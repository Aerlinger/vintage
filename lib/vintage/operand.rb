module Vintage
  # See http://www.obelisk.demon.co.uk/6502/addressing.html For more information on 6502 addressing modes
  module Operand
    def self.read(mem, mode, x, y)
      case mode
      when "#" # Implicit 
        nil
      when "@" # Relative
        offset = mem.next

        mem.pc + (offset <= 0x80 ? offset : -(0xff - offset + 1)) 
      when "IM" # Immediate
        mem.pc.tap { mem.next }
      when "ZP" # Zero Page
        mem.next
      when "ZX" # Zero Page, X
        mem.next + x
      when "ZY" # Zero Page, Y
        mem.next + y
      when  "AB" # Absolute
        mem.int16([mem.next, mem.next])
      when  "AX" # Absolute, Y
        mem.int16([mem.next, mem.next]) + x
      when  "AY" # Absolute, Y
        mem.int16([mem.next, mem.next]) + y
      when "IX" # Indexed Indirect
        e = mem.next

        mem.int16([mem[e + x], mem[e + x + 1]])
      when "IY" # Indirect Indexed
        e = mem.next

        mem.int16([mem[e], mem[e+1]]) + y
      else
        raise NotImplementedError, mode.inspect
      end
    end
  end
end
