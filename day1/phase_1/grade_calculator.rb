scores = []

print "enter number of scores : "
num_scores = gets.chomp.to_i

i = 1
while i <= num_scores
  print "Enter score #{i}: "
  score = gets.chomp.to_i
  
  if score >= 0 && score <= 100
    scores.push(score)
    i = i + 1
  else
    puts "Invalid score enter number between 0 and 100"
  end
end

sum = 0
scores.each do |s|
  sum = sum + s
end

average = sum.to_f / num_scores

if average >= 90
  grade = "A"
elsif average >= 80
  grade = "B"
elsif average >= 70
  grade = "C"
elsif average >= 60
  grade = "D"
else
  grade = "F"
end

highest = scores.max
lowest = scores.min

puts ""
puts "Results:"
puts "  Average : #{average}"
puts "  Grade   : #{grade}"
puts "  Highest : #{highest}"
puts "  Lowest  : #{lowest}"
