require 'spec_helper'

describe WAMP::Engines::Redis do
  let(:redis) { WAMP::Engines::Redis.new }

  context "initialization" do
    it "should have two instances of the redis class" do
      expect(redis.instance_variable_get(:@redis).class).to eq EM::Hiredis
      expect(redis.instance_variable_get(:@subscriber).class).to eq EM::Hiredis
    end

  end
end
