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

  context "client management" do
    context "#create_client" do
      it "should create a new instance of a socket" do
        expect { memory.create_client(DummySocket) }
          .to change(memory.clients, :size).by(1)
      end
    end

    context "with existing clients" do
      before do
        @ds1 = DummySocket.new(1)
        @ds2 = DummySocket.new(2)

        @id1 = memory.create_client(@ds1).id
        @id2 = memory.create_client(@ds2).id
      end

      context "#delete_client" do
        it "should delete a client" do
          expect { memory.delete_client @ds1 }
            .to change(memory.clients, :size).by(-1)
        end

        it "should return the removed client" do
          client = memory.find_clients(websocket: @ds1).first
          expect(memory.delete_client @ds1).to eq client
        end
      end

      context "#all_clients" do
        it "should return an array of all the clients" do
          expect(memory.all_clients.size).to eq 2

          expect(memory.all_clients).to eq memory.clients.values
        end
      end

      context "#find_clients" do
        it "should find a client by the given parameter" do
          expect(memory.find_clients(id: @id1).first.websocket).to eq @ds1
          expect(memory.find_clients(id: @id2).first.websocket).to eq @ds2
        end

        it "should return all the clients that match" do
          expect(memory.find_clients(topics: []).size).to eq 2
        end
      end
    end
  end

  context "topic management" do
    context "find or create a new topic" do
      it "should create a new topic" do
        expect { memory.find_or_create_topic("http://localhost/sample_topic") }
          .to change(memory.topics, :size).by(1)
      end

      it "should return an existing topic if one already exists" do
        new_topic = memory.find_or_create_topic("http://localhost/sample_topic")
        expect(memory.find_or_create_topic "http://localhost/sample_topic")
          .to eq new_topic
      end
    end

    context "topic subscription" do
      before do
        @client = memory.create_client(@ds1)
        @topic  = memory.find_or_create_topic("http://localhost/sample_topic")

        @sub = memory.subscribe_client_to_topic @client, @topic.uri
      end

      it "should add a client to a topic" do
        expect(@client.topics).to include @topic
      end

      it "should add a topic to a client" do
        expect(@topic.clients).to include @client
      end

      it "should return the topic the client subscribed to" do
        expect(@sub).to eq @topic
      end
    end

    context "topic unsubscription" do
      before do
        @client = memory.create_client(@ds1)
        @topic  = memory.find_or_create_topic("http://localhost/sample_topic")

        @sub = memory.subscribe_client_to_topic @client, @topic.uri
      end

      it "should remove the client from the topic" do
        expect { memory.unsubscribe_client_from_topic @client, @topic.uri }
          .to change(@topic.clients, :size).by(-1)
      end

      it "should remove the topic from the client" do
        expect { memory.unsubscribe_client_from_topic @client, @topic.uri }
          .to change(@client.topics, :size).by(-1)
      end
    end
  end
end
