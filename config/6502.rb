##
# Ruby-based DSL for defining behavior for each 6502 Opcode
#   Opcodes are defined in all-caps as "ghost" methods. The behavior of each opcode is defined within the block.
#   Opcodes are mapped to their respective definitions in 6502.csv during the first stage of loading the simulator
#   (See config.rb)

# EA
NOP {} # does nothing

# 00
BRK { raise StopIteration } # halts execution

## Storage

# Load Accumulator (LDA) Addressing Modes: (AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDA { cpu[:a] = mem[e] }

# Load Accumulator (LDX) Addressing Modes: (AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDX { cpu[:x] = mem[e] }

# Load Accumulator (LDY) Addressing Modes: ($AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDY { cpu[:y] = mem[e] }

TXA { cpu[:a] = cpu[:x] }

STA { mem[e] = cpu[:a] }

## Counters

INX { cpu[:x] += 1 }
DEX { cpu[:x] -= 1 }

DEC { cpu.result(mem[e] -= 1) }
INC { cpu.result(mem[e] += 1) }

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

CPX do
  cpu.carry_if(cpu[:x] >= mem[e])

  cpu.result(cpu[:x] - mem[e])
end

CMP do
  cpu.carry_if(cpu[:a] >= mem[e])

  cpu.result(cpu[:a] - mem[e])
end


## Bitwise operations

AND { cpu[:a] &= mem[e] }
BIT { cpu.result(cpu[:a] & mem[e]) }

LSR do
  t = (cpu[:a] >> 1) & 0x7F

  cpu.carry_if(cpu[:a][0] == 1)
  cpu[:a] = t
end

## Arithmetic

SEC { cpu.set_carry }
CLC { cpu.clear_carry }

ADC do
  t = cpu[:a] + mem[e] + cpu[:c]

  cpu.carry_if(t > 0xff)
  cpu[:a] = t
end

SBC do
  t = cpu[:a] - mem[e] - (cpu[:c] == 0 ? 1 : 0)

  cpu.carry_if(t >= 0)
  cpu[:a] = t
end

## Additions (untested):

STY { mem[e] = cpu[:y] }
STX { mem[e] = cpu[:x] }
ASL do
  cpu.carry_if(cpu[:a] > 0x7F)
  cpu[:a] <<= 1
end

BMI { raise NotImplementedError "BMI not yet implemented" }
BVC { raise NotImplementedError "BVC not yet implemented" }
BVS { raise NotImplementedError "BVS not yet implemented" }
CLD { raise NotImplementedError "CLD not yet implemented" }
CLI { raise NotImplementedError "CLI not yet implemented" }
CLV { raise NotImplementedError "CLV not yet implemented" }
DEY { raise NotImplementedError "DEY not yet implemented" }
CMP { raise NotImplementedError "CMP not yet implemented" }
EOR { raise NotImplementedError "EOR not yet implemented" }
ORA { raise NotImplementedError "ORA not yet implemented" }
PHP { raise NotImplementedError "PHP not yet implemented" }
PLP { raise NotImplementedError "PLP not yet implemented" }
ROL { raise NotImplementedError "ROL not yet implemented" }
ROR { raise NotImplementedError "ROR not yet implemented" }
RTI { raise NotImplementedError "RTI not yet implemented" }
SED { raise NotImplementedError "SED not yet implemented" }
SEI { raise NotImplementedError "SEI not yet implemented" }
TAY { raise NotImplementedError "TAY not yet implemented" }
TSX { raise NotImplementedError "TSX not yet implemented" }
TXS { raise NotImplementedError "TXS not yet implemented" }
TYA { raise NotImplementedError "TYA not yet implemented" }
#BNE { raise "BNE not yet implemented" }

RESET { raise NotImplementedError "RESET not yet implemented" }