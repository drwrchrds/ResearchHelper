require 'csv'

# GOAL: a CSV with the questions on the left
# each test-group is a column
# for each column, put all significant demographics and + or -

worksheet = []

contents = CSV.open "mathdone.csv", "r:ISO-8859-1"
contents.each do |row|
  worksheet << row
end

# make one-column array of questions
questions = []
worksheet.each do |row|
  questions << [row[0]]
end

@demos = []
# get an array of hashes for demos
# :demo => (.match(/\a-z\+/)[0]), *segments.each - :seg (demo.match(/\_\a-z\+/)=> col_index
worksheet[0].each_index do |i|
  x = worksheet[0][i]
  p "x is #{x}"

  if x.nil? || x.match(/([0-9a-z]+)(\_)([0-9a-z]+)/).nil?
    next
  end
  skip = false
  
  m = x.match(/([0-9a-z]+)(\_)([0-9a-z]+)/)
  p m
  # run through all @demos to see if it exists
  @demos.each do |d|
    p d
    p m
    # p m[1]
    if d.is_a?(Hash) && d[:demo].to_s == m[1]
      # assign each segment to its column index
      d[:segments][m[3].to_sym] = i
      skip = true
    end
  end
  next if skip == true
  d = Hash.new
  d[:demo] = m[1].to_sym
  d[:segments] = {m[3].to_sym => i}
  @demos << d
end

# test 2p or 1p test
@demos.each do |demo|
  if demo[:segments].keys.count > 2
    demo[:type] = :p1
  else
    demo[:type] = :p2
  end
end

# get significant true / false, and +/-
# in an array that is a column of worksheet
@demos.each do |demo|
  header = true
  worksheet.each_index do |i|
    if header == true
      questions[i] << demo[:demo].to_s
      header = false
    else
      row = worksheet[i]
      cell = []
      demo[:segments].each do |segment, index|
        if row[index + 3] == "TRUE"
          # condition ? if_true : if_false
          row[index + 2].to_i > 0 ? sign = "+" : sign = "-"
          cell << segment.to_s.upcase + sign
        end
      end
      questions[i] << cell.join(', ')
    end
  end
end

CSV.open "summarycharts.csv", "wb" do |row|
  questions.each do |question|
    row << question
  end
end
p "all done!"
  # ends with 
  