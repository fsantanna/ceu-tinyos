/*
// increases code size
#define ceu_out_pending()   (!call Scheduler.isEmpty() || !q_isEmpty(&Q_EXTS))
*/
#define ceu_out_wclock(us)  { if ((us) != CEU_WCLOCK_INACTIVE) \
                                call Timer.startOneShot((us)/1000); }
                            // TODO: "binary" time

#include "IO.h"
#include "Timer.h"

module AppC @safe()
{
    uses interface Boot;
    uses interface Scheduler;
    uses interface Timer<TMilli> as Timer;
#ifdef CEU_ASYNCS
    uses interface Timer<TMilli> as TimerAsync;
#endif

#ifdef IO_LEDS
    uses interface Leds;
#endif
#ifdef IO_SOUNDER
    uses interface Mts300Sounder as Sounder;
#endif
#ifdef IO_PHOTO
    uses interface Read<uint16_t> as Photo;
#endif
#ifdef IO_TEMP
    uses interface Read<uint16_t> as Temp;
#endif

#ifdef IO_RADIO
    uses interface AMSend       as RadioSend[am_id_t id];
    uses interface Receive      as RadioReceive[am_id_t id];
    uses interface Packet       as RadioPacket;
    uses interface AMPacket     as RadioAMPacket;
    uses interface SplitControl as RadioControl;
#endif
#ifdef IO_SERIAL
    uses interface AMSend       as SerialSend[am_id_t id];
    uses interface Receive      as SerialReceive[am_id_t id];
    uses interface Packet       as SerialPacket;
    uses interface AMPacket     as SerialAMPacket;
    uses interface SplitControl as SerialControl;
#endif

#ifdef IO_DISSEMINATION
    uses interface StdControl as Dissemination;
    uses interface DisseminationValue<uint16_t>  as DisseminationValue1;
    uses interface DisseminationUpdate<uint16_t> as DisseminationUpdate1;
    uses interface DisseminationValue<uint8_t>   as DisseminationValue2;
    uses interface DisseminationUpdate<uint8_t>  as DisseminationUpdate2;
#endif
}

implementation
{
    u32 old;

    #include "tinyos.c"
    #include "_ceu_code.cceu"

    event void Boot.booted ()
    {
        old = call Timer.getNow();
        ceu_go_init();
#ifdef IN_START
        ceu_go_event(IN_START, NULL);
#endif

        // TODO: periodic nunca deixaria TOSSched queue vazia
#ifndef ceu_out_wclock
        call Timer.startOneShot(10);
#endif
#ifdef CEU_ASYNCS
        call TimerAsync.startOneShot(10);
#endif
    }
    
    event void Timer.fired ()
    {
        u32 now = call Timer.getNow();
        s32 dt = now - old;
        old = now;
        ceu_go_wclock(dt*1000); // TODO: "binary" time
#ifndef ceu_out_wclock
        call Timer.startOneShot(10);
#endif
    }

#ifdef CEU_ASYNCS
    event void TimerAsync.fired ()
    {
        call TimerAsync.startOneShot(10);
        ceu_go_async(NULL,NULL);
    }
#endif

#ifdef IO_PHOTO
    event void Photo.readDone(error_t err, uint16_t val) {
        ceu_go_event(IN_PHOTO_READDONE, (void*)val);
    }
#endif // IO_PHOTO

#ifdef IO_TEMP
    event void Temp.readDone(error_t err, uint16_t val) {
        ceu_go_event(IN_TEMP_READDONE, (void*)val);
    }
#endif // IO_TEMP

#ifdef IO_RADIO
    event void RadioControl.startDone (error_t err) {
#ifdef IN_RADIO_STARTDONE
        ceu_go_event(IN_RADIO_STARTDONE, (void*)(int)err);
#endif
    }

    event void RadioControl.stopDone (error_t err) {
#ifdef IN_RADIO_STOPDONE
        ceu_go_event(IN_RADIO_STOPDONE, (void*)(int)err);
#endif
    }

    event void RadioSend.sendDone[am_id_t id](message_t* msg, error_t err)
    {
        //dbg("APP", "sendDone: %d %d\n", data[0], data[1]);
#ifdef IN_RADIO_SENDDONE
        ceu_go_event(IN_RADIO_SENDDONE, (void*)(int)err);
#endif
    }

    event message_t* RadioReceive.receive[am_id_t id]
        (message_t* msg, void* payload, uint8_t nbytes)
    {
#ifdef IN_RADIO_RECEIVE
        ceu_go_event(IN_RADIO_RECEIVE, msg);
#endif
        return msg;
    }
#endif // IO_RADIO

#ifdef IO_SERIAL
    event void SerialControl.startDone (error_t err)
    {
#ifdef IN_SERIAL_STARTDONE
        ceu_go_event(IN_SERIAL_STARTDONE, (void*)(int)err);
#endif
    }

    event void SerialControl.stopDone (error_t err)
    {
#ifdef IN_SERIAL_STOPDONE
        ceu_go_event(IN_SERIAL_STOPDONE, (void*)(int)err);
#endif
    }

    event void SerialSend.sendDone[am_id_t id](message_t* msg, error_t err)
    {
        //dbg("APP", "sendDone: %d %d\n", data[0], data[1]);
#ifdef IN_SERIAL_SENDDONE
        ceu_go_event(IN_SERIAL_SENDDONE, (void*)(int)err);
#endif
    }
    
    event message_t* SerialReceive.receive[am_id_t id]
        (message_t* msg, void* payload, uint8_t nbytes)
    {
#ifdef IN_SERIAL_RECEIVE
        ceu_go_event(IN_SERIAL_RECEIVE, msg);
#endif
        return msg;
    }

#endif // IO_SERIAL

#ifdef IO_DISSEMINATION

    event void DisseminationValue1.changed () {
#ifdef IN_DISSEMINATION_VALUE1
        const uint16_t* v = call DisseminationValue1.get();
        ceu_go_event(IN_DISSEMINATION_VALUE1, v);
#endif
    }

    event void DisseminationValue2.changed () {
#ifdef IN_DISSEMINATION_VALUE2
        const uint8_t* v = call DisseminationValue2.get();
        ceu_go_event(IN_DISSEMINATION_VALUE2, v);
#endif
    }

#endif

}
