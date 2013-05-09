NESCFILE ?= AppAppC
CEUFILE  ?= samples/blink.ceu

COMPONENT   = $(NESCFILE)
SENSORBOARD = mts300

PFLAGS += -Wno-unused-variable -Wno-unused-label
PFLAGS += -fno-strict-aliasing # required for accessing VARS
PFLAGS += -DCC2420_DEF_RFPOWER=3
PFLAGS += -I%T/lib/net/ctp -I%T/lib/net -I%T/lib/net/4bitle -I%T/lib/net/drip

BUILD_EXTRA_DEPS += ceu

include $(MAKERULES)

ceu:
	@echo "===================================================================="
	ceu $(CEUFILE) --m4 --tp-word 2 --tp-pointer 2 --defs-file _ceu_defs.h
	@echo "===================================================================="

ceu_clean:
	cd simul && make clean
	rm -f _ceu_* *.ceu_m4 samples/*.ceu_m4

.PHONY: ceu ceu_clean
