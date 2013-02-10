#define nx_struct struct

typedef s8  nx_int8_t;
typedef u8  nx_uint8_t;
typedef s16 nx_int16_t;
typedef u16 nx_uint16_t;
typedef u16 nxle_uint16_t;
typedef s32 nx_int32_t;
typedef u32 nx_uint32_t;

typedef u8  bool;
typedef u8  error_t;
typedef u8  am_id_t;
typedef u8  am_group_t;
typedef u16 am_addr_t;
typedef u8  nx_am_id_t;
typedef u8  nx_am_group_t;
typedef u16 nx_am_addr_t;

enum {
    AM_BROADCAST_ADDR = 0xffff,
};

enum {
    SUCCESS  =  0,
    FAIL     =  1, // Generic condition: backwards compatible
    ESIZE    =  2, // Parameter passed in was too big.
    ECANCEL  =  3, // Operation cancelled by a call.
    EOFF     =  4, // Subsystem is not active
    EBUSY    =  5, // The underlying system is busy; retry later
    EINVAL   =  6, // An invalid parameter was passed
    ERETRY   =  7, // A rare and transient failure: can retry
    ERESERVE =  8, // Reservation required before usage
    EALREADY =  9, // The device state you are requesting is already set
    ENOMEM   = 10, // Memory required not available
    ENOACK   = 11, // A packet was not acknowledged
    ELAST    = 11  // Last enum value
};

#define TOSH_DATA_LENGTH 64         // TODO: larger than in TinyOS
#define TOS_BCAST_ADDR 0xFFFF

typedef nx_struct {
    nx_am_addr_t dest;
    nx_am_addr_t src;
    nx_uint8_t length;
    nx_am_group_t group;
    nx_am_id_t type;
} message_header_t;

typedef nx_struct {
    nxle_uint16_t crc;
} message_footer_t;

typedef nx_struct {
    nx_int8_t strength;
    nx_uint8_t ack;
    nx_uint16_t time;
} message_metadata_t;

typedef nx_struct message_t {
    message_header_t   header;
    nx_uint8_t         data[TOSH_DATA_LENGTH];
    message_footer_t   footer;
    message_metadata_t metadata;
} message_t;

/* SERIAL */

#ifdef IO_SERIAL

int Serial_start_on = 0;
int Serial_start ()
{
    static int v1[] = CEU_SEQV_Serial_start;
    static int n1 = 0;
    int ret;
    if (n1 < CEU_SEQN_Serial_start)
        ret = v1[n1++];
    else
        ret = SUCCESS;

    static int v2[] = CEU_SEQV_SERIAL_STARTDONE;
    static int n2 = 0;
    if (ret == SUCCESS) {
        if (n2 < CEU_SEQN_SERIAL_STARTDONE)
            ret = MQ(IN_SERIAL_STARTDONE, v2[n2++]);
        else
            ret = MQ(IN_SERIAL_STARTDONE, SUCCESS);
        ret = ((ret==0) ? SUCCESS : EBUSY);
    }

    Serial_start_on = (ret==SUCCESS);
    return ret;
}
am_addr_t Serial_getSource (message_t* msg) {
    return msg->header.src;
}
void Serial_setSource (message_t* msg, am_addr_t to) {
    msg->header.src = to;
}
am_addr_t Serial_getDestination (message_t* msg) {
    return msg->header.dest;
}
void Serial_setDestination (message_t* msg, am_addr_t to) {
    msg->header.dest = to;
}
am_id_t Serial_getType (message_t* msg) {
    return msg->header.type;
}
void Serial_setType (message_t* msg, am_id_t id) {
    msg->header.type = id;
}
void* Serial_getPayload (message_t* msg, u8 len) {
    if (len <= TOSH_DATA_LENGTH) {
        return msg->data;
    }
    else {
        return NULL;
    }
}
void Serial_setPayloadLength(message_t* msg, u8 len) {
    msg->header.length = len;
}

#endif /* IO_SERIAL */

/* RADIO */

#ifdef IO_RADIO

