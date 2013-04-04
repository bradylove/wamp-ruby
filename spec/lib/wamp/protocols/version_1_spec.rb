require 'spec_helper'

describe WAMP::Protocols::Version1 do
  let(:protocol) { WAMP::Protocols::Version1.new }

  it "should have a version of 1" do
    expect(protocol.version).to eq 1
  end

  it "should describe a WELCOME message" do
    expect(protocol.welcome "id").to eq "[0,\"id\",1,\"#{WAMP.identity}\"]"
  end

  it "should describe a PREFIX message" do
    expect(protocol.prefix "prefix", "uri").to eq "[1,\"prefix\",\"uri\"]"
  end

  it "should describe a CALL message" do
    expect(protocol.call "callID", "procURI", [1, 2], "Arg3")
      .to eq "[2,\"callID\",\"procURI\",[1,2],\"Arg3\"]"
  end

  context "#call_result" do
    it "should describe a CALLRESULT with null as default results" do
      expect(protocol.call_result "callID").to eq "[3,\"callID\",null]"
    end

    it "should describe a CALLRESULT with a given result" do
      expect(protocol.call_result "callID", "Result").to eq "[3,\"callID\",\"Result\"]"
    end
  end

  context "#call_error" do
    it "should describe a CALLERROR message without error details" do
      expect(protocol.call_error "callID", "errorURI", "errorDesc")
        .to eq "[4,\"callID\",\"errorURI\",\"errorDesc\"]"
    end

    it "should describe a CALLERROR message with error details" do
      expect(protocol.call_error "callID", "errorURI", "errorDesc", "errorDetails")
        .to eq "[4,\"callID\",\"errorURI\",\"errorDesc\",\"errorDetails\"]"
    end
  end

  context "#subscribe" do
    it "should describe the SUBSCRIBE message" do
      expect(protocol.subscribe "topicURI").to eq "[5,\"topicURI\"]"
    end
  end

  context "#unsubscribe" do
    it "should describe the UNSUBSCRIBE message" do
      expect(protocol.unsubscribe "topicURI").to eq "[6,\"topicURI\"]"
    end
  end

  context "#publish" do
    it "should describe the PUBLISH message with a topic and a event payload" do
      expect(protocol.publish "topic_uri", "payload")
        .to eq "[7,\"topic_uri\",\"payload\"]"
    end

    it "should describe the PUBLISH message with a topic, event payload, and excludeMe" do
      expect(protocol.publish "topic_uri", "payload", true)
        .to eq "[7,\"topic_uri\",\"payload\",true]"
    end

    it "should describe the PUBLISH message with a topic, event payload, exclude, and include" do
      expect(protocol.publish "topic_uri", "payload", nil, ["include_id"])
        .to eq "[7,\"topic_uri\",\"payload\",null,[\"include_id\"]]"
    end
  end

  context "#event" do
    it "should describe the EVENT message" do
      expect(protocol.event "topicURI", "Event Data")
        .to eq "[8,\"topicURI\",\"Event Data\"]"
    end
  end
end
