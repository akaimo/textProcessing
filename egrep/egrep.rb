if ARGV.count != 2
  puts 'usage: egrep [pattern] [file]'
  exit
end

begin
  file = open(ARGV[1])
rescue => ex
  print 'egrep: text: '
  puts ex
  exit
end

file.each do |line|
  print line if /#{ARGV[0]}/ =~ line
end
file.close
