module Vintage
  class CPU
    def initialize
      # Registers of CPU include 8-bit X and Y registers as well as an accumulator (A) register
      @registers = { :a => 0, :x => 0, :y => 0 }

      # States of 6502 CPU:
      #   * n => negative?
      #   * v => overflow?
      #   * b => break
      #   * d => decimal?
      #   * i => interrupts disabled)
      #   * z => zero?
      #   * c => carry?
      @flags     = { :n => 0, :v => 0, :b => 0, :d => 0, :i => 0, :z => 0, :c => 0 }
    end

    def [](key)
      @registers[key] || @flags.fetch(key)
    end

    def []=(key, value)
      unless @registers.key?(key)
        raise ArgumentError, "#{key.inspect} is not a register" 
      end

      @registers[key] = result(value)
    end

    def set_carry
      @flags[:c] = 1
    end

    def clear_carry
      @flags[:c] = 0
    end

    def set_overflow
      @flags[:v] = 1
    end

    def clear_overflow
      @flags[:v] = 0
    end

    def set_interrupt
      @flags[:i] = 1
    end

    def clear_interrupt
      @flags[:i] = 0
    end

    def carry_if(test)
      test ? set_carry : clear_carry
    end

    #flags     = { :n => 0, :v => 0, :b => 0, :d => 0, :i => 0, :z => 0, :c => 0 }
    def get_flag_mask
      mask = 0
      mask += 128*@flags[:n]
      mask += 64*@flags[:v]
      mask += 16*@flags[:b]
      mask += 8*@flags[:d]
      mask += 4*@flags[:i]
      mask += 2*@flags[:z]
      mask += 1*@flags[:c]

      return mask
    end

    def set_status(value)
      @flags[:n] = value >= 128
      @flags[:v] = value >= 64
      @flags[:b] = value >= 16
      @flags[:d] = value >= 8
      @flags[:i] = value >= 4
      @flags[:z] = value >= 2
      @flags[:c] = value >= 1
    end

    def result(number)
      number &= 0xff

      @flags[:z] = (number == 0 ? 1 : 0)
      @flags[:n] = number[7]

      number
    end
  end
end
