class Tokenizer
  @@imps = {
    ' ' => :stack,
    '\t ' => :arithmetic,
    '\t\t' => :heap,
    '\n' => :flow,
    '\t\n' => :io
  }

  @@stack = {
    ' ' => :push,
    '\n ' => :dup,
    '\n\t' => :swap,
    '\n\n' => :discard
  }

  def initialize(program)
    @tokens = []
    @program = program.read
    tokenize
  end

  def tokenize
    @result = []
    while @program.length > 0
      # IMP
      if @program =~ /\A( |\n|\t[ \n\t])/
        imp = Regexp.last_match(1)
        p imp
        @program.gsub!(/\A( |\n|\t[ \n\t])/, '')
      else
        fail Exception, 'undefind IMP'
      end
      # unless @program.gsub!(/\A( |\n|\t[ \n\t])/, '')
      # command
      # param
      # @result << imp << cmd << prm
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
