require 'spec_helper'

class DummySocket
  def send(*args); true; end;
end

describe WAMP::Socket do
  let(:new_socket) { WAMP::Socket.new("sampleid", DummySocket.new) }

  context "#initialization" do
    it "should return a client" do
      expect(new_socket.class).to eq WAMP::Socket
    end

    it "should create a new id on creation" do
      expect(new_socket.id).to_not be_nil
    end

    it 'should have an array of topics' do
      expect(new_socket.topics).to eq []
    end

    # it "should send the welcome message" do
    #   ds = DummySocket.new
    #   ds.should_receive :send
    #   WAMP::Socket.new("sampleid", ds)
    # end
  end

  it 'should add a new topic to client' do
    topic = WAMP::Topic.new("ws://localhost:9292/sample_topic")
    new_socket.add_topic topic
    expect(new_socket.topics).to eq [topic]
  end
end
