class DummySocket
  attr_accessor :id

  def initialize(id = "sampleid")
    @id = id
  end

  def send(args)
    true
  end
end
