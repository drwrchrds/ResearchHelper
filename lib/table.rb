class Table < Question
  attr_reader :subquestions
  
  def initialize
    @name, @number, @rows = name, number, rows
    @subquestions = get_subquestions
  end
  
  def get_subquestions
    # def get_table_question_values(options, subquestion)
#       @values = []
#       @n = subquestion[options.last[0]].to_i
#
#       options[0..-2].each_index do |i|
#         v = Hash.new
#         v[:name] = options[i][1]
#         v[:count] = subquestion[options[i][0] + 1].to_i # get i + 1 to get next column (count instead of %)
#         v[:n] = @n
#         v[:p] = v[:count].to_f / v[:n].to_f
#         # p "#{v[:name]} - count: #{v[:count]} n: #{v[:n]} p: #{v[:p]}"
#         @values << v
#       end
#       @values
#     end
  end
end