require 'spec_helper'

class DummySocket
end

describe WAMP::Engines::Memory do
	let(:memory) { WAMP::Engines::Memory.new }

	context "#initialization" do
		it "should initialize with some empty hashes" do
			expect(memory.clients).to eq({})
			expect(memory.topics).to eq({})
			expect(memory.options).to eq({})
		end
	end

	context "#create_client" do
		it "should create a new instance of a socket" do

		end
	end
end