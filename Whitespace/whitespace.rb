class Tokenizer
  @@imps = {
    ' ' => :stack,
    "\t " => :arithmetic,
    "\t\t" => :heap,
    "\n" => :flow,
    "\t\n" => :io
  }

  @@cmd = {
    stack: {
      ' ' => :push,
      "\n " => :dup,
      "\n\t" => :swap,
      "\n\n" => :discard
    },
    arithmetic: {
      '  ' => :add,
      " \t" => :sub,
      " \n" => :mul,
      "\t " => :div,
      "\t\t" => :mod
    },
    heap: {
      ' ' => :store,
      "\t" => :retrive
    },
    flow: {
      '  ' => :label,
      " \t" => :cell,
      " \n" => :jump,
      "\t " => :jz,
      "\t\t" => :jn,
      "\t\n" => :ret,
      "\n\n" => :exit
    },
    io: {
      '  ' => :outchar,
      " \t" => :outnum,
      "\t " => :readchar,
      "\t\t" => :readnum
    }
  }

  @@param = [:push, :label, :cell, :jump, :jz, :jn]

  def initialize(program)
    @tokens = []
    @program = program.read.gsub(/[^ \t\n]/, '')
    tokenize
  end

  def tokenize
    @result = []
    while @program.length > 0
      @imp = nil; @cmd = nil; @param = nil
      imp
      command
      parameter if @@param.include?(@cmd)
      @result << [@imp, @cmd, @param]
    end

    p @result
  end

  def imp
    match = /\A( |\n|\t[ \n\t])/
    if @program =~ match
      @imp = @@imps[Regexp.last_match(1)]
      # p @imp
      @program.sub!(match, '')
    else
      fail Exception, 'undefind IMP'
    end
  end

  def command
    match = /\A(#{@@cmd[@imp].keys.join('|')})/
    unless @program =~ match
      fail Exception, 'undefind command'
    end
    @program.sub!(match, '')
    @cmd = @@cmd[@imp][Regexp.last_match(1)]
    # p @cmd
  end

  def parameter
    match = /\A([ \t]+\n)/
    if @program =~ match
      @param = Regexp.last_match(1)
      # p @param
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
