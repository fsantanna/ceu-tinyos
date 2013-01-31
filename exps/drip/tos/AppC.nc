configuration AppC {}
implementation {
  components MainC;
  C.Boot -> MainC;
  components LedsC;
  C.Leds -> LedsC;
  components new TimerMilliC();
  C.Timer -> TimerMilliC;

  components C;
  components DisseminationC;
  C.DisseminationControl -> DisseminationC;

  components new DisseminatorC(uint16_t, 0x1111) as Diss1;
  C.Value1 -> Diss1;
  C.Update1 -> Diss1;

  components new DisseminatorC(uint16_t, 0x2222) as Diss2;
  C.Value2 -> Diss2;
  C.Update2 -> Diss2;

  components new DisseminatorC(uint16_t, 0x3333) as Diss3;
  C.Value3 -> Diss3;
  C.Update3 -> Diss3;

  components new DisseminatorC(uint16_t, 0x4444) as Diss4;
  C.Value4 -> Diss4;
  C.Update4 -> Diss4;

  components new DisseminatorC(uint16_t, 0x5555) as Diss5;
  C.Value5 -> Diss5;
  C.Update5 -> Diss5;

  components new DisseminatorC(uint16_t, 0x6666) as Diss6;
  C.Value6 -> Diss6;
  C.Update6 -> Diss6;

  components new DisseminatorC(uint16_t, 0x7777) as Diss7;
  C.Value7 -> Diss7;
  C.Update7 -> Diss7;

  components new DisseminatorC(uint16_t, 0x8888) as Diss8;
  C.Value8 -> Diss8;
  C.Update8 -> Diss8;
/*
*/

  components ActiveMessageC;
  C.RadioControl -> ActiveMessageC;

}
