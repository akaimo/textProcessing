# linux command 'ed'
class REPL
  def initialize
    @cmd = nil

    loop do
      read
      evel
      print
    end
  end

  def read
    @cmd = STDIN.gets
  end

  def evel
  end

  def print
    puts @cmd
  end
end

REPL.new
