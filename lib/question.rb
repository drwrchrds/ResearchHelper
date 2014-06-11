class Question
  TYPES = [
    :top_two,
    :single,
    :table,
    :rank
  ]
  
  def initialize(name, number, start_row, end_row)
    @name, @number, @start_row, @end_row = name, number, start_row, end_row
    @values = []
  end
  
  # write factory methods here
  
  def self.parse_row_data(rows)
    debugger
    number = rows[0][0].match(/\d/)[0]
    name = rows[0][0]
    type = Question.parse_type(rows)
    
  end
  
  def self.parse_type(rows)
    next_row = rows[1]
    next_cell_down = rows[1][0]
    if next_cell_down == nil
  #=begin # uncomment this for doing top-two questions
      next_row.each_index do |cell_index|
        # at each cell, see if the cell two to the right contains a 2, and the cell four to the right has a 3, etc.
        # this works best b/c sometimes scale questions start or end with other options, e.g., N/A, Don't Know
        debugger
        if next_row[cell_index].to_s.include?("1") && next_row[cell_index + 2].to_s.include?("2") && next_row[cell_index + 4].to_s.include?("3") && next_row[cell_index + 6].to_s.include?("4") && next_row[cell_index + 8].to_s.include?("5")
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

class TopTwo < Question
  def initialize
    
  end
end

class Single < Question
end

class Rank < Question
end

class Table < Question
end
