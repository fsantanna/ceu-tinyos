#ifndef IO_h
#define IO_h

#include "_ceu_defs.h"

#if defined(FUNC_Leds_led0Off) || defined(FUNC_Leds_led1Off) || \
    defined(FUNC_Leds_led2Off) || defined(FUNC_Leds_led0On)  || \
    defined(FUNC_Leds_led1On)  || defined(FUNC_Leds_led2On)  || \
    defined(FUNC_Leds_led0Toggle)  || defined(FUNC_Leds_led1Toggle)  || \
    defined(FUNC_Leds_led2Toggle) || \
    defined(FUNC_Leds_set)
    #define IO_LEDS 1
#endif

#if defined(IN_RADIO_STARTDONE) || defined(IN_RADIO_STOPDONE) || \
    defined(IN_RADIO_SENDDONE)  || defined(IN_RADIO_RECEIVE)  || \
    defined(FUNC_Radio_start)   || defined(OUT_RADIO_SEND)
    #define IO_RADIO 1
#endif

#if defined(IN_SERIAL_STARTDONE) || defined(IN_SERIAL_STOPDONE) || \
    defined(IN_SERIAL_SENDDONE)  || defined(IN_SERIAL_RECEIVE)  || \
    defined(FUNC_Serial_start)   || defined(OUT_SERIAL_SEND)
    #define IO_SERIAL 1
#endif

#if defined(FUNC_Photo_read) || defined(IN_PHOTO_READDONE)
    #define IO_PHOTO 1
#endif

#if defined(FUNC_Temp_read) || defined(IN_TEMP_READDONE)
    #define IO_TEMP 1
#endif

#if defined(FUNC_Sounder_beep)
    #define IO_SOUNDER 1
#endif

// TODO
//#define IO_DISSEMINATION 1

#endif  // IO_h
