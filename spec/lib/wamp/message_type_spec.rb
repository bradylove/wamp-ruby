require 'spec_helper'

describe WAMP::MessageType do
  it "should be a module" do
    expect(WAMP::MessageType.class).to eq Module
  end

  def self.expect_message_type(type, id)
    it "should return the message type id" do
      expect(WAMP::MessageType[type]).to eq id
    end

    it "should return the name if given an integer" do
      expect(WAMP::MessageType[id]).to eq type
    end
  end

  self.expect_message_type :WELCOME, 0
  self.expect_message_type :PREFIX, 1
  self.expect_message_type :CALL, 2
  self.expect_message_type :CALLRESULT, 3
  self.expect_message_type :CALLERROR, 4
  self.expect_message_type :SUBSCRIBE, 5
  self.expect_message_type :UNSUBSCRIBE, 6
  self.expect_message_type :PUBLISH, 7
  self.expect_message_type :EVENT, 8

end
