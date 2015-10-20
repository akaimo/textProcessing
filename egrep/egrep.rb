file = open(ARGV[1])
file.each {|line|
  if /#{ARGV[0]}/ =~ line then
    print line
  end
}
file.close
