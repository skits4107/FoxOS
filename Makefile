
CC = aarch64-linux-gnu-gcc

AS  = aarch64-linux-gnu-gcc 

LINKER_SCRIPT = linker.ld

CCFLAGS = -Wall -O2 -ffreestanding -nostdlib -mgeneral-regs-only -mstrict-align \
          -fno-pie -fno-stack-protector -fno-asynchronous-unwind-tables
ASFLAGS  = -c

LDFLAGS = -T $(LINKER_SCRIPT) -nostdlib -static -no-pie \
          -Wl,-n -Wl,--gc-sections -Wl,--build-id=none
LDLIBS  = 

TARGET = kernel8.img
OBJS = boot.o exception_vectors.o handle_exceptions.o kernel_main.o

all: $(TARGET)

# The Linking Step
OBJCOPY = aarch64-linux-gnu-objcopy

$(TARGET): $(OBJS) $(LINKER_SCRIPT)
	$(CC) $(LDFLAGS) $(OBJS) $(LDLIBS) -o kernel8.elf
	$(OBJCOPY) -O binary kernel8.elf $(TARGET)

# Assembly Compilation (Using GCC with -c flag)
boot.o: boot.S
	$(AS) $(ASFLAGS) boot.S -o boot.o

exception_vectors.o: exception_vectors.S
	$(AS) $(ASFLAGS) exception_vectors.S -o exception_vectors.o

# C Compilation
handle_exceptions.o: handle_exceptions.c
	$(CC) $(CCFLAGS) -c handle_exceptions.c -o handle_exceptions.o

kernel_main.o: kernel_main.c
	$(CC) $(CCFLAGS) -c kernel_main.c -o kernel_main.o


.PHONY: clean
clean:
	rm -f *.o $(TARGET)