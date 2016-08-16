
10.times do |n|
   Widget.find_or_create_by!(:name => "Widget#{n + 1}")
end

puts "#{Widget.count} widgets"