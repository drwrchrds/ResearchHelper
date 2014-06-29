require 'csv'
require 'date'
require 'debugger'
Dir["./lib/*"].each {|file| require file }

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
  @starts_ends = starts.zip(ends)
end

def split_questions
  @starts_ends.each do |start, finish|
    question_rows = []
    @rows[start..finish].each do |row|
      question_rows << row
    end
    @questions << question_rows
  end
end


def get_question_text(string)
  digits_to_drop = string.match(/\d{1,2}/)[0].length + 2
  text = string.split('').drop(digits_to_drop).join('')
end




### end method definitions

### begin program
p "Sifting for relevant data in: all demos"
# demo = gets.chomp
demos = Dir.entries("sg_in").select { |file| !File.directory?(file) }
demos.each do |demo|
  contents = CSV.open "sg_in/#{demo}", "r:ISO-8859-1"
  @rows = []
  @starts_ends = []
  @questions = []

  # these three methods populate @questions with each question
  contents.each do |row|
    @rows << row
  end
  puts demo
  find_questions(@rows)
  split_questions
  p "#{@questions.count} questions to parse"

  # get question objects
  @questions.map! do |question|
    Question.parse_row_data(question)
  end

  debugger
  CSV.open("sg_out/#{demo}", "wb") do |row|
    row << [nil, "#{demo.chomp('.')}", DateTime.now]
    row << [nil, "p/rank", "n"]
    
    @questions.each do |question|
      row << [hash[:number] + " - " + get_question_text(hash[:question])]
      row << [hash[:type].to_s]
      hash[:values].each do |value|
        if hash[:type] == :rank
          row << [value[:name], value[:rank], value[:n]]
        else
          row << [value[:name], value[:p], value[:n]]
        end
      end
      row << []
    end
  end

  p "success! - sg_out/#{demo} created"
end