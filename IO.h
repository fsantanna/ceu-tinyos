#ifndef CEU_IO_h
#define CEU_IO_h

#include "_ceu_app.h"

#if defined(CEU_FUN_Leds_led0Off) || defined(CEU_FUN_Leds_led1Off) || \
    defined(CEU_FUN_Leds_led2Off) || defined(CEU_FUN_Leds_led0On)  || \
    defined(CEU_FUN_Leds_led1On)  || defined(CEU_FUN_Leds_led2On)  || \
    defined(CEU_FUN_Leds_led0Toggle)  || defined(CEU_FUN_Leds_led1Toggle)  || \
    defined(CEU_FUN_Leds_led2Toggle) || \
    defined(CEU_FUN_Leds_set)
    #define CEU_IO_LEDS 1
#endif

#if defined(CEU_IN_RADIO_STARTDONE) || defined(CEU_IN_RADIO_STOPDONE) || \
    defined(CEU_IN_RADIO_SENDDONE)  || defined(CEU_IN_RADIO_RECEIVE)  || \
    defined(CEU_FUN_Radio_start)    || defined(OUT_RADIO_SEND)
    #define CEU_IO_RADIO 1
#endif

#if defined(CEU_IN_SERIAL_STARTDONE) || defined(CEU_IN_SERIAL_STOPDONE) || \
    defined(CEU_IN_SERIAL_SENDDONE)  || defined(CEU_IN_SERIAL_RECEIVE)  || \
    defined(CEU_FUN_Serial_start)    || defined(OUT_SERIAL_SEND)
    #define CEU_IO_SERIAL 1
#endif

#if defined(CEU_FUN_Photo_read) || defined(CEU_IN_PHOTO_READDONE)
    #define CEU_IO_PHOTO 1
#endif

#if defined(CEU_FUN_Temp_read) || defined(CEU_IN_TEMP_READDONE)
    #define CEU_IO_TEMP 1
#endif

#if defined(CEU_FUN_Sounder_beep)
    #define CEU_IO_SOUNDER 1
#endif

// TODO
//#define CEU_IO_DISSEMINATION 1

#endif  // CEU_IO_h
