require "csv"

module Vintage

  ##
  # Loads configuration for 6502 from two files:
  #   * 6502.csv: Provides mappings between Opcode, Instruction, and Addressing Modes
  #   * 6502.rb:  Ruby based DSL providing functionality for each opcode
  class Config
    CONFIG_DIR = "#{File.dirname(__FILE__)}/../../config"

    def initialize
      load_codes
      load_definitions
    end

    attr_reader :definitions, :codes

    def opcode(command, mode)
      code = @codes.find { |key, value| [value[0].upcase, value[1]] == [command.upcase, mode] }

      code.first if code
    end

    private

    ##
    # Table lookup of mappings between Opcodes and their corresponding Instructions
    def load_codes
      csv_data = CSV.read("#{CONFIG_DIR}/6502.csv")
                    .reject { |r| r[0].start_with?('!') }
                    .map { |r| [r[0].to_i(16), [r[1].to_sym, r[2]]] }

      @codes = Hash[csv_data]
    end

    ##
    # Use instance_eval to interpret the instruction set behavior as defined in 6502.rb
    # opcodes are intercepted by +method_missing+
    def load_definitions
      @definitions = {}

      instance_eval(File.read("#{CONFIG_DIR}/6502.rb"))
    end

    ##
    # Opcodes are declared within 6502.csv. Opcode behavior is defined in 6502.rb
    # The method_missing hook builds a mapping between each opcode and its behavior
    def method_missing(id, *a, &b)
      return super unless id == id.upcase

      @definitions[id] = b
    end
  end
end