int Radio_start_on = 0;
int Radio_start ()
{
    static int v1[] = CEU_SEQV_Radio_start;
    static int n1 = 0;
    int ret;
    if (n1 < CEU_SEQN_Radio_start)
        ret = v1[n1++];
    else
        ret = SUCCESS;

    static int v2[] = CEU_SEQV_RADIO_STARTDONE;
    static int n2 = 0;
    if (ret == SUCCESS) {
        if (n2 < CEU_SEQN_RADIO_STARTDONE)
            ret = MQ(IN_RADIO_STARTDONE, v2[n2++]);
        else
            ret = MQ(IN_RADIO_STARTDONE, SUCCESS);
        ret = ((ret==0) ? SUCCESS : EBUSY);
    }

    Radio_start_on = (ret==SUCCESS);
    return ret;
}
am_addr_t Radio_getSource (message_t* msg) {
    return msg->header.src;
}
void Radio_setSource (message_t* msg, am_addr_t to) {
    msg->header.src = to;
}
am_addr_t Radio_getDestination (message_t* msg) {
    return msg->header.dest;
}
void Radio_setDestination (message_t* msg, am_addr_t to) {
    msg->header.dest = to;
}
am_id_t Radio_getType (message_t* msg) {
    return msg->header.type;
}
void Radio_setType (message_t* msg, am_id_t id) {
    msg->header.type = id;
}
void* Radio_getPayload (message_t* msg, u8 len) {
    if (len <= TOSH_DATA_LENGTH) {
        return msg->data;
    }
    else {
        return NULL;
    }
}
void Radio_setPayloadLength(message_t* msg, u8 len) {
    msg->header.length = len;
}
uint8_t Radio_maxPayloadLength() {
    return TOSH_DATA_LENGTH;
}

#define ceu_out_event_RADIO_SEND(a) RADIO_SEND(a)
int RADIO_SEND (message_t* data) {
    int ret = 0;
    if (!Radio_start_on)
        return 0;
#ifdef TOS_COLLISION
    if (rand()%100 >= TOS_COLLISION)
#endif
        ret = ceu_out_event_F(OUT_RADIO_SEND, sizeof(message_t), data);
#ifdef IN_RADIO_SENDDONE
    MQ(IN_RADIO_SENDDONE, 1);
#endif
    return ret;
}

#ifdef FUNC_Photo_read
int Photo_read ()
{
    static int v1[] = CEU_SEQV_Photo_read;
    static int n1 = 0;
    int ret;
    if (n1 < CEU_SEQN_Photo_read)
        ret = v1[n1++];
    else
        ret = SUCCESS;

#ifdef IN_PHOTO_READDONE
    static int v2[] = CEU_SEQV_PHOTO_READDONE;
    static int n2 = 0;
    if (ret == SUCCESS) {
        if (n2 < CEU_SEQN_PHOTO_READDONE)
            MQ(IN_PHOTO_READDONE, v2[n2++]);
        else
            MQ(IN_PHOTO_READDONE, v2[n2-1]);
    }
#endif

    return ret;
}
#endif

#ifdef FUNC_Temp_read
int Temp_read ()
{
    static int v1[] = CEU_SEQV_Temp_read;
    static int n1 = 0;
    int ret;
    if (n1 < CEU_SEQN_Temp_read)
        ret = v1[n1++];
    else
        ret = SUCCESS;

#ifdef IN_TEMP_READDONE
    static int v2[] = CEU_SEQV_TEMP_READDONE;
    static int n2 = 0;
    if (ret == SUCCESS) {
        if (n2 < CEU_SEQN_TEMP_READDONE)
            MQ(IN_TEMP_READDONE, v2[n2++]);
        else
            MQ(IN_TEMP_READDONE, v2[n2-1]);
    }
#endif

    return ret;
}
#endif

#endif /* IO_RADIO */

/* LED */

#ifdef IO_LEDS

u8 leds = 0;

void Leds_dbg () {
    DBG("leds (%d %d %d)\n", (leds&(1<<2))>>2, (leds&(1<<1))>>1, leds&(1<<0));
}

#ifdef FUNC_Leds_set
void Leds_set (int v) {
    leds = v;
    Leds_dbg();
}
#endif

#ifdef FUNC_Leds_led0On
void Leds_led0On () {
    leds |= 1 << 0;
    Leds_dbg();
}
#endif
#ifdef FUNC_Leds_led0Off
void Leds_led0Off () {
    leds &= ~(1 << 0);
    Leds_dbg();
}
#endif
#ifdef FUNC_Leds_led0Toggle
void Leds_led0Toggle () {
    leds ^= 1 << 0;
    Leds_dbg();
}
#endif

#ifdef FUNC_Leds_led1On
void Leds_led1On () {
    leds |= 1 << 1;
    Leds_dbg();
}
#endif
#ifdef FUNC_Leds_led1Off
void Leds_led1Off () {
    leds &= ~(1 << 1);
    Leds_dbg();
}
#endif
#ifdef FUNC_Leds_led1Toggle
void Leds_led1Toggle () {
    leds ^= 1 << 1;
    Leds_dbg();
}
#endif

#ifdef FUNC_Leds_led2On
void Leds_led2On () {
    leds |= 1 << 2;
    Leds_dbg();
}
#endif
#ifdef FUNC_Leds_led2Off
void Leds_led2Off () {
    leds &= ~(1 << 2);
    Leds_dbg();
}
#endif
#ifdef FUNC_Leds_led2Toggle
void Leds_led2Toggle () {
    leds ^= 1 << 2;
    Leds_dbg();
}
#endif

#endif
