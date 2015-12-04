class Tokenizer
  def initialize(program)
    @tokens = []
    @program = []
    program.each do |line|
      @program << line
    end
    p @program
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
