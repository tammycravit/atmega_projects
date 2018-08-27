###########################################################################
#                         AVR-GCC Generic Makefile                        #
###########################################################################
#     Version 1.10, 2018-08-27, Tammy Cravit, tammycravit@gmail.com       #
###########################################################################

# Target name. Taken from the enclosing directory name if unspecified.
# TARGET =

# Microcontroller type - must match a value from "avrdude -p ?"
MCU   = attiny45

# Microcontroller CPU speed
F_CPU = 1000000UL

# Baud rate for communication
BAUD  = 19200UL

# Processor fuse settings. If you don't override them here, the defaults
# for your MCU type (as specified below - search for !FUSES) will be used
# instead.
#
# LFUSE =
# HFUSE =
# EFUSE =

## A directory for common include files and the simple USART library.
## If you move either the current folder or the Library folder, you'll
##  need to change this path to match.
# LIBRARY_DIR=../library

##########------------------------------------------------------##########
##########                 Programmer Defaults                  ##########
##########          Set up once, then forget about it           ##########
##########------------------------------------------------------##########

# Programmer type - must match a value from "avrdude -c ?"
PROGRAMMER_TYPE = usbtiny

# Extra arguments to avrdude: baud rate, chip type, -F flag, etc.
PROGRAMMER_ARGS =

include ../library/Makefile.mk
