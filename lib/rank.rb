class Rank < Question
  def get_values
    values = []
    begin
      value_at = 2
    
      while value_at < @rows.count 
        row = @rows[value_at]
        name = row[0]
        break if name.match('total_responses_text:')
        count = Integer(row[1])
        rank = Integer(row[2])
        
        value = RankValue.new(name, count, rank)
        value.question = self
        values << value
        
        value_at += 1
      end
    rescue => e
      debugger
      retry
    end
    values
  end
end