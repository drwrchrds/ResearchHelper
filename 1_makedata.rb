require 'csv'
require 'date'
require 'debugger'

### start method definitions

def question_header?(row)
  row[0].to_s[0..6].match(/\d{1,2}\.\s.+/) != nil
end

def find_questions(rows)
  starts = [] # list of starting indices
  ends = [] # list of ending indices
  
  i = 0
  
  while i < rows.count 
    begin
      if question_header?(rows[i])
        starts << i
        # check to see if the next four rows are all empty
      elsif rows[i][0] != nil && rows[i+1][0] == nil && rows[i+2][0] == nil && rows[i+3][0] == nil && rows[i + 4][0] == nil
        ends << i
      end
      i += 1
    rescue NoMethodError => error
      puts "Reached end of file: " + e
      ends << (i - 1)
      break
    end
  end

  starts.each_index do |x|
    @starts_ends << [starts[x], ends[x]]
  end
end

def split_questions
  @starts_ends.each do |start, finish|
    question = []
    @rows[start..finish].each do |row|
      question << row
    end
    @questions_by_arr << question
  end
end


def get_question_number(first_row)
  number = first_row[0].match(/\d{1,2}/)[0]
end


def get_question_text(string)
  digits_to_drop = string.match(/\d{1,2}/)[0].length + 2
  text = string.split('').drop(digits_to_drop).join('')
end


def get_question_type(question)
  next_row = question[1]
  next_cell_down = question[1][0]
  if next_cell_down == nil
#=begin # uncomment this for doing top-two questions
    next_row.each_index do |cell_index|
      # at each cell, see if the cell two to the right contains a 2, and the cell four to the right has a 3, etc.
      # this works best b/c sometimes scale questions start or end with other options, e.g., N/A, Don't Know
      if next_row[cell_index].to_s.include?("1") && next_row[cell_index + 2].to_s.include?("2") && next_row[cell_index + 4].to_s.include?("3") && next_row[cell_index + 6].to_s.include?("4") && next_row[cell_index + 8].to_s.include?("5")
        return :top_two
      end
    end
#=end
    :table
  elsif next_cell_down == "Value"
    :single
  elsif next_cell_down == "Item"
    :rank
  end
  # are there other question types that would be good to list here?
end



def get_question_values(type, question)
  @values = []
  if type == :single # for SINGLE
    @v_start = 2
    @v_end = 0
    @n = 0 # sample size - will be for a :single type Q
    # get final question value position (@v_end)
    question.each do |row|
      if row[0].nil?
        break
      else
        @v_end += 1
      end
    end
    # get @n 
    question.each do |row|
      if row[0] == "Total Responses"
        @n = row[1].to_i
        break
      end
    end
    # get values by going down the left-most column (until you hit nil)
    question[@v_start...@v_end].each do |row|
      v = Hash.new
      v[:name] = row[0]
      v[:count] = row[1].to_i
      v[:n] = @n
      v[:p] = v[:count].to_f / v[:n].to_f
      @values << v
    end
  elsif type == :rank # for RANK - looks a lot like single
    @v_start = 2
    @v_end = 0
    @n = 0 # sample size - will be for a :single type Q
    # get final question value position and @n
    question.each do |row|
      if row[0].include? "total_responses_text"
          @n = row[0].match(/\d+/)[0].to_i
        break
      else
        @v_end += 1
      end
    end
    # get values by going down the left-most column (until you hit nil)
    question[@v_start...@v_end].sort.each do |row|
      v = Hash.new
      # break if row.compact == [] <- use this if you don't have v_end
      v[:name] = row[0]
      v[:rank] = row[2].to_i
      v[:n] = @n
      @values << v
    end
  elsif type == :top_two # for TOP-TWO type
    @four = 0
    @five = 0
    @responses = 0

    # get indices of columns containing top-two picks
    question[1].each_index do |i|
      # some 
      if question[1][i].to_s.include?("4") && question[1][i+2].to_s.include?("5")
        @four = i + 1
        @five = i + 3
      elsif question[1][i].to_s == "Responses"
        @responses = i
      end
    end

    question[3..-1].each do |row|
      v = Hash.new
      v[:name] = row[0]
      v[:count] = row[@four].to_i + row[@five].to_i
      v[:n] = row[@responses].to_i
      v[:p] = v[:count].to_f / v[:n].to_f
      @values << v
    end
  end
  @values
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
  @questions_by_arr.each do |question|
    q = Hash.new
    q[:number] = get_question_number(question[0])
    q[:question] = question[0][0]
    q[:type] = get_question_type(question)

    # :table type questions are tricky, since they have many multiple-choice questions
    # within them. These get sorted out first, and the rest follow up in the 'else' statement
    # this includes "top_two" questions as table questions, but you still get the 'top-two' results below
    if q[:type] == :table || q[:type] == :top_two
    
      parent_num = q[:number]
      parent_question = q[:question]
      # get column indices for answer options
      # as well as answer strings
      options = []
      question[1].each_index do |i|
        if !question[1][i].nil?
          options << [i, question[1][i]]
        end
      end
    
      i = 1
      first = true
    
      # if it's a normal table, starting row is 2. If it's a top_two, starting row is 3.
      q[:type] == :top_two ? starting_row = 3 : starting_row = 2
    
      question[starting_row..-1].each_with_index do |subquestion, idx|
        next if subquestion[0].nil?
        
        s = Hash.new
        s[:number] = parent_num + ".#{i}"
        s[:type] = :multi
        if first == true
          
          s[:question] = parent_question + "::" + subquestion[0]
        else
          # this cuts off the parent_question title after 50 characters, then adds the subquestion title on the end
          # e.g., "15.2 - How would you compare each amenity to WiFi as a...::Magazines"
          s[:question] = parent_question[0..50] + "...::" + subquestion[0]
        end
        s[:values] = get_table_question_values(options, subquestion)
        @questions_by_hash << s
        i += 1
        first = false
      end
    end
    
    if q[:type] != :table
      q[:values] = get_question_values(q[:type], question)
      @questions_by_hash << q
    end
  end

  two_p_test = []
  # do this with an array?

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