// LEDS

#define DBG(fmt,args...)

#ifdef CEU_FUN_Leds_set
void Leds_set (uint8_t v) {
    call Leds.set(v);
}
#endif

#ifdef CEU_FUN_Leds_led0On
void Leds_led0On () {
    call Leds.led0On();
}
#endif
#ifdef CEU_FUN_Leds_led1On
void Leds_led1On () {
    call Leds.led1On();
}
#endif
#ifdef CEU_FUN_Leds_led2On
void Leds_led2On () {
    call Leds.led2On();
}
#endif

#ifdef CEU_FUN_Leds_led0Off
void Leds_led0Off () {
    call Leds.led0Off();
}
#endif
#ifdef CEU_FUN_Leds_led1Off
void Leds_led1Off () {
    call Leds.led1Off();
}
#endif
#ifdef CEU_FUN_Leds_led2Off
void Leds_led2Off () {
    call Leds.led2Off();
}
#endif

#ifdef CEU_FUN_Leds_led0Toggle
void Leds_led0Toggle () {
    call Leds.led0Toggle();
}
#endif
#ifdef CEU_FUN_Leds_led1Toggle
void Leds_led1Toggle () {
    call Leds.led1Toggle();
}
#endif
#ifdef CEU_FUN_Leds_led2Toggle
void Leds_led2Toggle () {
    call Leds.led2Toggle();
}
#endif

// PHOTO

#ifdef CEU_FUN_Photo_read
int Photo_read () {
   return call Photo.read();
}
#endif

// TEMP

#ifdef CEU_FUN_Temp_read
int Temp_read () {
   return call Temp.read();
}
#endif

// RADIO
#ifdef CEU_IO_RADIO

int Radio_start_on = 1;

error_t Radio_start () {
    return call RadioControl.start();
}
error_t Radio_stop () {
    return call RadioControl.stop();
}

#ifdef CEU_FUN_Radio_clear
void Radio_clear (message_t* msg) {
    call RadioPacket.clear(msg);
}
#endif

void* Radio_getPayload (message_t* msg, uint8_t len) {
    return call RadioPacket.getPayload(msg, len);
}

uint8_t Radio_payloadLength (message_t *msg) {
    return call RadioPacket.payloadLength(msg);
}

void Radio_setPayloadLength (message_t* msg, uint8_t len) {
    return call RadioPacket.setPayloadLength(msg, len);
}

uint8_t Radio_maxPayloadLength () {
    return call RadioPacket.maxPayloadLength();
}

am_addr_t Radio_source (message_t* msg) {
    return call RadioAMPacket.source(msg);
}

void Radio_setSource (message_t* msg, am_addr_t addr) {
    return call RadioAMPacket.setSource(msg, addr);
}

am_addr_t Radio_destination (message_t* msg) {
    return call RadioAMPacket.destination(msg);
}

void Radio_setDestination (message_t* msg, am_addr_t addr) {
    return call RadioAMPacket.setDestination(msg, addr);
}

am_id_t Radio_type (message_t* msg) {
    return call RadioAMPacket.type(msg);
}

void Radio_setType (message_t* msg, am_id_t id) {
    call RadioAMPacket.setType(msg, id);
}

am_group_t Radio_group (message_t* msg) {
    return call RadioAMPacket.group(msg);
}

void Radio_setGroup (message_t* msg, am_group_t id) {
    call RadioAMPacket.setGroup(msg, id);
}

#ifdef CEU_OUT_RADIO_SEND
#define ceu_out_event_RADIO_SEND RADIO_SEND
void RADIO_SEND (tceu___message_t____int_* p)  {
    am_id_t id     = call RadioAMPacket.type(p->_1);
    am_addr_t addr = call RadioAMPacket.destination(p->_1);
    int len        = call RadioPacket.payloadLength(p->_1);

    error_t err = call RadioSend.send[id](addr, p->_1, len);
    if (p->_2 != NULL)
        *(p->_2) = err;
}
#endif

