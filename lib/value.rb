class Value
  attr_accessor :question, :sample
  attr_reader :name, :count
  
  def initialize(name, count)
    @name, @count = name, count
  end
  
  def proportion
    @count / @sample.to_f
  end
end

class RankValue < Value
  attr_reader :rank
  
  def initialize(name, count, rank)
    @name, @count, @rank = name, count, rank
  end
end