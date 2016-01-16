class Ef
  @@keywords = {
    '+' => :add,
    '-' => :sub,
    '*' => :mul,
    '/' => :div,
    '%' => :mod,
    '(' => :lpar,
    ')' => :rpar,
    'print' => :print,
    '"' => :dQuot
  }

  attr_accessor :code

  def initialize()
    @code = ''
    @space = {}
  end

  def get_token()
    if @code =~ /\A\s*(#{@@keywords.keys.map { |t| Regexp.escape(t) } .join('|')})/
      @code = $'
      return @@keywords[$1]
    elsif @code =~ /\A\s*([0-9.]+)/
      @code = $'
      return $1.to_f
    elsif @code =~ /\A\s*([a-zA-z]\w*)/
      @code = $'
      return $1.to_s
    elsif @code =~ /\A\s*(\w+)/
      @code = $'
      return $1.to_s
    elsif @code =~ /\A\s*\z/
      return nil
    end
    return :bad_token
  end

  def unget_token(token)
    if token.is_a? Numeric
      @code = token.to_s + @code
    else
      @code = @@keywords.key(token) ? @@keywords.key(token) + @code : token + @code
    end
  end

  def expression()
    result = term()
    loop do
      token = get_token()
      unless token == :add || token == :sub
        unget_token(token)
        break
      end
      result = [token, result, term()]
    end
    return result
  end

  def term()
    result = factor()
    loop do
      token = get_token()
      unless token == :mul || token == :div
        unget_token(token)
        break
      end
      result = [token, result, factor()]
    end
    return result
  end

  def call()
    fail Exception, 'unexpected token' unless get_token() == :lpar
    token = get_token()
    if token == :dQuot
      if @code =~ /\A\s*(.+)(")/
        @code = $2 + $'
        result = $1.to_s
      end
      fail Exception, 'unexpected token' unless get_token() == :dQuot
      fail Exception, 'unexpected token' unless get_token() == :rpar
      return result
    else
      unget_token(token)
    end
    result = sentence()
    fail Exception, 'unexpected token' unless get_token() == :rpar
    return result
  end

  def factor()
    token = get_token()
    minusflg = 1
    if token == :sub
      minusflg = -1
      token = get_token()
    end
    if token.is_a? Numeric
      return token * minusflg
    elsif token == :lpar
      result = expression()
      unless get_token() == :rpar
        fail Exception, 'unexpected token'
      end
      return [:mul, minusflg, result]
    else
      fail Exception, 'unexpected token'
    end
  end

  def assign()
    vari = get_token()
    if @code =~ /\A\s*(=)/
      @code = $'
    else
      fail Exception, "can not find '='"
    end
    x = get_token()
    return [vari, x]
  end

  def sentences()
    @result = []
    loop do
      break if @code == "\n" || @code == ''
      @result << sentence()
    end
  end

  def sentence()
    token = get_token()
    if token.is_a? Numeric
      unget_token(token)
      return expression()
    end

    if token =~ /\A\s*([a-zA-z]\w*)/ && !token.instance_of?(Symbol)
      unget_token(token)
      return [:assignment, assign()]
    end

    case token
    when :print then return [:print, call()]
    end
  end

  def evaluate()
    p @result
    @result.each do |e|
      eval(e)
    end
    p @space
  end

  def eval(exp)
    if exp.instance_of?(Array)
      case exp[0]
      when :add then return eval(exp[1]) + eval(exp[2])
      when :sub then return eval(exp[1]) - eval(exp[2])
      when :mul then return eval(exp[1]) * eval(exp[2])
      when :div then return eval(exp[1]) / eval(exp[2])
      when :print then p eval(exp[1])
      when :assignment then @space[exp[1][0]] = exp[1][1]
      end
    else
      return exp
    end
  end
end

ef = Ef.new
begin
  File.open(ARGV[0]) do |file|
    ef.code = file.read
  end
rescue
  puts 'file not open'
  exit
end

ef.sentences()
ef.evaluate()
