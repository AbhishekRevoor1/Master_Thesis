# ======================================================================
#  rv64Sim / Makefile (C + startup)
#  • compile  .c    →  .o
#  • assemble .s    →  .o
#  • link     .o    →  .elf
#  • objcopy  .elf  →  .v (Verilog hex) + .mem
# ======================================================================

.SUFFIXES:

# ----------- Toolchain ------------------------------------------------
CC      := riscv64-unknown-elf-gcc
AS      := riscv64-unknown-elf-gcc
CP      := riscv64-unknown-elf-objcopy

# ----------- Flags ----------------------------------------------------
CFLAGS  := -march=rv64izicsr -mabi=lp64 -nostdlib -ffreestanding -O2 -g -msmall-data-limit=0
ASFLAGS := $(CFLAGS)
LDFLAGS := -T linker.ld -nostdlib -ffreestanding -march=rv64izicsr -mabi=lp64
CPFLAGS := -O verilog --verilog-data-width 4

# ----------- File Names & Paths ---------------------------------------
TARGET      ?= main                     # make TARGET=foo
SRC_C       := $(TARGET).c
SRC_S       := crt0.s
OBJS        := $(SRC_C:.c=.o) $(SRC_S:.s=.o)
ELF         := $(TARGET).elf
VERILOG     := $(TARGET).v

# ----------- Simulation Output ----------------------------------------
SIMDIR      := ../sim
SIMMEM1     := riscvtest.mem
SIMMEM2     := riscvtest_tb_$(TARGET).mem


# ----------- Default Goal ---------------------------------------------
.DEFAULT_GOAL := $(TARGET)

# ======================================================================
#  Pattern Rules
# ======================================================================

# ---------- 1.  .c → .o ----------
%.o: %.c
	@echo "[CC] Compiling $<"
	$(CC) $(CFLAGS) -c $< -o $@

# ---------- 2.  .s → .o ----------
%.o: %.s
	@echo "[AS] Assembling $<"
	$(AS) $(ASFLAGS) -c $< -o $@

# ---------- 3.  .o → .elf ----------
%.elf: $(OBJS) linker.ld
	@echo "[LD] Linking $@"
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

# ---------- 4.  .elf → .v ----------
%.v: %.elf
	@echo "[CP] Converting $< to $@"
	$(CP) $< $(CPFLAGS) $@
	sed -i 's/ /\n/g' $@
	sed -i 's/\r//g'  $@
	sed -i '1d'       $@
	cp -f $@ $(SIMDIR)/$(SIMMEM1)
	cp -f $@ $(SIMDIR)/$(SIMMEM2)

# ---------- 5.  Full chain ----------
$(TARGET): $(VERILOG)

# ---------- 6.  Clean ----------
.PHONY: clean
clean:
	@echo "[RM] Cleaning build files"
	rm -f *.o *.elf *.v
	rm -f $(TARGET).s

# ---------- 7.  Keep intermediate ----------
.PRECIOUS: %.elf %.o
