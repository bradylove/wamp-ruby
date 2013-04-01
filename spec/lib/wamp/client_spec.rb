require 'spec_helper'

describe WAMP::Client do
  let(:client) { WAMP::Client.new }

  it "should start with an empty id" do
    expect(client.id).to be_nil
  end
end