class Table < Question
  attr_reader :options
  
  def initialize(name, number, rows)
    @name, @number, @rows = name, number, rows
    @options = get_options
    @values = nil
    get_subquestions
  end
  
  def subquestions
    @subquestions ||= []
  end
  
  def get_options
    options = []
    @rows[1].each_with_index do |cell, idx|
      next unless cell
      options << [idx, cell]
    end
    options
  end
  
  def get_subquestions
    starting_row = 2
  
    num = 1
    @rows.each_with_index do |sub_rows, idx|
      next if idx < 2
      next if sub_rows[0].nil?
      
      # get full parent name only on first subquestion
      sub_number = @number + ".#{num}"
      sub_name = @name.dup.gsub(@number + '.', sub_number)
      if num != 1
        sub_name = sub_name[0..50] + '...'
      end
      sub_name += "::#{sub_rows[0]}"
      
      self.subquestions << Subquestion.new(sub_name, sub_number,
            sub_rows, self)

      num += 1
    end
  end
end