#include "IO.h"

configuration AppAppC
{
}

implementation
{
    components MainC, AppC, SchedulerBasicP;
    components new TimerMilliC() as Timer;
#ifdef CEU_ASYNCS
    components new TimerMilliC() as TimerAsync;
#endif

#ifdef IO_LEDS
    components LedsC;
#endif
#ifdef IO_SOUNDER
    components SounderC;
#endif
#ifdef IO_PHOTO
    components new PhotoC();
#endif
#ifdef IO_TEMP
    components new TempC();
#endif
#ifdef IO_RADIO
    components ActiveMessageC as Radio;
#endif
#ifdef IO_SERIAL
    components SerialActiveMessageC as Serial;
#endif

    AppC.Scheduler -> SchedulerBasicP;
    AppC.Boot  -> MainC;
    AppC.Timer -> Timer;
#ifdef CEU_ASYNCS
    AppC.TimerAsync -> TimerAsync;
#endif

#ifdef IO_LEDS
    AppC.Leds  -> LedsC;
#endif
#ifdef IO_SOUNDER
    AppC.Sounder -> SounderC ;
#endif
#ifdef IO_PHOTO
    AppC.Photo -> PhotoC;
#endif
#ifdef IO_TEMP
    AppC.Temp -> TempC;
#endif

#ifdef IO_RADIO
    AppC.RadioSend     -> Radio.AMSend;
    AppC.RadioReceive  -> Radio.Receive;
    AppC.RadioPacket   -> Radio.Packet;
    AppC.RadioAMPacket -> Radio.AMPacket;
    AppC.RadioControl  -> Radio.SplitControl;
#endif
    
#ifdef IO_SERIAL
    AppC.SerialSend     -> Serial.AMSend;
    AppC.SerialReceive  -> Serial.Receive;
    AppC.SerialPacket   -> Serial.Packet;
    AppC.SerialAMPacket -> Serial.AMPacket;
    AppC.SerialControl  -> Serial.SplitControl;
#endif

#ifdef IO_DISSEMINATION
    components DisseminationC;
    AppC.Dissemination -> DisseminationC;

    components new DisseminatorC(uint16_t, 0x1111) as Dissemination1;
    AppC.DisseminationValue1  -> Dissemination1;
    AppC.DisseminationUpdate1 -> Dissemination1;

    components new DisseminatorC(uint8_t, 0x1112) as Dissemination2;
    AppC.DisseminationValue2  -> Dissemination2;
    AppC.DisseminationUpdate2 -> Dissemination2;
#endif

}
