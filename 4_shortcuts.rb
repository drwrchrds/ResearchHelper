# write shortcut names in second row of summarycharts.csv, e.g.:
# 2013 Revenue   2013 Growth    Gender
#      $             Gr           Ge


require 'csv'

data = []
CSV.foreach "sg_out/!alldata.csv" do |row|
data << [row[0],row[1], row[2]] # collect the first 3 columns from '!alldata.csv'
end
p "imported !alldata.csv successfully. Now importing summarycharts.csv"

summarycharts = []
CSV.foreach "summarycharts.csv" do |row|
summarycharts << row
end
p "imported summarycharts.csv successfully. Did you input shortcut names?"

shortcuts = summarycharts[1] # this gets the shortcut names from the SECOND row in summarycharts.csv
if shortcuts[1] == ""
  p "Don't forget to add shortcodes for your demographics in the SECOND ROW of summarycharts.csv!"
  p "Please add shortcodes and try running this program again."
  exit
else
  p "Here's all your shortcuts: #{shortcuts}."
end

all_shortcuts = [nil, nil]
summarycharts[2..-1].each do |row| # "summarycharts[2..-1]" pulls every row after the top two
  keys = []
  #p row[1..-1]
  for i in 1..(row.count-1) # this moves through every index after 0, and retrieves the "shortcut" if the cell is NOT nil
    if row[i]
      keys << shortcuts[i]
    end
  end
  all_shortcuts << keys.join(' ')
end



CSV.open "shortcuts.csv", "wb" do |row|
  summarycharts.each_index do |i|
    row << [data[i][0], data[i][1], data[i][2], all_shortcuts[i]]
  end
end
p "All done! Now you get to make a bunch of charts!"