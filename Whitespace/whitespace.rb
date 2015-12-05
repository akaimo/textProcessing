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
    match = /\A( |\n|\t[ \n\t])/
    if @program =~ match
      @imp = @@imps[Regexp.last_match(1)]
      @result << @imp
      @program.sub!(match, '')
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
    @result << @cmd
  end

  def stack
    match = /\A( |\n[ \t\n])/
    if @program =~ match
      @cmd = @@stack[Regexp.last_match(1)]
      @program.sub!(match, '')
    else
      fail Exception, 'undefind stack command'
    end
  end

  def arithmetic
    match = /\A( [ \t\n]|\t[ \t])/
    if @program =~ match
      @cmd = @@arithmetic[Regexp.last_match(1)]
      @program.sub!(match, '')
    end
  end

  def heap
    match = /\A( |\t)/
    if @program =~ match
      @cmd = @@heap[Regexp.last_match(1)]
      @program.sub!(match, '')
    else
      fail Exception, 'undefind heap command'
    end
  end

  def flow
    match = /\A( [ \t\n]|\t[ \t\n]|\n\n)/
    if @program =~ match
      @cmd = @@flow[Regexp.last_match(1)]
      @program.sub!(match, '')
    else
      fail Exception, 'undefind flow command'
    end
  end

  def io
    match = /\A( [ \t]|\t[ \t])/
    if @program =~ match
      @cmd = @@io[Regexp.last_match(1)]
      @program.sub!(match, '')
    else
      fail Exception, 'undefind io command'
    end
  end

  def parameter
    match = /\A([ \t]+\n)/
    if @program =~ match
      @param = Regexp.last_match(1)
      @result << @param
      @program.sub!(match, '')
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
