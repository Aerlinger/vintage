require_relative "helper"

describe "Instructions" do
  let(:cpu) { Vintage::CPU.new }
  let(:mem) { Vintage::Storage.new }

  let(:registers) { [:a, :x, :y] }
  let(:flags)     { [:c, :n, :z] }

  #context "ASL" do
    it "implements ABsolute addressing" do
    end

    it "implements ABsolute X addressing" do

    end

    it "implements Accumulator addressing" do

    end

    it "implements Zero Page addressing" do

    end

    it "implements Zero Page, X addressing" do

    end
  #end

  def read(bytes, mode, params={})
    x = params.fetch(:x, 0)
    y = params.fetch(:y, 0)

    mem.load(bytes)

    address = Vintage::Operand.read(mem, mode, x, y)
    pc      = mem.pc

    { :address => address, :pc => pc }
  end
end
