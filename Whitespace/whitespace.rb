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
      if @cmd == :push
        @param = eval("0b#{$1[1..-1].tr(" \t", '01')}")
        @param *= -1 if ($1[0] == ?\t)
      else
        @param = eval("0b#{Regexp.last_match(1).tr(" \t", '01')}")
      end
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
      _, cmd, parm = @tokens[@pc]
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

      when :store
        value = @stack.pop
        address = @stack.pop
        @heap[address] = value
      when :retrive then @stack.push @heap[@stack.pop]

      when :label
      when :cell
        @call.push(@pc)
        jump(parm)
      when :jump then jump(parm)
      when :jz then jump(parm) if @stack.pop == 0
      when :jn then jump(parm) if @stack.pop < 0
      when :ret then @pc = @call.pop
      when :exit then exit

      when :outchar then print @stack.pop.chr
      when :outnum then print @stack.pop
      when :readchar then @heap[@stack.pop] = $stdin.gets
      when :readnum then @heap[@stack.pop] = $stdin.gets.to_i

      else fail Exception, 'Unknown'
      end
    end
  end

  def arithmetic(op)
    b = @stack.pop
    a = @stack.pop
    @stack.push eval("a #{op} b")
  end

  def jump(label)
    @tokens.each_with_index do |token, i|
      if token == [:flow, :label, label]
        @pc = i
        break
      end
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

Executor.new(Tokenizer.new(file).tokens).run
