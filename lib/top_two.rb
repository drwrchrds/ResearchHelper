class TopTwo < Question
  def sample_size
    raise NotImplementedError.new("Can't calculate sample size of aggregate questions")
  end

  def get_values
    values = []
    value_at = 3
    
    # get indices of columns containing top-two picks
    number_row = @rows[1]
    four, five, total = extract_four_five_total(number_row)

    while value_at < @rows.count
      row = @rows[value_at]
      name = row[0]
      count = Integer(row[four]) + Integer(row[five])
      sample = Integer(row[total])
      values << add_value(name, count, sample)
      
      value_at += 1
    end
    values
  end
  
  def add_value(name, count, sample)
    val = Value.new(name, count)
    val.question = self
    val.sample = sample
    val
  end
  
  private
  
    def extract_four_five_total(row)
      four_col, five_col, total_responses_col = nil, nil, nil
    
      row.each_with_index do |col, idx|
        next unless col
        
        # grab indices of '4' and '5'
        if col.match('4')
          four_col = idx + 1
          five_col = idx + 3
        end
      
        if col.match('Responses')
          total_responses_col = idx
        end
      end
      [four_col, five_col, total_responses_col]
    end
end