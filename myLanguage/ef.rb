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
    'for' => :for,
    'in' => :in
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
    loop {
      token = get_token()
      unless token == :add || token == :sub
        unget_token(token)
        break
      end
      result = [token, result, term()]
    }
    return result
  end

  def term()
    result = factor()
    loop {
      token = get_token()
      unless token == :mul || token == :div
        unget_token(token)
        break
      end
      result = [token, result, factor()]
    }
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
      fail Exception, 'unexpected token' unless get_token() == :rpar
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

  def my_if()
    condition = get_l_brace_sentence()

    return [:if, judge(condition), s_block()]
  end

  # blockの中身を取得
  def s_block()
    block = ''
    if @code =~ /(?<paren>{(?:[^{}]|\g<paren>)*})/
      block = $1
      @code = $'

      if block =~ /({)/
        block = $'
      else
        fail Exception, "can not find '{'"
      end

      if block =~ /\A\s*(.+)(})/m
        block = $1
      else
        fail Exception, "can not find '}'"
      end

    else
      fail Exception, "can not find '{}'"
    end

    code, result = @code, @result
    @code = block
    sentences()
    block = @result
    @code, @result = code, result
    block.unshift(:block)
  end

  # '{'の左の式を取得
  def get_l_brace_sentence()
    condition = ''
    if @code =~ /\A\s*(.+)(\s+{)/
      @code = $2 + $'
      condition = $1
    end
    return condition
  end

  # if文などの条件式を取得
  def judge(condition)
    code, result = @code, @result
    @code = condition

    token = get_token()
    token2 = get_token()
    unget_token(token2)
    unget_token(token)

    if token.is_a?(Numeric) || token2 == :add || token2 == :sub || token2 == :mul || token2 == :div
      sentences()
      condition = @result
    elsif token == :dQuot
      condition = [token2]
    else
      condition = [[:variable, condition]]
    end

    @code, @result = code, result
    condition.unshift(:condition)
    return condition
  end

  def my_for()
    variable = get_token()
    fail Exception, "can not find 'in'" unless get_token() == :in

    num = frequency(get_l_brace_sentence())
    block = s_block()

    return [:for, variable, num, block]
  end

  # ループ回数を取得
  def frequency(code)
    first = 0
    finish = 0
    if code =~ /\A\s*(\d+)...(\d+)\s*\z/
      first = $1
      finish = $2
    end
    return [:frequency, first.to_i, finish.to_i]
  end

  def sentences()
    @result = []
    loop {
      break if @code =~ /\A\s+\z/ || @code == ''
      @result << sentence()
    }
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
      when :print
        return [:print, call()]
      when :if
        return my_if()
      when :for
        return my_for()
    end
  end


  #--------------------------------------------------------------------------
  #
  # evaluate
  #
  #--------------------------------------------------------------------------
  def evaluate()
    # p @result
    @result.each { |e|
      eval(e)
    }
    p @space
  end

  def eval(exp)
    if exp.instance_of?(Array)
      case exp[0]
        when :add
          return eval(exp[1]) + eval(exp[2])
        when :sub
          return eval(exp[1]) - eval(exp[2])
        when :mul
          return eval(exp[1]) * eval(exp[2])
        when :div
          return eval(exp[1]) / eval(exp[2])
        when :print
          p eval(exp[1])
        when :assignment
          @space[exp[1][0]] = exp[1][1]
        when :variable
          @space[exp[1]] ? eval(@space[exp[1]]) : '0'
        when :if
          e_if(exp[1], exp[2])
        when :condition
          e_cond(exp[1])
        when :block
          e_block(exp)
        when :for
          e_for(exp[1], exp[2], exp[3])
      end
    else
      return exp
    end
  end

  def e_if(condition, block)
    c = e_cond(condition)
    if c
      eval(block)
    end
  end

  def e_cond(condition)
    result = eval(condition[1])
    if result.to_s =~ /\d+/
      if result.to_f == 0.0
        return false
      else
        return true
      end
    else
      return true
    end
  end

  def e_block(block)
    block.each { |b|
      eval(b)
    }
  end

  def e_for(variable, freq, block)
    first = freq[1]
    finish = freq[2]
    loop {
      eval([:assignment, [variable, first] ])
      eval(block)
      break if first == finish
      first += 1
    }
  end
end

ef = Ef.new
begin
  File.open(ARGV[0]) { |file|
    ef.code = file.read
  }
rescue
  puts 'file not open'
  exit
end

ef.sentences()
ef.evaluate()
