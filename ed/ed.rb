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
    cmd = STDIN.gets
    @cmd = cmd.match(/[acdeDfhHijlmnpPqQrstuwWz=]/)
  end

  def evel
    if @cmd.nil?
      @result = '?'
    else
      # execution command
      exit if @cmd[0] == 'q'
      @result = @cmd[0]
    end
  end

  def print
    puts @result
  end
end

# main
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
