/*
// increases code size
#define ceu_out_pending()   (!call Scheduler.isEmpty() || !q_isEmpty(&Q_EXTS))
*/
#define ceu_out_wclock(us)  { if ((us) != CEU_WCLOCK_INACTIVE) \
                                call Timer.startOneShot((us)/1000); }
                            // TODO: "binary" time

#include <message.h>
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

#ifdef CEU_IO_LEDS
    uses interface Leds;
#endif
#ifdef CEU_IO_SOUNDER
    uses interface Mts300Sounder as Sounder;
#endif
#ifdef CEU_IO_PHOTO
    uses interface Read<uint16_t> as Photo;
#endif
#ifdef CEU_IO_TEMP
    uses interface Read<uint16_t> as Temp;
#endif

#ifdef CEU_IO_RADIO
    uses interface AMSend       as RadioSend[am_id_t id];
    uses interface Receive      as RadioReceive[am_id_t id];
    uses interface Packet       as RadioPacket;
    uses interface AMPacket     as RadioAMPacket;
    uses interface SplitControl as RadioControl;
#endif
#ifdef CEU_IO_SERIAL
    uses interface AMSend       as SerialSend[am_id_t id];
    uses interface Receive      as SerialReceive[am_id_t id];
    uses interface Packet       as SerialPacket;
    uses interface AMPacket     as SerialAMPacket;
    uses interface SplitControl as SerialControl;
#endif

#ifdef CEU_IO_DISSEMINATION
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
    #include "_ceu_app.h"
    #include "_ceu_app.c"

    event void Boot.booted ()
    {
        old = call Timer.getNow();
        ceu_go_init(NULL);
#ifdef CEU_IN_START
        ceu_go_event(NULL, CEU_IN_START, NULL);
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
        ceu_go_wclock(NULL, dt*1000); // TODO: "binary" time
#ifndef ceu_out_wclock
        call Timer.startOneShot(10);
#endif
    }

#ifdef CEU_ASYNCS
    event void TimerAsync.fired ()
    {
        call TimerAsync.startOneShot(10);
        ceu_go_async(NULL);
    }
#endif

#ifdef CEU_IO_PHOTO
    event void Photo.readDone(error_t err, uint16_t val) {
        ceu_go_event(NULL, CEU_IN_PHOTO_READDONE, (void*)val);
    }
#endif // CEU_IO_PHOTO

#ifdef CEU_IO_TEMP
    event void Temp.readDone(error_t err, uint16_t val) {
        ceu_go_event(NULL, CEU_IN_TEMP_READDONE, (void*)val);
    }
#endif // CEU_IO_TEMP

#ifdef CEU_IO_RADIO
    event void RadioControl.startDone (error_t err) {
#ifdef CEU_IN_RADIO_STARTDONE
        ceu_go_event(NULL, CEU_IN_RADIO_STARTDONE, (void*)(int)err);
#endif
    }

    event void RadioControl.stopDone (error_t err) {
#ifdef CEU_IN_RADIO_STOPDONE
        ceu_go_event(NULL, CEU_IN_RADIO_STOPDONE, (void*)(int)err);
#endif
    }

    event void RadioSend.sendDone[am_id_t id](message_t* msg, error_t err)
    {
        //dbg("APP", "sendDone: %d %d\n", data[0], data[1]);
#ifdef CEU_IN_RADIO_SENDDONE
        tceu___message_t____int t = { msg, err };
        ceu_go_event(NULL, CEU_IN_RADIO_SENDDONE, &t);
#endif
    }

    event message_t* RadioReceive.receive[am_id_t id]
        (message_t* msg, void* payload, uint8_t nbytes)
    {
#ifdef CEU_IN_RADIO_RECEIVE
        tceu___message_t_____int t = { &msg, nbytes };
        ceu_go_event(NULL, CEU_IN_RADIO_RECEIVE, &t);
        return *t._1;
#endif
        return msg;
    }
#endif // CEU_IO_RADIO

#ifdef CEU_IO_SERIAL
    event void SerialControl.startDone (error_t err)
    {
#ifdef CEU_IN_SERIAL_STARTDONE
        ceu_go_event(NULL, CEU_IN_SERIAL_STARTDONE, (void*)(int)err);
#endif
    }

    event void SerialControl.stopDone (error_t err)
    {
#ifdef CEU_IN_SERIAL_STOPDONE
        ceu_go_event(NULL, CEU_IN_SERIAL_STOPDONE, (void*)(int)err);
#endif
    }

    event void SerialSend.sendDone[am_id_t id](message_t* msg, error_t err)
    {
        //dbg("APP", "sendDone: %d %d\n", data[0], data[1]);
#ifdef CEU_IN_SERIAL_SENDDONE
        tceu__message_t___int t = { msg, err };
        ceu_go_event(NULL, CEU_IN_SERIAL_SENDDONE, &t);
#endif
    }
    
    event message_t* SerialReceive.receive[am_id_t id]
        (message_t* msg, void* payload, uint8_t nbytes)
    {
#ifdef CEU_IN_SERIAL_RECEIVE
        tceu__message_t____int t = { &msg, nbytes };
        ceu_go_event(NULL, CEU_IN_SERIAL_RECEIVE, &t);
        return *t.msg_ptr;
#endif
        return msg;
    }

#endif // CEU_IO_SERIAL

#ifdef CEU_IO_DISSEMINATION

    event void DisseminationValue1.changed () {
#ifdef CEU_IN_DISSEMINATION_VALUE1
        const uint16_t* v = call DisseminationValue1.get();
        ceu_go_event(NULL, CEU_IN_DISSEMINATION_VALUE1, v);
#endif
    }

    event void DisseminationValue2.changed () {
#ifdef CEU_IN_DISSEMINATION_VALUE2
        const uint8_t* v = call DisseminationValue2.get();
        ceu_go_event(NULL, CEU_IN_DISSEMINATION_VALUE2, v);
#endif
    }

#endif

}
