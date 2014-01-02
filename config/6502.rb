##
# Ruby-based DSL for defining behavior for each 6502 Opcode
#   Opcodes are defined in all-caps as "ghost" methods. The behavior of each opcode is defined within the block.
#   Opcodes are mapped to their respective definitions in 6502.csv during the first stage of loading the simulator
#   (See config.rb)

# EA
NOP {} # does nothing

# 00
BRK(:b) { raise StopIteration } # halts execution

## Storage

# Load Accumulator (LDA) Addressing Modes: (AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDA(:n, :v) { cpu[:a] = mem[e] }

# Load Accumulator (LDX) Addressing Modes: (AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDX(:n, :v) { cpu[:x] = mem[e] }

# Load Accumulator (LDY) Addressing Modes: ($AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDY(:n, :v) { cpu[:y] = mem[e] }

TXA(:n, :v) { cpu[:a] = cpu[:x] }

STA { mem[e] = cpu[:a] }

## Counters

# Overflow, zero, signed?
INX(:n, :z) { cpu[:x] += 1 }
DEX(:n, :z) { cpu[:x] -= 1 }

DEC(:n, :z) { cpu.result(mem[e] -= 1) }
INC(:n, :z) { cpu.result(mem[e] += 1) }

## Flow control

JMP { mem.jump(e) }

JSR { mem.jsr(e) }
RTS { mem.rts }

BNE { mem.branch(cpu[:z] == 0, e) }
BEQ { mem.branch(cpu[:z] == 1, e) }
BPL { mem.branch(cpu[:n] == 0, e) }
BCS { mem.branch(cpu[:c] == 1, e) }
BCC { mem.branch(cpu[:c] == 0, e) }

## Comparisons

CPX(:n, :z, :c) do
  cpu.carry_if(cpu[:x] >= mem[e])

  cpu.result(cpu[:x] - mem[e])
end

CMP(:n, :z, :c) do
  cpu.carry_if(cpu[:a] >= mem[e])

  cpu.result(cpu[:a] - mem[e])
end


## Bitwise operations

AND(:n, :z) { cpu[:a] &= mem[e] }
BIT(:n, :v, :z) { cpu.result(cpu[:a] & mem[e]) }

LSR(:n, :z, :c) do
  t = (cpu[:a] >> 1) & 0x7F

  cpu.carry_if(cpu[:a][0] == 1)
  cpu[:a] = t
end

## Arithmetic

SEC { cpu.set_carry }
CLC { cpu.clear_carry }

ADC(:n, :v, :z, :c) do
  t = cpu[:a] + mem[e] + cpu[:c]

  cpu.carry_if(t > 0xff)
  cpu[:a] = t
end

SBC(:n, :v, :z, :c) do
  t = cpu[:a] - mem[e] - (cpu[:c] == 0 ? 1 : 0)

  cpu.carry_if(t >= 0)
  cpu[:a] = t
end

## Additions (untested):

STY { mem[e] = cpu[:y] }

STX { mem[e] = cpu[:x] }

ASL(:n, :z, :c) do
  cpu.carry_if(cpu[:a] > 0x7F)
  cpu[:a] <<= 1
end

BPL { mem.branch(cpu[:n] == 1, e) }
BVC { mem.branch(cpu[:v] == 0, e) }
BVS { mem.branch(cpu[:v] == 1, e) }

CLD { raise NotImplementedError "CLD not yet implemented" }

CLI { cpu.clear_interrupt }
CLV { cpu.clear_overflow }

DEY(:n, :z) { cpu[:y] -= 1 }

#CMP { raise NotImplementedError "CMP not yet implemented" }
EOR(:n, :z) { raise NotImplementedError "EOR not yet implemented" }
ORA(:n, :z) { raise NotImplementedError "ORA not yet implemented" }
PHP { raise NotImplementedError "PHP not yet implemented" }
PLP { raise NotImplementedError "PLP not yet implemented" }
ROL(:n, :z, :c) { raise NotImplementedError "ROL not yet implemented" }
ROR(:n, :z, :c) { raise NotImplementedError "ROR not yet implemented" }
RTI { raise NotImplementedError "RTI not yet implemented" }
SED { raise NotImplementedError "SED not yet implemented" }
SEI { raise NotImplementedError "SEI not yet implemented" }
TAY(:n, :z) { raise NotImplementedError "TAY not yet implemented" }
TSX(:n, :z) { raise NotImplementedError "TSX not yet implemented" }
TXS(:n, :z) { raise NotImplementedError "TXS not yet implemented" }
TYA(:n, :z) { raise NotImplementedError "TYA not yet implemented" }
#BNE { raise "BNE not yet implemented" }

RESET { raise NotImplementedError "RESET not yet implemented" }
