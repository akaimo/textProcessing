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
    addr = '(?:\d+|[.$,;]|\/.*\/)'
    cmnd = '(?:wq|[acdefgijkmnpqrsw=]|\s|\z)'
    prmt = '(?:.*)'
    @cmd = @cmd.match(/\A(?:(#{addr})(?:(,)?(#{addr}))?)?(#{cmnd})(#{prmt})?\z/)
    p @cmd # debug

    @output = true
    if @cmd.nil?
      @result = '?'
    else
      execute_command
    end
  end

  def print
    puts @result if @output == true
    puts "now_line: #{@current_line}" # debug
  end

  def execute_command
    @result = '?'
    case @cmd[4]
    when ''  then newline
    when 'a' then add
    when 'p' then print_line
    when 'q' then exit
    end
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
    if @cmd[1].to_i > @buffer.count || @cmd[1].to_i == 0
      @result = '?'
    else
      @current_line = @cmd[1].to_i
      @result = @buffer[@current_line - 1]
    end
  end

  def add
    return unless @cmd[5] == ''

    @new_buffer = []
    loop do
      str = STDIN.gets
      break if str == ".\n"
      @new_buffer << str
    end

    @current_line = @cmd[1].to_i unless @cmd[1].nil?

    @new_buffer.each do |str|
      @buffer.insert(@current_line, str)
      @current_line += 1
    end

    @output = false
  end

  def print_line
    if @cmd[1].nil?
      @result = @buffer[@current_line - 1]
    elsif @cmd[3].nil?
      @current_line = @cmd[1].to_i
      @result = @buffer[@current_line - 1]
    else
      print_line_addr
    end
  end

  def print_line_addr
    first_line = @cmd[1].to_i
    last_line = @cmd[3].to_i
    return if first_line > last_line

    @print_array = []
    first_line.upto(last_line) do |n|
      @print_array << @buffer[n - 1]
    end

    @current_line = last_line
    @result = @print_array
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
