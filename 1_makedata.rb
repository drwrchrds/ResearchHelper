require 'csv'
require 'date'
require 'debugger'
require './lib/question.rb'

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
    @questions_by_arr << question_rows
  end
end


def get_question_text(string)
  digits_to_drop = string.match(/\d{1,2}/)[0].length + 2
  text = string.split('').drop(digits_to_drop).join('')
end


def get_table_question_values(options, subquestion)
  @values = []
  @n = subquestion[options.last[0]].to_i
    
  options[0..-2].each_index do |i|
    v = Hash.new
    v[:name] = options[i][1]
    v[:count] = subquestion[options[i][0] + 1].to_i # get i + 1 to get next column (count instead of %)
    v[:n] = @n
    v[:p] = v[:count].to_f / v[:n].to_f
    # p "#{v[:name]} - count: #{v[:count]} n: #{v[:n]} p: #{v[:p]}"
    @values << v
  end
  @values
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
  @questions_by_arr = []
  @questions_by_hash = []

  # these three methods populate @questions_by_arr with each question
  contents.each do |row|
    @rows << row
  end
  puts demo
  find_questions(@rows) # trouble here
  split_questions
  p "#{@questions_by_arr.count} questions to parse"

  # this method extracts relevant question data into a hash for each question
  @questions_by_arr.map! do |question|
    quest = Question.parse_row_data(question)
    # q[:number] = get_question_number(question[0])
  #   q[:question] = question[0][0]
  #   q[:type] = get_question_type(question)

    # :table type questions are tricky, since they have many multiple-choice questions
    # within them. These get sorted out first, and the rest follow up in the 'else' statement
    # this includes "top_two" questions as table questions, but you still get the 'top-two' results below
    # if quest.type == :table || quest.type == :top_two
#     
#       parent_num = q[:number]
#       parent_question = q[:question]
#       # get column indices for answer options
#       # as well as answer strings
#       options = []
#       question[1].each_index do |i|
#         if !question[1][i].nil?
#           options << [i, question[1][i]]
#         end
#       end
#     
#       i = 1
#       first = true
#     
#       # if it's a normal table, starting row is 2. If it's a top_two, starting row is 3.
#       q[:type] == :top_two ? starting_row = 3 : starting_row = 2
#     
#       question[starting_row..-1].each_with_index do |subquestion, idx|
#         next if subquestion[0].nil?
#         
#         s = Hash.new
#         s[:number] = parent_num + ".#{i}"
#         s[:type] = :multi
#         if first == true
#           
#           s[:question] = parent_question + "::" + subquestion[0]
#         else
#           # this cuts off the parent_question title after 50 characters, then adds the subquestion title on the end
#           # e.g., "15.2 - How would you compare each amenity to WiFi as a...::Magazines"
#           s[:question] = parent_question[0..50] + "...::" + subquestion[0]
#         end
#         s[:values] = get_table_question_values(options, subquestion)
#         @questions_by_hash << s
#         i += 1
#         first = false
#       end
#     end
    
    # if q[:type] != :table
    #   q[:values] = get_question_values(q[:type], question)
    #   @questions_by_hash << q
    # end
  end

  # do this with an array?
  debugger
  CSV.open("sg_out/#{demo}", "wb") do |row|
    row << [nil, "#{demo.chomp('.')}", DateTime.now]
    row << [nil, "p/rank", "n"]

    @questions_by_hash.each do |hash|
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