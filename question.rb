class Question
  def initialize(type, number, start_row, end_row)
    @number, @start_row, @end_row = number, start_row, end_row
    @values = []
  end
  
  # write factory methods here
  def self.new_top_two(start_row, end_row)
    
  end
  
  def self.new_rank(start_row, end_row)
  end
  
  def self.new_single(start_row, end_row)
  end
  
  def self.new_table(start_row, end_row)
  end
end