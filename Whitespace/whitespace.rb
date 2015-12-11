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

  attr_reader :tokens

  def initialize(program)
    @tokens = []
    @program = program.read.gsub(/[^ \t\n]/, '')
    tokenize
  end

  def tokenize
    while @program.length > 0
      @imp = nil; @cmd = nil; @param = nil
      imp
      command
      parameter if @@param.include?(@cmd)
      @tokens << [@imp, @cmd, @param]
    end
    # p @tokens
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
      # p @pram
      @program.sub!(match, '')
    else
      fail Exception, 'undefind Parameters'
    end
  end
end

class Executor
  def initialize(tokens)
    @tokens = tokens
  end

  def run
    @pc = 0
    @stack = []
    @heap = {}
    @call = []
    loop do
      imp, cmd, parm = @tokens[@pc]
      @pc += 1
      exit if @tokens.count < @pc
      case cmd
      when :push then @stack.push parm
      when :dup then @stack.push @stack[-1]
      when :swap then @stack[-1], @stack[-2] = @stack[-2], @stack[-1]
      when :discard then @stack.pop

      when :add then arithmetic('+')
      when :sub then arithmetic('-')
      when :mul then arithmetic('*')
      when :div then arithmetic('/')
      when :mod then arithmetic('%')
      end
    end
  end

  def arithmetic(op)
    @stack.push eval('@stack.pop #{op} @stack.pop')
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

Executor.new(Tokenizer.new(file).tokens).run
