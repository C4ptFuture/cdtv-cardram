#
#   Note:
#	Set VERSION and REVISION numbers in VERSION file. The date and version string for the
#   reisdent module will be automatically generated.
#
#    Build <projectname>:
#		ENVIRONMENT=internal make <projectname>
#		ENVIRONMENT=release make <projectname>
#
#
#
PROJECT=cardram
VASM=vasmm68k_mot
VLINK=vlink -s
INCLUDE=include_i
SRC=src/$(PROJECT)
BUILD=build/$(PROJECT)
LIB=-Llib
AFLAGS=-DVERSION=$(VERSION) -DREVISION=$(REVISION) -m68000 -kick1hunks -Fhunk
GITHASH := $(shell git rev-parse --short HEAD)
DATESTRING := $(shell date +'%Y%m%d')
DATESTRING_COMMODORE := $(shell date +'%-d.%-m.%y')
VERSION = $(shell grep VERSION VERSION|cut -d= -f2)
REVISION = $(shell grep REVISION VERSION|cut -d= -f2)


.PHONY: clean deps builddir check-env

cardram: deps
	@echo "\n\n\n====== [ Build for CD1401 ] =========================================================\n"
	$(VASM) -DCD1401 -D$(ENVIRONMENT) $(AFLAGS) -I$(INCLUDE) $(SRC)/$(PROJECT).asm -o $(BUILD)/$(PROJECT)-$(VERSION).$(REVISION)-CD1401-$(ENVIRONMENT).o


	@echo "\n\n\n====== [ Link for CD1401 ] ==========================================================\n"
	$(VLINK) -bamigahunk ${LIB} -lamiga -Bstatic $(BUILD)/$(PROJECT)-$(VERSION).$(REVISION)-CD1401-$(ENVIRONMENT).o -o $(BUILD)/$(PROJECT)-$(VERSION).$(REVISION)-CD1401-$(ENVIRONMENT).ld


# build dependencies
deps: check-env createrev builddir

# make sure all required env vars are set
check-env:
ifndef VERSION
	$(error VERSION is undefined)
endif
ifndef REVISION
	$(error REVISION is undefined)
endif
ifndef ENVIRONMENT
	$(error ENVIRONMENT is undefined)
endif

# makes sure build dir exists
builddir:
	mkdir -p build/$(PROJECT)

# creates the version string include according to Commodore conventions
createrev:
	@echo "\n====== [ Create revision ] "
	@echo "VSTRING	MACRO" > $(SRC)/rev.i
	@echo "  dc.b   '$(PROJECT) $(VERSION).$(REVISION) ($(DATESTRING_COMMODORE))',13,10,0" >> $(SRC)/rev.i
	@echo "  CNOP   0,2" >> $(SRC)/rev.i
	@echo "  ENDM" >> $(SRC)/rev.i

# delete all build artifacts
clean:
	find $(BUILD) -name "*.o" -exec rm {} \;
	find $(BUILD) -name "*.ld" -exec rm {} \;
