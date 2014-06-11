class Value
  attr_accessor :question, :sample
  
  def initialize(name, count)
    @name, @count = name, count
  end
  
  def proportion
    @count / @sample.to_f
  end
end