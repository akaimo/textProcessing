class Tokenizer
  @@imps = {
    ' ' => :stack,
    "\t " => :arithmetic,
    "\t\t" => :heap,
    "\n" => :flow,
    "\t\n" => :io
  }

  @@stack = {
    ' ' => :push,
    "\n " => :dup,
    "\n\t" => :swap,
    "\n\n" => :discard
  }

  @@arithmetic = {
    '  ' => :add,
    " \t" => :sub,
    " \n" => :mul,
    "\t " => :div,
    "\t\t" => :mod
  }

  @@heap = {
    ' ' => :store,
    "\t" => :retrive
  }

  @@flow = {
    '  ' => :label,
    " \t" => :cell,
    " \n" => :jump,
    "\t " => :jz,
    "\t\t" => :jn,
    "\t\n" => :ret,
    "\n\n" => :exit
  }

  @@io = {
    '  ' => :outchar,
    " \t" => :outnum,
    "\t " => :readchar,
    "\t\t" => :readnum
  }

  @@param = [:stack, :label, :cell, :jump, :jz, :jn]

  def initialize(program)
    @tokens = []
    @program = program.read
    tokenize
  end

  def tokenize
    @result = []
    while @program.length > 0
      imp
      command
      if @@param.include?(@imp)
        parameter
      end
    end

    p @result
  end

  def imp
    if @program =~ /\A( |\n|\t[ \n\t])/
      @imp = @@imps[Regexp.last_match(1)]
      p @imp
      @result << @imp
      @program.sub!(/\A( |\n|\t[ \n\t])/, '')
    else
      fail Exception, 'undefind IMP'
    end
  end

  def command
    case @imp
    when :stack then stack
    when :arithmetic then arithmetic
    when :heap then heap
    when :flow then flow
    when :io then io
    end
  end

  def stack
    if @program =~ /\A( |\n[ \t\n])/
      @cmd = @@stack[Regexp.last_match(1)]
      @program.sub!(/\A( |\n[ \t\n])/, '')
      p @cmd
      @result << @cmd
    else
      fail Exception, 'undefind stack command'
    end
  end

  def arithmetic
    p 'arithmetic'
  end

  def heap
    p 'heap'
  end

  def flow
    p 'flow'
  end

  def io
    if @program =~ /\A( [ \t]|\t[ \t])/
      @cmd = @@io[Regexp.last_match(1)]
      @program.sub!(/\A( [ \t]|\t[ \t])/, '')
      p @cmd
      @result << @cmd
    else
      fail Exception, 'undefind io command'
    end
  end

  def parameter
    if @program =~ /\A([ \t]+\n)/
      @param = Regexp.last_match(1)
      p @param
      @result << @param
      @program.sub!(/\A([ \t]+\n)/, '')
    else
      fail Exception, 'undefind Parameters'
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

Tokenizer.new(file)
