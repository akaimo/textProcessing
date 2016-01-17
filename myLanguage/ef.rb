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
    '"' => :dQuot,
    'if' => :if,
    '{' => :lwave,
    '}' => :rwave
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
    return if token == :bad_token || token == nil
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
    fail Exception, "can not find '('" unless get_token() == :lpar
    token = get_token()
    token2 = get_token
    unget_token(token2)

    if token == :dQuot
      if @code =~ /\A\s*(.+)(")/
        @code = $2 + $'
        result = $1.to_s
      end
      fail Exception, 'can not find `"`' unless get_token() == :dQuot
    elsif token.is_a?(Numeric) || token2 == :add || token2 == :sub || token2 == :mul || token2 == :div
      unget_token(token)
      result = sentence()
    else
      result = [:variable, token]
    end

    fail Exception, "can not find ')'" unless get_token() == :rpar
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
    elsif token == :dQuot  # 文字列の計算
      if @code =~ /\A\s*(.+)(")/
        @code = $2 + $'
        result = $1.to_s
      end
      fail Exception, 'can not find `"`' unless get_token == :dQuot
      return result
    else  # 変数の計算
      return [:variable, token]
    end
  end

  def assign()
    vari = get_token()
    if @code =~ /\A\s*(=)/
      @code = $'
    else
      fail Exception, "can not find '='"
    end

    token = get_token()
    if token == :dQuot
      if @code =~ /\A\s*(.+)(")/
        @code = $2 + $'
        result = $1.to_s
      end
      fail Exception, 'can not find `"`' unless get_token() == :dQuot
      return [vari, result]
    else
      unget_token(token)
    end

    return [vari, sentence()]
  end

  def myIf()
    condition = ''
    if @code =~ /\A\s*(.+)(\s+{)/
      @code = $2 + $'
      condition = $1
    end
    condition = judge(condition)
    # p condition

    fail Exception, "can not find '{'" unless get_token() == :lwave
    block = ''
    if @code =~ /\A\s*(.*)(})/m
      @code = $2 + $'
      block = $1
    end
    # p block
    fail Exception "can not find '}'" unless get_token() == :rwave

    code, result = @code, @result
    @code = block
    sentences()
    block = @result
    @code, @result = code, result
    block.unshift(:block)
    # p block

    return [:if, condition, block]
  end

  def judge(condition)
    if condition =~ /\d+/
      return [:crndition, condition.to_f]
    else
      return [:condition, [:variable, condition]]
    end
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

    # 計算
    token2 = get_token()
    unget_token(token2)
    if token.is_a?(Numeric) || token2 == :add || token2 == :sub || token2 == :mul || token2 == :div
      unget_token(token)
      return expression()
    end

    # 変数
    if token =~ /\A\s*([a-zA-z]\w*)/ && !token.instance_of?(Symbol)
      unget_token(token)
      return [:assignment, assign()]
    end

    case token
    when :print then return [:print, call()]
    when :if then return myIf()
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
      when :variable then @space[exp[1]] ? eval(@space[exp[1]]) : '0'
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
