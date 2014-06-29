class Question
  attr_reader :sample_size, :values, :name, :number
  
  def initialize(name, number, rows)
    @name, @number, @rows = name, number, rows
    @sample_size = 0
    begin
      @values = get_values
    rescue ArgumentError => e
      debugger
      retry
    rescue => e
      debugger
      retry
    end
  end
  
  def add_value(name, count)
    val = Value.new(name, count)
    val.question = self
    val
  end
  
  def values
    @values ||= []
  end
  
  def inspect
    "<Question: #{number}, #{name[0..25]}, Values: #{values.count}>"
  end
  
  def to_s
    
  end
  
  def self.parse_row_data(rows)
    number = rows[0][0].match(/\d+/)[0]
    name = rows[0][0]
    type = Question.parse_type(rows)
    question = type.new(name, number, rows)
    
    if type == Table
      # return subquestions if type is Table
      question.subquestions
    else
      # must return question in array for Array#concat
      [question]
    end
  end
  
  def self.parse_type(rows)
    next_row = rows[1]
    next_cell_down = rows[1][0]
    if next_cell_down == nil
  #=begin # uncomment this for doing top-two questions
      next_row.each_index do |col|
        # at each cell, see if the cell two to the right contains a 2, and the cell four to the right has a 3, etc.
        # this works best b/c sometimes scale questions start or end with other options, e.g., N/A, Don't Know
        if next_row[col].to_s.include?("1") && next_row[col + 2].to_s.include?("2") && next_row[col + 4].to_s.include?("3") && next_row[col + 6].to_s.include?("4") && next_row[col + 8].to_s.include?("5")
          return TopTwo
        end
      end
  #=end
      Table
    elsif next_cell_down == "Value"
      Single
    elsif next_cell_down == "Item"
      Rank
    end
  end
end



