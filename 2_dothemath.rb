require 'csv'

demos = Dir.entries("sg_out").select { |file| !File.directory?(file) }
demos.map! { |demo| demo[0..-5] }
demos.sort!

big_array = []
  first_col = CSV.open "sg_out/!alldata.csv", "r:ISO-8859-1"
  first_col.each do |row|
  big_array << [row[0]]
end

demos.each do |demo|
  contents = CSV.open "sg_out/#{demo}.csv", "r:ISO-8859-1" 
    i = 0
    contents.each do |row|
    big_array[i] = big_array[i] + [row[1], row[2], nil, nil]
    i+=1
  end
  p "included #{demo}"
end

CSV.open "dothemath.csv", "wb" do |row|
  big_array.each do |x|
    row << x
  end
end
p "all done - now do the math!"