#endif  // CEU_IO_RADIO

// SERIAL
#ifdef CEU_IO_SERIAL

int Serial_start_on = 1;

#ifdef CEU_FUN_Serial_start
error_t Serial_start () {
    return call SerialControl.start();
}
#endif
#ifdef CEU_FUN_Serial_stop
error_t Serial_stop () {
    return call SerialControl.stop();
}
#endif

#ifdef CEU_FUN_Serial_clear
void Serial_clear (message_t* msg) {
    call SerialPacket.clear(msg);
}
#endif

#ifdef CEU_FUN_Serial_getPayload
void* Serial_getPayload (message_t* msg, uint8_t len) {
    return call SerialPacket.getPayload(msg, len);
}
#endif

#ifdef CEU_FUN_Serial_payloadLength
uint8_t Serial_payloadLength (message_t *msg) {
    return call SerialPacket.payloadLength(msg);
}
#endif

#ifdef CEU_FUN_Serial_setPayloadLength
void Serial_setPayloadLength (message_t* msg, uint8_t len) {
    return call SerialPacket.setPayloadLength(msg, len);
}
#endif

#ifdef CEU_FUN_Serial_maxPayloadLength
uint8_t Serial_maxPayloadLength () {
    return call SerialPacket.maxPayloadLength();
}
#endif

#ifdef CEU_FUN_Serial_source
am_addr_t Serial_source (message_t* msg) {
    return call SerialAMPacket.source(msg);
}
#endif

#ifdef CEU_FUN_Serial_setSource
void Serial_setSource (message_t* msg, am_addr_t addr) {
    return call SerialAMPacket.setSource(msg, addr);
}
#endif

#ifdef CEU_FUN_Serial_destination
am_addr_t Serial_destination (message_t* msg) {
    return call SerialAMPacket.destination(msg);
}
#endif

#ifdef CEU_FUN_Serial_setDestination
void Serial_setDestination (message_t* msg, am_addr_t addr) {
    return call SerialAMPacket.setDestination(msg, addr);
}
#endif

#ifdef CEU_FUN_Serial_type
am_id_t Serial_type (message_t* msg) {
    return call SerialAMPacket.type(msg);
}
#endif

#ifdef CEU_FUN_Serial_setType
void Serial_setType (message_t* msg, am_id_t id) {
    call SerialAMPacket.setType(msg, id);
}
#endif

#ifdef CEU_FUN_Serial_group
am_group_t Serial_group (message_t* msg) {
    return call SerialAMPacket.group(msg);
}
#endif

#ifdef CEU_FUN_Serial_setGroup
void Serial_setGroup (message_t* msg, am_group_t id) {
    call SerialAMPacket.setGroup(msg, id);
}
#endif

#ifdef CEU_OUT_SERIAL_SEND
#define ceu_out_event_SERIAL_SEND SERIAL_SEND
void SERIAL_SEND (tceu___message_t____int_* p)  {
    am_id_t id     = call SerialAMPacket.type(p->_1);
    am_addr_t addr = call SerialAMPacket.destination(p->_1);
    int len        = call SerialPacket.payloadLength(p->_1);
    error_t err = call SerialSend.send[id](addr, p->_1, len);
    if (p->_2 != NULL)
        *p->_2 = err;
}
#endif

#endif  // CEU_IO_SERIAL

#ifdef CEU_FUN_Dissemination_start
void Dissemination_start () {
    call Dissemination.start();
}
#endif

#ifdef CEU_FUN_Dissemination_change1
void Dissemination_change1 (u16* v) {
    dbg("DIP", "1 = %d\n", *v);
    call DisseminationUpdate1.change(v);
}
#endif

#ifdef CEU_FUN_Dissemination_change2
void Dissemination_change2 (u8* v) {
    call DisseminationUpdate2.change(v);
}
#endif
