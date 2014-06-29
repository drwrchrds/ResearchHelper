


require 'csv'
require 'date'
require 'debugger'

Dir["./lib/*"].each { |file| require file }

### start method definitions

def question_header?(row)
  row[0].to_s[0..6].match(/\d+\.\s.+/)
end

def find_questions(rows)
  starts = [] # list of starting indices
  ends = [] # list of ending indices
  
  i = 0
  
  while i < rows.count 
    begin
      if question_header?(rows[i])
        starts << i
        i += 2
        until rows[i].all?(&:nil?)
          i += 1
        end
        ends << i - 1
      end
      i += 1
    rescue NoMethodError => error
      puts "Reached end of file: " + error.message
      ends << (i - 1)
      break
    end
  end
  # debugger
  starts.zip(ends)
end

def split_questions(rows, starts_ends)
  row_sets = []
  starts_ends.each do |start, finish|
    row_sets << rows[start..finish]
  end
  row_sets
end


p "Sifting for relevant data in: all demos"
# demo = gets.chomp

demos = Dir.entries("sg_in").select { |file| !File.directory?(file) }


demos.each do |demo|
  contents = CSV.open "sg_in/#{demo}", "r:ISO-8859-1"

  rows = contents.to_a
  starts_ends = find_questions(rows)
  @question_row_sets = split_questions(rows, starts_ends)


  # create question objects from row data
  questions = []
  @question_row_sets.each do |question_rows|
    questions.concat(Question.parse_row_data(question_rows))
  end

  CSV.open("sg_out/#{demo}", "wb") do |rows|
    rows << [nil, "#{demo.chomp('.')}", DateTime.now]
    rows << [nil, "p/rank", "n"]
  
    questions.each do |question|
      rows << [question.name]
      rows << [question.class.to_s]
      question.values.each do |value|
        if question.class == Rank
          rows << [value.name, value.rank, value.count]
        else
          rows << [value.name, value.proportion, value.count]
        end
      end
      # add empty line to separate questions
      rows << []
    end
  end

  p "success! - sg_out/#{demo} created"
end