class Subquestion < Question
  attr_accessor :parent_question
  
  def initialize(name, number, rows, parent)
    @name, @number, @rows, @parent_question = 
          name, number, rows, parent
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
  
  
  def get_values
    options = parent_question.options
    responses_index = options.last[0]
    @sample_size = Integer(@rows[responses_index])
    
    values = []

    options.each_with_index do |option, idx|
      next if idx == options.length - 1
      val_name = option[1]
      val_count = Integer(@rows[option[0] + 1])
      value = Value.new(val_name, val_count)
      value.sample = @sample_size
      value.question = self
      values << value
    end

    values
  end

end