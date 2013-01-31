#include <Timer.h>
generic module TrickleTimerImplP(uint16_t low,
				 uint16_t high,
				 uint8_t k,
				 uint8_t count,
				 uint8_t scale) {
  provides {
    interface Init;
    interface TrickleTimer[uint8_t id];
  }
  uses {
    interface Timer<TMilli>;
    interface BitVector as Pending;
    interface BitVector as Changed;
    interface Random;
    interface Leds;
  }
}
implementation {
  typedef struct {
    uint16_t period;
    uint32_t time;
    uint32_t remainder;
    uint8_t count;
  } trickle_t;
  trickle_t trickles[count];
  void adjustTimer();
  void generateTime(uint8_t id);
  command error_t Init.init() {
    int i;
    for (i = 0; i < count; i++) {
      trickles[i].period = high;
      trickles[i].count = 0;
      trickles[i].time = 0;
      trickles[i].remainder = 0;
    }
    atomic {
      call Pending.clearAll();
      call Changed.clearAll();
    }
    return SUCCESS;
  }
  command error_t TrickleTimer.start[uint8_t id]() {
    if (trickles[id].time != 0) {
      return EBUSY;
    }
    trickles[id].time = 0;
    trickles[id].remainder = 0;
    trickles[id].count = 0;
    generateTime(id);
    atomic {
      call Changed.set(id);
    }
    adjustTimer();
    dbg("Trickle", "Starting trickle timer %hhu @ %s\n", id, sim_time_string());
    return SUCCESS;
  }
  command void TrickleTimer.stop[uint8_t id]() {
    trickles[id].time = 0;
    trickles[id].period = high;
    adjustTimer();
    dbg("Trickle", "Stopping trickle timer %hhu @ %s\n", id, sim_time_string());
  }
  command void TrickleTimer.reset[uint8_t id]() {
    trickles[id].period = low;
    trickles[id].count = 0;
    if (trickles[id].time != 0) {
      dbg("Trickle", "Resetting running trickle timer %hhu @ %s\n", id, sim_time_string());
      atomic {
	call Changed.set(id);
      }
      trickles[id].time = 0;
      trickles[id].remainder = 0;
      generateTime(id);
      adjustTimer();
    } else {
      dbg("Trickle", "Resetting  trickle timer %hhu @ %s\n", id, sim_time_string());
    }
  }
  command void TrickleTimer.incrementCounter[uint8_t id]() {
    trickles[id].count++;
  }
  task void timerTask() {
    uint8_t i;
    for (i = 0; i < count; i++) {
      bool fire = FALSE;
      atomic {
	if (call Pending.get(i)) {
	  call Pending.clear(i);
	  fire = TRUE;
	}
      }
      if (fire) {
	dbg("Trickle", "Firing trickle timer %hhu @ %s\n", i, sim_time_string());
	signal TrickleTimer.fired[i]();
	post timerTask();
	return;
      }
    }
  }
  event void Timer.fired() {
    uint8_t i;
    uint32_t dt = call Timer.getdt();
    dbg("Trickle", "Trickle Sub-timer fired\n");
    for (i = 0; i < count; i++) {
      uint32_t remaining = trickles[i].time;
      if (remaining != 0) {
	remaining -= dt;
	if (remaining == 0) {
	  if (trickles[i].count < k) {
	    atomic {
	      dbg("Trickle", "Trickle: mark timer %hhi as pending\n", i);
	      call Pending.set(i);
	    }
	    post timerTask();
	  }
	  call Changed.set(i);
	  generateTime(i);
	    
      trickles[i].count = 0;
	}
      }
    }
    adjustTimer();
  }
  void adjustTimer() {
    uint8_t i;
    uint32_t lowest = 0;
    bool set = FALSE;
    uint32_t elapsed = (call Timer.getNow() - call Timer.gett0());
	
    for (i = 0; i < count; i++) {
      uint32_t timeRemaining = trickles[i].time;
      dbg("Trickle", "Adjusting: timer %hhi (%u)\n", i, timeRemaining);
      if (timeRemaining == 0) { // Not running, go to next timer
	continue;
      }
      atomic {
	if (!call Changed.get(i)) {
	  if (timeRemaining > elapsed) {
	    dbg("Trickle", "  not changed, elapse time remaining to %u.\n", trickles[i].time - elapsed);
	    timeRemaining -= elapsed;
	    trickles[i].time -= elapsed;
	  }
	  else { // Time has already passed, so fire immediately
	    dbg("Trickle", "  not changed, ready to elapse, fire immediately\n");
	    timeRemaining = 1;
	    trickles[i].time = 1;
	  }
	}
	else {
	  dbg("Trickle", "  changed, fall through.\n");
	  call Changed.clear(i);
	}
      }
      if (!set) {
	lowest = timeRemaining;
	set = TRUE;
      }
      else if (timeRemaining < lowest) {
	lowest = timeRemaining;
      }
    }
    if (set) {
      uint32_t timerVal = lowest;
      dbg("Trickle", "Starting sub-timer with interval %u.\n", timerVal);
      call Timer.startOneShot(timerVal);
    }
    else {
      call Timer.stop();
    }
  }
  void generateTime(uint8_t id) {
    uint32_t newTime;
    uint16_t rval;
    if (trickles[id].time != 0) {
      trickles[id].period *= 2;
      if (trickles[id].period > high) {
	trickles[id].period = high;
      }
    }
    trickles[id].time = trickles[id].remainder;
    newTime = trickles[id].period;
    newTime = newTime << (scale - 1);
    rval = call Random.rand16() % (trickles[id].period << (scale - 1));
    newTime += rval;
    trickles[id].remainder = (((uint32_t)trickles[id].period) << scale) - newTime;
    trickles[id].time += newTime;
    dbg("Trickle,TrickleTimes", "Generated time for %hhu with period %hu (%u) is %u (%i + %hu)\n", id, trickles[id].period, (uint32_t)trickles[id].period << scale, trickles[id].time, (trickles[id].period << (scale - 1)), rval);
  }
 default event void TrickleTimer.fired[uint8_t id]() {
   return;
 }
}
generic configuration TrickleTimerMilliC(uint16_t low,
					 uint16_t high,
					 uint8_t k,
					 uint8_t count) {
  provides interface TrickleTimer[uint8_t];
}
implementation {
  components new TrickleTimerImplP(low, high, k, count, 10), MainC, RandomC;
  components new TimerMilliC();
  components new BitVectorC(count) as PendingVector;
  components new BitVectorC(count) as ChangeVector;
  components LedsC;
  TrickleTimer = TrickleTimerImplP;
  TrickleTimerImplP.Timer -> TimerMilliC;
  TrickleTimerImplP.Random -> RandomC;
  TrickleTimerImplP.Changed -> ChangeVector;
  TrickleTimerImplP.Pending -> PendingVector;
  TrickleTimerImplP.Leds -> LedsC;
  MainC.SoftwareInit -> TrickleTimerImplP;
}
interface TrickleTimer {
  command error_t start();
  command void stop();
  command void reset();
  command void incrementCounter();
  event void fired();
}
