require 'spec_helper'

describe WAMP::Topic do
  context "initialization" do
    it "should have a URI" do
      topic = WAMP::Topic.new("ws://localhost:9292/sample_topic")
      expect(topic.name).to eq "ws://localhost:9292/sample_topic"
    end
  end
end
