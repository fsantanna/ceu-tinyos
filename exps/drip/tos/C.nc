#include <Timer.h>

module C {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli>;

  uses interface StdControl as DisseminationControl;
  uses interface DisseminationValue<uint16_t> as Value1;
  uses interface DisseminationUpdate<uint16_t> as Update1;
  uses interface DisseminationValue<uint16_t> as Value2;
  uses interface DisseminationUpdate<uint16_t> as Update2;
  uses interface DisseminationValue<uint16_t> as Value3;
  uses interface DisseminationUpdate<uint16_t> as Update3;
  uses interface DisseminationValue<uint16_t> as Value4;
  uses interface DisseminationUpdate<uint16_t> as Update4;
  uses interface DisseminationValue<uint16_t> as Value5;
  uses interface DisseminationUpdate<uint16_t> as Update5;
  uses interface DisseminationValue<uint16_t> as Value6;
  uses interface DisseminationUpdate<uint16_t> as Update6;
  uses interface DisseminationValue<uint16_t> as Value7;
  uses interface DisseminationUpdate<uint16_t> as Update7;
  uses interface DisseminationValue<uint16_t> as Value8;
  uses interface DisseminationUpdate<uint16_t> as Update8;
/*
*/

  uses interface SplitControl as RadioControl;
}

implementation {
  uint16_t counter1;
  uint16_t counter2;
  uint16_t counter3;
  uint16_t counter4;
  uint16_t counter5;
  uint16_t counter6;
  uint16_t counter7;
  uint16_t counter8;

  event void Timer.fired() {
    if ( TOS_NODE_ID  == 1 ) {
      counter1 = counter1 + 1;
      call Update1.change(&counter1);
      counter2 = counter2 + 1;
      call Update2.change(&counter2);
      counter3 = counter3 + 1;
      call Update3.change(&counter3);
      counter4 = counter4 + 1;
      call Update4.change(&counter4);
      counter5 = counter5 + 1;
      call Update5.change(&counter5);
      counter6 = counter6 + 1;
      call Update6.change(&counter6);
      counter7 = counter7 + 1;
      call Update7.change(&counter7);
      counter8 = counter8 + 1;
      call Update4.change(&counter8);
/*
*/
    }
  }

  event void Value1.changed() {
    const uint16_t* newVal = call Value1.get();
      counter1 = *newVal;
      //dbg("C", "1 = %d\n", counter2);
  }

  event void Value2.changed() {
    const uint16_t* newVal = call Value2.get();
      counter2 = *newVal;
      //dbg("C", "2 = %d\n", counter2);
  }

  event void Value3.changed() {
    const uint16_t* newVal = call Value3.get();
      counter3 = *newVal;
      //dbg("C", "3 = %d\n", counter3);
  }

  event void Value4.changed() {
    const uint16_t* newVal = call Value4.get();
      counter4 = *newVal;
      //dbg("C", "4 = %d\n", counter4);
  }

  event void Value5.changed() {
    const uint16_t* newVal = call Value5.get();
      counter5 = *newVal;
      //dbg("C", "5 = %d\n", counter5);
  }

  event void Value6.changed() {
    const uint16_t* newVal = call Value6.get();
      counter6 = *newVal;
      //dbg("C", "6 = %d\n", counter6);
  }

  event void Value7.changed() {
    const uint16_t* newVal = call Value7.get();
      counter7 = *newVal;
      //dbg("C", "7 = %d\n", counter7);
  }

  event void Value8.changed() {
    const uint16_t* newVal = call Value8.get();
      counter8 = *newVal;
      //dbg("C", "8 = %d\n", counter8);
  }

/*
*/

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS) 
      call RadioControl.start();
    else {
      call DisseminationControl.start();
      counter1 = 0;
      counter2 = 0;
      counter3 = 0;
      counter4 = 0;
      counter5 = 0;
      counter6 = 0;
      counter7 = 0;
      counter8 = 0;
      if ( TOS_NODE_ID  == 1 ) 
        call Timer.startPeriodic(2000);
    }
  }

  event void RadioControl.stopDone(error_t er) {}

}
