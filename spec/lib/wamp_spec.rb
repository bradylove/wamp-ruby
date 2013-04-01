require 'spec_helper'

describe WAMP do
  it "should be a module" do
    expect(WAMP.class).to eq Module
  end

  it "should have a version" do
    WAMP.version.should eq "#{WAMP::MAJOR}.#{WAMP::MINOR}.#{WAMP::PATCH}"
  end

  it "should have a server identity" do
    expect(WAMP.identity).to eq "WAMP Ruby/#{WAMP.version}"
  end

  it "should have a protocol version" do
    expect(WAMP.protocol_version).to eq 1
  end
end
