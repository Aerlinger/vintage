module Vintage
  class CPU
    def initialize
      # Registers of CPU include 8-bit X and Y registers as well as an accumulator (A) register
      @registers = { :a => 0, :x => 0, :y => 0 }

      # States of 6502 CPU (z => zero?, c => carry?, n => negative?)
      @flags     = { :z => 0, :c => 0, :n => 0 }
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

    def carry_if(test)
      test ? set_carry : clear_carry
    end

    def result(number)
      number &= 0xff

      @flags[:z] = (number == 0 ? 1 : 0)
      @flags[:n] = number[7]

      number
    end
  end
end

                   
