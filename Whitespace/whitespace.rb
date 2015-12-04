class Tokenizer
  @@imps = {
    ' ' => :stack,
    '\t ' => :arithmetic,
    '\t\t' => :heap,
    '\n' => :flow,
    '\t\n' => :io
  }

  def initialize(program)
    @tokens = []
    @program = program.read
    tokenize
  end

  def tokenize
    p @program
    @result = []
    while @program.length > 0
      # IMP
      imp = @program.match(/\A( |\n|\t[ \n\t])/)
      imp = @@imps[imp[1]]
      p imp
      break
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
