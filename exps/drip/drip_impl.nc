implementation {
  enum { NUM_DISSEMINATORS = uniqueCount("DisseminationTimerC.TrickleTimer") };
  message_t m_buf;
  bool m_running;
  bool m_bufBusy;
  void sendProbe( uint16_t key );
  void sendObject( uint16_t key );
  command error_t StdControl.start() {
    uint8_t i;
    for ( i = 0; i < NUM_DISSEMINATORS; i++ ) {
      call DisseminatorControl.start[ i ]();
    }
    m_running = TRUE;
sendProbe(1);
    return SUCCESS;
  }
  command error_t StdControl.stop() {
    uint8_t i;
    for ( i = 0; i < NUM_DISSEMINATORS; i++ ) {
      call DisseminatorControl.stop[ i ]();
    }
    m_running = FALSE;
    return SUCCESS;
  }
  event error_t DisseminationCache.start[ uint16_t key ]() {
    error_t result = call TrickleTimer.start[ key ]();
    call TrickleTimer.reset[ key ]();
    return result;
  }
  event error_t DisseminationCache.stop[ uint16_t key ]() {
    call TrickleTimer.stop[ key ]();
    return SUCCESS;
  }
  event void DisseminationCache.newData[ uint16_t key ]() {
    sendObject( key );
    call TrickleTimer.reset[ key ]();
  }
  event void TrickleTimer.fired[ uint16_t key ]() {
    sendObject( key );
  }
  void sendProbe( uint16_t key ) {
    dissemination_probe_message_t* dpMsg = 
      (dissemination_probe_message_t*) call ProbeAMSend.getPayload( &m_buf, sizeof(dissemination_probe_message_t));
    if (dpMsg != NULL) {
      m_bufBusy = TRUE;
      dpMsg->key = key;
      call ProbeAMSend.send( AM_BROADCAST_ADDR, &m_buf,
			     sizeof( dissemination_probe_message_t ) );
    }
  }
  void sendObject( uint16_t key ) {
    void* object;
    uint8_t objectSize = 0;
    dissemination_message_t* dMsg;
    if ( !m_running || m_bufBusy ) { return; }
    dMsg = 
      (dissemination_message_t*) call AMSend.getPayload( &m_buf, sizeof(dissemination_message_t) );
    if (dMsg != NULL) {
      m_bufBusy = TRUE;
      dMsg->key = key;
      dMsg->seqno = call DisseminationCache.requestSeqno[ key ]();
      if ( dMsg->seqno != DISSEMINATION_SEQNO_UNKNOWN ) {
	object = call DisseminationCache.requestData[ key ]( &objectSize );
	if ((objectSize + sizeof(dissemination_message_t)) > 
	    call AMSend.maxPayloadLength()) {
	  objectSize = call AMSend.maxPayloadLength() - sizeof(dissemination_message_t);
	}
	memcpy( dMsg->data, object, objectSize );
      }      
      call AMSend.send( AM_BROADCAST_ADDR,
			&m_buf, sizeof( dissemination_message_t ) + objectSize );
    }
  }
  event void ProbeAMSend.sendDone( message_t* msg, error_t error ) {
    m_bufBusy = FALSE;
  }
  event void AMSend.sendDone( message_t* msg, error_t error ) {
    m_bufBusy = FALSE;
  }
  event message_t* Receive.receive( message_t* msg, 
				    void* payload, 
				    uint8_t len ) {
    dissemination_message_t* dMsg = 
      (dissemination_message_t*) payload;
    uint16_t key = dMsg->key;
    uint32_t incomingSeqno = dMsg->seqno;
    uint32_t currentSeqno = call DisseminationCache.requestSeqno[ key ]();
    if ( !m_running ) { return msg; }
    if ( currentSeqno == DISSEMINATION_SEQNO_UNKNOWN &&
	 incomingSeqno != DISSEMINATION_SEQNO_UNKNOWN ) {
      call DisseminationCache.storeData[ key ]
	( dMsg->data, 
	  len - sizeof( dissemination_message_t ),
	  incomingSeqno );
      call TrickleTimer.reset[ key ]();
      return msg;
    }
    if ( incomingSeqno == DISSEMINATION_SEQNO_UNKNOWN &&
	 currentSeqno != DISSEMINATION_SEQNO_UNKNOWN ) {
      call TrickleTimer.reset[ key ]();
      return msg;
    }
    if ( (int32_t)( incomingSeqno - currentSeqno ) > 0 ) {
      call DisseminationCache.storeData[key]
	( dMsg->data, 
	  len - sizeof(dissemination_message_t),
	  incomingSeqno );
      dbg("Dissemination", "Received dissemination value 0x%08x,0x%08x @ %s\n", (int)key, (int)incomingSeqno, sim_time_string());
      call TrickleTimer.reset[ key ]();
    } else if ( (int32_t)( incomingSeqno - currentSeqno ) == 0 ) {
      call TrickleTimer.incrementCounter[ key ]();
    } else {
      sendObject( key );
    }
    return msg;
  }
  event message_t* ProbeReceive.receive( message_t* msg, 
					 void* payload, 
					 uint8_t len) {
    dissemination_probe_message_t* dpMsg = 
      (dissemination_probe_message_t*) payload;
    if ( !m_running ) { return msg; }
    if ( call DisseminationCache.requestSeqno[ dpMsg->key ]() != 
	 DISSEMINATION_SEQNO_UNKNOWN ) {    
      sendObject( dpMsg->key );
    }
    return msg;
  }
  default command void* 
    DisseminationCache.requestData[uint16_t key]( uint8_t* size ) { return NULL; }
  default command void 
    DisseminationCache.storeData[uint16_t key]( void* data, 
						uint8_t size, 
						uint32_t seqno ) {}
  default command uint32_t 
    DisseminationCache.requestSeqno[uint16_t key]() { return DISSEMINATION_SEQNO_UNKNOWN; }
  default command error_t TrickleTimer.start[uint16_t key]() { return FAIL; }
  default command void TrickleTimer.stop[uint16_t key]() { }
  default command void TrickleTimer.reset[uint16_t key]() { }
  default command void TrickleTimer.incrementCounter[uint16_t key]() { }
  default command error_t DisseminatorControl.start[uint16_t id]() { return FAIL; }
  default command error_t DisseminatorControl.stop[uint16_t id]() { return FAIL; }
}
implementation {
  t valueCache;
  bool m_running;
  uint32_t seqno = DISSEMINATION_SEQNO_UNKNOWN;
  task void changedTask() {
    signal DisseminationValue.changed();
  }
  command error_t StdControl.start() {
    error_t result = signal DisseminationCache.start();
    if ( result == SUCCESS ) { m_running = TRUE; }
    return result;
  }
  command error_t StdControl.stop() {
    if ( !m_running ) { return EOFF; }
    m_running = FALSE;
    return signal DisseminationCache.stop();
  }
  command const t* DisseminationValue.get() {
    return &valueCache;
  }
  command void DisseminationValue.set( const t* val ) {
    if (seqno == DISSEMINATION_SEQNO_UNKNOWN) {
      valueCache = *val;
    }
  }
  command void DisseminationUpdate.change( t* newVal ) {
    if ( !m_running ) { return; }
    memcpy( &valueCache, newVal, sizeof(t) );
    seqno = seqno >> 16;
    seqno++;
    if ( seqno == DISSEMINATION_SEQNO_UNKNOWN ) { seqno++; }
    seqno = seqno << 16;
    seqno += TOS_NODE_ID;
    signal DisseminationCache.newData();
    post changedTask();
  }
  command void* DisseminationCache.requestData( uint8_t* size ) {
    *size = sizeof(t);
    return &valueCache;
  }
  command void DisseminationCache.storeData( void* data, uint8_t size,
					     uint32_t newSeqno ) {
    memcpy( &valueCache, data, size < sizeof(t) ? size : sizeof(t) );
    seqno = newSeqno;
    signal DisseminationValue.changed();
  }
  command uint32_t DisseminationCache.requestSeqno() {
    return seqno;
  }
  default event void DisseminationValue.changed() { }
}
