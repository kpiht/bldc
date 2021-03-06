PROJ_NAME=bldc

# Path to dependencies.
LIBS_DIR=./libs

# Path to LIBC.
LIBC_DIR=$(LIBS_DIR)
# LIBC_PATH=$(LIBC_DIR)/buildresults/src

# Path to uCmd.
UCMD_DIR=$(LIBS_DIR)/ucmd

# Link to ST Drivers. Using version 1.10.0
STM_DIR=$(LIBS_DIR)/STM32CubeF3
STM_SRC+=$(STM_DIR)/Drivers/STM32F3xx_HAL_Driver/Src

# Link to FreeRTOS. Using version 10.2.1
RTOS_DIR=$(LIBS_DIR)/FreeRTOS

SRCS=hw/src/main.c
SRCS+=hw/src/stm32f3xx_it.c
SRCS+=hw/src/adc.c
SRCS+=hw/src/gpio.c
SRCS+=hw/src/pwm.c
SRCS+=hw/src/uart.c
SRCS+=hw/src/tmr.c
SRCS+=hw/src/enc.c
SRCS+=app/src/tasks.c
SRCS+=app/src/app.c
SRCS+=app/src/mtrif.c
SRCS+=app/src/command.c
SRCS+=system/src/system_stm32f3xx.c
SRCS+=$(STM_DIR)/Drivers/CMSIS/Device/ST/STM32F3xx/Source/Templates/gcc/startup_stm32f302x8.s
SRCS+=$(STM_SRC)/stm32f3xx_hal_gpio.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_rcc.c
SRCS+=$(STM_SRC)/stm32f3xx_hal.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_cortex.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_adc.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_adc_ex.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_dma.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_rcc_ex.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_cortex.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_tim.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_tim_ex.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_uart.c
SRCS+=$(STM_SRC)/stm32f3xx_hal_uart_ex.c

# This is the location for printf.c file implementation from Embdedded Artistry.
SRCS+=$(LIBC_DIR)/printf/printf.c

# Location for command utility.
SRCS+=$(UCMD_DIR)/ucmd.c
SRCS+=$(UCMD_DIR)/line.c
SRCS+=$(UCMD_DIR)/err.c
SRCS+=$(UCMD_DIR)/utils.c

# This is the location of port.c file.
SRCS+=$(RTOS_DIR)/FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c
SRCS+=$(RTOS_DIR)/FreeRTOS/Source/portable/MemMang/heap_2.c

# This is where the actual implementation of FreeRTOS is.
SRCS+=$(RTOS_DIR)/FreeRTOS/Source/tasks.c
SRCS+=$(RTOS_DIR)/FreeRTOS/Source/timers.c
SRCS+=$(RTOS_DIR)/FreeRTOS/Source/queue.c
SRCS+=$(RTOS_DIR)/FreeRTOS/Source/list.c
SRCS+=$(RTOS_DIR)/FreeRTOS/Source/stream_buffer.c

# Drivers section.
INC_DIRS=$(STM_DIR)/Drivers/CMSIS/Device/ST/STM32F3xx/Include
INC_DIRS+=$(STM_DIR)/Drivers/STM32F3xx_HAL_Driver/Inc
INC_DIRS+=$(STM_DIR)/Drivers/CMSIS/Include
INC_DIRS+=$(RTOS_DIR)/FreeRTOS/Source/include
INC_DIRS+=$(RTOS_DIR)/FreeRTOS/Source/portable/GCC/ARM_CM4F

#uCmd section.
INC_DIRS+=$(UCMD_DIR)

#Libc section.
INC_DIRS+=$(LIBC_DIR)/printf

# Project section.
INC_DIRS+=./system/inc
INC_DIRS+=./hw/inc
INC_DIRS+=./app/inc
INC_DIRS+=.

ST_LINK_DIR=~/opt/stlink/build/Release/bin

TOOLS_DIR=~/opt/gcc-arm-none-eabi-9-2020-q2/bin
CC=$(TOOLS_DIR)/arm-none-eabi-gcc
OBJCOPY=$(TOOLS_DIR)/arm-none-eabi-objcopy
OBJDUMP=$(TOOLS_DIR)/arm-none-eabi-objdump
# GDB=$(TOOLS_DIR)/arm-none-eabi-gdb
GDB=arm-none-eabi-gdb
SZ=$(TOOLS_DIR)/arm-none-eabi-size
BUILD_DIR=./build

# Any compiler options you need to set
CFLAGS=-ggdb3
CFLAGS+=-Og -gdwarf-5
CFLAGS+=-Wall -Wextra -Warray-bounds
CFLAGS+=-mlittle-endian -mcpu=cortex-m4
CFLAGS+=-mthumb-interwork -mthumb
CFLAGS+=-mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant
# CFLAGS+=--specs=nosys.specs --specs=rdimon.specs
CFLAGS+=-ffunction-sections -fdata-sections -fno-math-errno

# Linker Files (all *.ld files)
LFLAGS=-Wl,-Map,$(BUILD_DIR)/$(PROJ_NAME).map -Wl,--gc-sections -T./linker/stm32f30_flash.ld

INCLUDE = $(addprefix -I,$(INC_DIRS))

DEFS=-DSTM32F302x8
DEFS+=-D__DBG__
DEFS+=-D__SLOG__

.PHONY: $(PROJ_NAME)
$(PROJ_NAME): $(PROJ_NAME).elf

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

$(PROJ_NAME).elf: $(SRCS)
	mkdir -p $(BUILD_DIR)
	$(CC) $(INCLUDE) $(DEFS) $(CFLAGS) $(LFLAGS) $^ -o $(BUILD_DIR)/$@
	$(OBJCOPY) -O ihex $(BUILD_DIR)/$(PROJ_NAME).elf   $(BUILD_DIR)/$(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(BUILD_DIR)/$(PROJ_NAME).elf $(BUILD_DIR)/$(PROJ_NAME).bin
	$(SZ) $(BUILD_DIR)/$(PROJ_NAME).elf

dump:
	$(OBJDUMP) -D --source $(BUILD_DIR)/$(PROJ_NAME).elf > $(BUILD_DIR)/$(PROJ_NAME).dump
	
clean:
	rm -f *.o $(BUILD_DIR)/$(PROJ_NAME).elf $(BUILD_DIR)/$(PROJ_NAME).hex $(BUILD_DIR)/$(PROJ_NAME).bin $(BUILD_DIR)/$(PROJ_NAME).map $(BUILD_DIR)/$(PROJ_NAME).dump

flash:
	$(ST_LINK_DIR)/st-flash write $(BUILD_DIR)/$(PROJ_NAME).bin 0x8000000

stlink:
	$(ST_LINK_DIR)/st-util -p4242

all:
	make clean && make && make flash

# before you start gdb, you must start st-util
.PHONY: debug
debug:
	$(ST_LINK_DIR)/st-util &
	$(GDB) $(BUILD_DIR)/$(PROJ_NAME).elf --command=./debug/cmd.gdb
	killall st-util
