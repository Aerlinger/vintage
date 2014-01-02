##
# Ruby-based DSL for defining behavior for each 6502 Opcode
#   Opcodes are defined in all-caps as "ghost" methods. The behavior of each opcode is defined within the block.
#   Opcodes are mapped to their respective definitions in 6502.csv during the first stage of loading the simulator
#   (See config.rb)

# EA
NOP {} # does nothing

# 00
BRK(:b) {
  raise StopIteration
} # halts execution

## Storage

# Load Accumulator (LDA) Addressing Modes: (AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDA(:n, :v) { cpu[:a] = mem[e] }

# Load X Register (LDX) Addressing Modes: (AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDX(:n, :v) { cpu[:x] = mem[e] }

# Load Y register (LDY) Addressing Modes: ($AD => AB, BD => AX, B9 => AY, IM, ZP, ZX, IX, IY)
LDY(:n, :v) { cpu[:y] = mem[e] }

TXA(:n, :v) { cpu[:a] = cpu[:x] }
TYA(:n, :z) { cpu[:a] = cpu[:y] }
TAX(:n, :z) { cpu[:x] = cpu[:a] }
TAY(:n, :z) { cpu[:y] = cpu[:a] }
TSX(:n, :z) { cpu[:x] = mem.get_stack }
TXS(:n, :z) { mem.set_stack(cpu[:x])  }

STA { mem[e] = cpu[:a] }

PLA { cpu[:a] = mem.pull }
PHA { mem.push cpu[:a] }

## Counters

# Overflow?
INX(:n, :z) { cpu[:x] += 1 }
DEX(:n, :z) { cpu[:x] -= 1 }

DEC(:n, :z) { cpu.result(mem[e] -= 1) }
INC(:n, :z) { cpu.result(mem[e] += 1) }

INY(:n, :z) { cpu[:y] += 1 }
DEY(:n, :z) { cpu[:y] -= 1 }

## Flow control

JMP { mem.jump(e) }
JSR { mem.jsr(e) }
RTS { mem.rts }

BNE { mem.branch(cpu[:z] == 0, e) }
BEQ { mem.branch(cpu[:z] == 1, e) }
BPL { mem.branch(cpu[:n] == 0, e) }
BMI { mem.branch(cpu[:n] == 1, e) }
BCS { mem.branch(cpu[:c] == 1, e) }
BCC { mem.branch(cpu[:c] == 0, e) }
BVS { mem.branch(cpu[:v] == 1, e) }
BVC { mem.branch(cpu[:v] == 0, e) }


## Comparisons

CPX(:n, :z, :c) do
  cpu.carry_if(cpu[:x] >= mem[e])

  cpu.result(cpu[:x] - mem[e])
end

CPY(:n, :z, :c) do
  cpu.carry_if(cpu[:y] >= mem[e])

  cpu.result(cpu[:y] - mem[e])
end

CMP(:n, :z, :c) do
  cpu.carry_if(cpu[:a] >= mem[e])

  cpu.result(cpu[:a] - mem[e])
end


## Bitwise operations

AND(:n, :z) { cpu[:a] &= mem[e] }
EOR(:n, :z) { cpu[:a] ^= mem[e] }
ORA(:n, :z) { cpu[:a] |= mem[e] }
BIT(:n, :v, :z) { cpu.result(cpu[:a] & mem[e]) }

ASL(:n, :z, :c) do
  cpu.carry_if(cpu[:a] > 0x7F)
  cpu[:a] <<= 1
end

LSR(:n, :z, :c) do
  t = (cpu[:a] >> 1) & 0x7F

  cpu.carry_if(cpu[:a][0] == 1)
  cpu[:a] = t
end

# Todo, what about accumulator addressing mode?
ROL(:n, :z, :c) do
  t = cpu[:a]
  cpu[:a] <<= 1
  cpu[:a] += cpu[:c]
  cpu.carry_if(t > 0x7f)
end

# Todo, what about accumulator addressing mode?
ROR(:n, :z, :c) do
  t = cpu[:a]
  cpu[:a] >>= 1
  cpu[:a] += cpu[:c] * 128
  cpu.carry_if(t.odd?)
end

## Arithmetic

SEC { cpu.set_carry }
SEI { cpu.set_interrupt }
CLC { cpu.clear_carry }
CLI { cpu.clear_interrupt }
CLV { cpu.clear_overflow }

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

STX { mem[e] = cpu[:x] }
STY { mem[e] = cpu[:y] }


PHP { mem.push cpu.get_flag_mask }
PLP { cpu.set_status mem.pull  }

RTI do
  mem.set_status mem.pull
  mem.jump(mem.int16([mem.pull, mem.pull]))
end

SED { raise NotImplementedError "SED (Decimal mode) not yet implemented" }
CLD { raise NotImplementedError "CLD (Decimal mode) not yet implemented" }

RESET { raise NotImplementedError "RESET (internal) not yet implemented" }
S_IRQ { raise NotImplementedError "S_IRQ (internal) not yet implemented" }
S_NMI { raise NotImplementedError "S_NMI (internal) not yet implemented" }
