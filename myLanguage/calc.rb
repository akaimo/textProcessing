class Calc
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

  def initialize
    @code = ''
  end

  def get_token()
    if @code =~ /\A\s*(#{@@keywords.keys.map { |t| Regexp.escape(t) } .join('|')})/
      @code = $'
      return @@keywords[$1]
    elsif @code =~ /\A\s*([0-9.]+)/
      @code = $'
      return $1.to_f
    elsif @code =~ /\A\s*(\w+)/
      @code = $'
      return $1.to_s
    elsif @code =~ /\A\s*\z/
      return nil
    end
    :bad_token
  end

  def unget_token(token)
    if token.is_a? Numeric
      @code = token.to_s + @code
    else
      @code = @@keywords.key(token) ? @@keywords.key(token) + @code : @code
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
    result
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
    result
  end

  def call()
    fail Exception, 'unexpected token' unless get_token() == :lpar
    token = get_token()
    if token == :dQuot
      result = get_token
      fail Exception, 'unexpected token' unless get_token() == :dQuot
      return result
    else
      unget_token(token)
    end
    result = expression()
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
    elsif token == :print
      return [:print, call()]
    else
      fail Exception, 'unexpected token'
    end
  end

  def eval(exp)
    if exp.instance_of?(Array)
      case exp[0]
      when :add then return eval(exp[1]) + eval(exp[2])
      when :sub then return eval(exp[1]) - eval(exp[2])
      when :mul then return eval(exp[1]) * eval(exp[2])
      when :div then return eval(exp[1]) / eval(exp[2])
      when :print then p eval(exp[1])
      end
    else
      return exp
    end
  end
end

calc = Calc.new
loop do
  print 'exp> '
  calc.code = STDIN.gets
  exit if calc.code == "quit\n"
  ex = calc.expression()
  calc.eval(ex)
end
