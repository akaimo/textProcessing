# linux command 'ed'
class REPL
  def initialize(buffer)
    @buffer = buffer
    @current_line = buffer.count
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
      @result = '?'
      newline if @cmd[3] == ''
      exit if @cmd[3] == 'q'
    end
  end

  def print
    puts @result
    puts "now_line: #{@current_line}" # debug
  end

  # command
  def newline
    if @cmd[1].nil?
      newline_none_addr
    else
      newline_addr
    end
  end

  def newline_none_addr
    if @current_line == @buffer.count
      @result = '?'
    else
      @current_line += 1
      @result = @buffer[@current_line - 1]
    end
  end

  def newline_addr
    if @cmd[1].to_i > @buffer.count
      @result = '?'
    else
      @current_line = @cmd[1].to_i
      @result = @buffer[@current_line - 1]
    end
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
