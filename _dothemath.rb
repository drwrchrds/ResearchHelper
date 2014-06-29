require 'csv'
require 'debugger'

demos = Dir.entries("sg_out").select { |file| !File.directory?(file) }
demos.map! { |demo| demo[0..-5] }
demos.sort!


# change Z for different confidence levels:
# 1.645 => 90%
# 1.96 => 95%
# 2.575 => 99%

Z = 1.645

class PopulationSizeError < StandardError
end

first_col = CSV.open "sg_out/!alldata.csv", "r:ISO-8859-1"
big_array = first_col.to_a.map { |row| row.concat([nil, nil]) }

demos.each do |demo|
  next if demo == '!alldata'
  contents = CSV.open "sg_out/#{demo}.csv", "r:ISO-8859-1" 
  i = 0
  contents.each do |row|
    begin
      p1 = Float(row[1])
      p0 = Float(big_array[i][1])
      n1 = Float(row[2])
      n0 = Float(big_array[i][2])
    
      raise PopulationSizeError.new if n0 < 30
      # (p1-p0)/SQRT(p0*(1-p0)*(1/n1+1/n0))
      numerator = (p1 - p0)
      denominator = Math.sqrt(p0 * (1 - p0) * (1 / n1 + 1 / n0))
      
      
      standard_deviations = numerator / denominator
      
      # 0.0 / 0.0 gives NaN (not a number), catch this error here
      raise Math::DomainError.new if standard_deviations.nan?
      
      significant = standard_deviations.abs > Z && n1 >= 30
    rescue ZeroDivisionError => e
      # denominator == 0
      standard_deviations = nil
      significant = nil
    rescue NoMethodError => e
      # no method abs for nil
      standard_deviations = nil
      significant = nil
    rescue ArgumentError => e
      # invalid value for float
      standard_deviations = nil
      significant = nil
    rescue TypeError => e
      # can't create float
      standard_deviations = nil
      significant = nil
    rescue Math::DomainError => e
      # can't square_root a negative number
      standard_deviations = 'N/A'
      significant = nil
    rescue PopulationSizeError => e
      # population is too small for sig testing
      standard_deviations = 'N/A'
      significant = nil
    ensure
      big_array[i].concat [row[1], row[2], standard_deviations, significant, nil]
      i += 1
    end
  end
  p "included #{demo}"
end

CSV.open "significance_calculations.csv", "wb" do |row|
  big_array.each do |x|
    row << x
  end
end
p "all done - now do the math!"