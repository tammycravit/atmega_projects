###########################################################################
#                         AVR-GCC Generic Makefile                        #
###########################################################################
#     Version 1.10, 2018-08-27, Tammy Cravit, tammycravit@gmail.com       #
###########################################################################

#==========================================================================
# This Makefile is based upon the generic AVR-GCC Makefile from Elliot
# Williams (https://bit.ly/2wuYQTz). I've modified it for my needs as
# follows:
#
# 1. It now looks for the newer AVR-GCC toolchain from Zak Kemble's blog
#    (http://blog.zakkemble.co.uk/avr-gcc-builds/) in /opt (on Linux) or
#    c:\AVR-GCC (on Windows) and uses it if present.
#
# 2. It checks if LIBDIR exists, and skips it if not.
#
# 3. It allows default HFUSE/LFUSE/EFUSE settings for different MCUs, and
#    also allows them to be overridden in the project-specific section.
#
# 4. It provides an "erase" target to erase the memory of the MCU.
#
# 5. It provides more detailed and pretty "make debug" output.
#
# 6. Moved some plumbing below the "you should not have to edit below this
#    point" line.
#
# 7. Refactored the guts out into an include file, so you can override
#    stuff here.
#==========================================================================
# The project-specific Makefile template is in Makefile.template in this 
# directory.  This Makefile is intended to be included by that file, and 
# contains all the "plumbing" bits.
#
# You should not run this Makefile directly.
#==========================================================================

##########------------------------------------------------------##########
##########                  Program Locations                   ##########
##########------------------------------------------------------##########

# Use newer AVR toolchain from http://blog.zakkemble.co.uk/avr-gcc-builds/
# if present
AVR_TOOLCHAIN_VERSION = 8.1.0

ifeq ($(shell test -d /opt/avr-gcc-$(AVR_TOOLCHAIN_VERSION)-x64-linux && echo -n yes),yes)
	TOOLCHAIN_PREFIX = /opt/avr-gcc-$(AVR_TOOLCHAIN_VERSION)-x64-linux/bin/
else
ifeq ($(shell test -d /c/avr-gcc-$(AVR_TOOLCHAIN_VERSION) && echo -n yes),yes)
	TOOLCHAIN_PREFIX = /c/avr-gcc-$(AVR_TOOLCHAIN_VERSION)/bin/
else
	TOOLCHAIN_PREFIX =
endif
endif

CC      = $(TOOLCHAIN_PREFIX)avr-gcc
OBJCOPY = $(TOOLCHAIN_PREFIX)avr-objcopy
OBJDUMP = $(TOOLCHAIN_PREFIX)avr-objdump
AVRSIZE = $(TOOLCHAIN_PREFIX)avr-size
ifeq ($(shell test -x $(TOOLCHAIN_PREFIX)avrdude && echo -n yes),yes)
	AVRDUDE = $(TOOLCHAIN_PREFIX)avrdude
else
	AVRDUDE = avrdude
endif

##########------------------------------------------------------##########
##########                   Makefile Magic!                    ##########
##########         Summary:                                     ##########
##########             We want a .hex file                      ##########
##########        Compile source files into .elf                ##########
##########        Convert .elf file into .hex                   ##########
##########        You shouldn't need to edit below.             ##########
##########------------------------------------------------------##########

LIBRARY_DIR ?= ../library
ifeq ($(shell test -d $(LIBRARY_DIR) && echo -n yes),yes)
	LIBDIR = $(LIBRARY_DIR)
else
	LIBDIR =
endif

## Target should be named automatically after the enclosing directory, but you
## can override above.
TARGET ?= $(lastword $(subst /, ,$(CURDIR)))

