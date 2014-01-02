module Vintage
  ##
  # Top level module representing a 6502-based Virtual Machine
  #
  # Includes:
  #   * Configuration (codes and definitions of the 6502 ISA)
  #   * Virtual Memory (RAM)
  #   * Virtual 6502
  class Simulator
    # An isolated scope to run code (See 'clean-room' ruby pattern)
    EvaluationContext = Struct.new(:mem, :cpu, :e)

    ##
    # Top-level entry point
    #
    # Accepts ROM file as input and a reference to the UI as memory-mapped IO.
    def self.run(file, ui)
      config = Vintage::Config.new
      cpu    = Vintage::CPU.new
      mem    = Vintage::Storage.new

      mem.extend(MemoryMap)
      #mem.ui = ui

      # Tell the memory what data to read for the program (ROM)
      mem.load(File.binread(file).bytes)

      loop do
        code = mem.next

        op, mode = config.codes[code]
        if name
          # We load the operaand from memory
          e = Operand.read(mem, mode, cpu[:x], cpu[:y])

          # Run operation within an isolated evaluation context
          EvaluationContext.new(mem, cpu, e)
                           .instance_exec(&config.definitions[op])
        else
          raise LoadError, "No operation matches code: #{'%.2x' % code}"
        end
      end
    end
  end
end
