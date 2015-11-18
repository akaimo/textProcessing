# linux command 'ed'
class REPL
  def initialize(buffer)
    @buffer = buffer
  end

  def start
    loop do
      read
      evel
      print
    end
  end

  def read
    @cmd = STDIN.gets.chomp
  end

  def evel
    addr = '(?:\d+|[.$,:]|\/.*\/)'
    cmnd = '(?:wq|[acdefgijkmnpqrsw=]|\s|\z)'
    prmt = '(?:.*)'
    @cmd = @cmd.match(/\A(?:(#{addr})(?:,(#{addr}))?)?(#{cmnd})(#{prmt})?\z/)
    p @cmd # debug

    if @cmd.nil?
      @result = '?'
    else
      # execution command
      exit if @cmd[3] == 'q'
      @result = @cmd[0]
    end
  end

  def print
    puts @result
  end
end

# main
if ARGV[0].nil?
  puts 'usage: ed [file]'
  exit
end

begin
  file = open(ARGV[0])
rescue => ex
  puts ex
  exit
end

buffer = []
file.each do |line|
  buffer.push(line)
end
file.close

repl = REPL.new(buffer)
repl.start
