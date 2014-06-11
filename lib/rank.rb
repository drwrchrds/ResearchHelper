class Rank < Question
  def get_values
    values = []
    value_at = 2
    
    while value_at < @rows.count 
      row = @rows[value_at]
      name = row[0]
      break if name == 'total_responses_text'
      weight = Integer(row[1])
      values << add_value(name, weight)
      
      value_at += 1
    end
    values
  end
end