require 'spec_helper'

describe WAMP::Engines::Memory do
  let(:memory)       { WAMP::Engines::Memory.new }

  context "#initialization" do
    it "should initialize with some empty hashes" do
      expect(memory.clients).to eq({})
      expect(memory.topics).to eq({})
      expect(memory.options).to eq({})
    end
  end

  context "#create_client" do
    it "should create a new instance of a socket" do
      expect { memory.create_client(DummySocket) }
        .to change(memory.clients, :size).by(1)
    end
  end

  context "#find_clients" do
    before do
      @ds1 = DummySocket.new(1)
      @ds2 = DummySocket.new(2)

      @id1 = memory.create_client(@ds1).id
      @id2 = memory.create_client(@ds2).id
    end

    it "should find a client by the given parameter" do
      expect(memory.find_clients(id: @id1).first.websocket).to eq @ds1
      expect(memory.find_clients(id: @id2).first.websocket).to eq @ds2
    end

    it "should return all the clients that match" do
      expect(memory.find_clients(topics: []).size).to eq 2
    end
  end
end
