class Single < Question
  def get_values
    values = []
    value_at = 2
    
    while value_at < @rows.count
      row = @rows[value_at]
      name = row[0]
      count = Integer(row[1])
      values << add_value(name, count)
      @sample_size += count
      
      value_at += 1
    end
    values.each { |val| val.sample = @sample_size }
    values
  end
end