# Object files: will find all .c/.h files in current directory
#  and in LIBDIR.  If you have any other (sub-)directories with code,
#  you can add them in to SOURCES below in the wildcard statement.
SOURCES=$(wildcard *.c $(LIBDIR)/*.c)
OBJECTS=$(SOURCES:.c=.o)
HEADERS=$(SOURCES:.c=.h)

## Compilation options, type man avr-gcc if you're curious.
CPPFLAGS = -DF_CPU=$(F_CPU) -DBAUD=$(BAUD) -I. -I$(LIBDIR)
CFLAGS = -Os -g -std=gnu99 -Wall
## Use short (8-bit) data types
CFLAGS += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
## Splits up object files per function
CFLAGS += -ffunction-sections -fdata-sections
LDFLAGS = -Wl,-Map,$(TARGET).map
## Optional, but often ends up with smaller code
LDFLAGS += -Wl,--gc-sections
## Relax shrinks code even more, but makes disassembly messy
## LDFLAGS += -Wl,--relax
## LDFLAGS += -Wl,-u,vfprintf -lprintf_flt -lm  ## for floating-point printf
## LDFLAGS += -Wl,-u,vfprintf -lprintf_min      ## for smaller printf
TARGET_ARCH = -mmcu=$(MCU)

## Explicit pattern rules:
##  To make .o files from .c files
%.o: %.c $(HEADERS) Makefile
	 $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c -o $@ $<;

$(TARGET).elf: $(OBJECTS)
	$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LDLIBS) -o $@

%.hex: %.elf
	 $(OBJCOPY) -j .text -j .data -O ihex $< $@

%.eeprom: %.elf
	$(OBJCOPY) -j .eeprom --change-section-lma .eeprom=0 -O ihex $< $@

%.lst: %.elf
	$(OBJDUMP) -S $< > $@

## These targets don't have files named after them
.PHONY: all disassemble disasm eeprom size clean squeaky_clean flash fuses

all: $(TARGET).hex

# Optionally create listing file from .elf
# This creates approximate assembly-language equivalent of your code.
# Useful for debugging time-sensitive bits,
# or making sure the compiler does what you want.
disassemble: $(TARGET).lst

disasm: disassemble

# Optionally show how big the resulting program is
size:  $(TARGET).elf
	$(AVRSIZE) -C --mcu=$(MCU) $(TARGET).elf

clean:
	rm -f $(TARGET).elf $(TARGET).hex $(TARGET).obj \
	$(TARGET).o $(TARGET).d $(TARGET).eep $(TARGET).lst \
	$(TARGET).lss $(TARGET).sym $(TARGET).map $(TARGET)~ \
	$(TARGET).eeprom

squeaky_clean:
	rm -f *.elf *.hex *.obj *.o *.d *.eep *.lst *.lss *.sym *.map *~ *.eeprom

##########------------------------------------------------------##########
##########              Programmer-specific details             ##########
##########           Flashing code to AVR using avrdude         ##########
##########------------------------------------------------------##########

flash: $(TARGET).hex
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU) $(PROGRAMMER_ARGS) -U flash:w:$<

## An alias
program: flash

flash_eeprom: $(TARGET).eeprom
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU) $(PROGRAMMER_ARGS) -U eeprom:w:$<

erase:
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU) $(PROGRAMMER_ARGS) -e

avrdude_terminal:
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU) $(PROGRAMMER_ARGS) -nt

## If you've got multiple programmers that you use,
## you can define them here so that it's easy to switch.
## To invoke, use something like `make flash_arduinoISP`
flash_usbtiny: PROGRAMMER_TYPE = usbtiny
flash_usbtiny: PROGRAMMER_ARGS =  # USBTiny works with no further arguments
flash_usbtiny: flash

flash_usbasp: PROGRAMMER_TYPE = usbasp
flash_usbasp: PROGRAMMER_ARGS =  # USBasp works with no further arguments
flash_usbasp: flash

flash_arduinoISP: PROGRAMMER_TYPE = avrisp
flash_arduinoISP: PROGRAMMER_ARGS = -b 19200 -P /dev/ttyACM0
## (for windows) flash_arduinoISP: PROGRAMMER_ARGS = -b 19200 -P com5
flash_arduinoISP: flash

flash_109: PROGRAMMER_TYPE = avr109
flash_109: PROGRAMMER_ARGS = -b 9600 -P /dev/ttyUSB0
flash_109: flash

##########------------------------------------------------------##########
##########       Fuse settings and suitable defaults            ##########
##########------------------------------------------------------##########

#!FUSES
# Add additional conditionals if need be. You can override by setting
# these values above if need be. Atmel fuse calculator can be found at
# http://www.engbedded.com/fusecalc/

LFUSE_DEFAULT = 0x62
HFUSE_DEFAULT = 0xdf
EFUSE_DEFAULT = 0x00

ifeq ($(MCU),attiny45)
	LFUSE ?= 0x62
	HFUSE ?= 0xdf
	EFUSE ?= 0xfe
else ifeq ($(MCU),attiny2313a)
	LFUSE ?= 0x64
	HFUSE ?= 0xdf
	EFUSE ?= 0xfe
else
	LFUSE ?= LFUSE_DEFAULT
	HFUSE ?= HFUSE_DEFAULT
	EFUSE ?= EFUSE_DEFAULT
endif

## Generic
FUSE_STRING = -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m

fuses:
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU) \
	           $(PROGRAMMER_ARGS) $(FUSE_STRING)
show_fuses:
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU) $(PROGRAMMER_ARGS) -nv

## Called with no extra definitions, sets to defaults
set_default_fuses:  FUSE_STRING = -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m
set_default_fuses:  fuses

## Set the fuse byte for full-speed mode
## Note: can also be set in firmware for modern chips
set_fast_fuse: LFUSE = 0xE2
set_fast_fuse: FUSE_STRING = -U lfuse:w:$(LFUSE):m
set_fast_fuse: fuses

## Set the EESAVE fuse byte to preserve EEPROM across flashes
set_eeprom_save_fuse: HFUSE = 0xD7
set_eeprom_save_fuse: FUSE_STRING = -U hfuse:w:$(HFUSE):m
set_eeprom_save_fuse: fuses

## Clear the EESAVE fuse byte
clear_eeprom_save_fuse: FUSE_STRING = -U hfuse:w:$(HFUSE):m
clear_eeprom_save_fuse: fuses

## Display debugging information
debug:
	@echo "============================================================================"
	@echo "=                       Project Debugging Information                      ="
	@echo "============================================================================"
	@echo ""
	@echo "Project name : " $(TARGET)
	@echo "Source files : " $(SOURCES)
	@echo "LIBRARY_DIR  : " $(LIBRARY_DIR)
	@echo ""
	@echo "----| Microcontroller Settings |-------------------------------------------"
	@echo ""
	@echo "MCU   : " $(MCU)
	@echo "F_CPU : " $(F_CPU)
	@echo "BAUD  : " $(BAUD)
	@echo ""
	@echo "----| Microcontroller fuse settings |--------------------------------------"
	@echo ""
	@echo "LFUSE : " $(LFUSE)
	@echo "HFUSE : " $(HFUSE)
	@echo "EFUSE : " $(EFUSE)
	@echo ""
	@echo "----| Programmer Settings |------------------------------------------------"
	@echo ""
	@echo "Type  : " $(PROGRAMMER_TYPE)
	@echo "Args  : " $(PROGRAMMER_ARGS)
	@echo "============================================================================"
	@echo

