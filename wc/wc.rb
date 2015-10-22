require 'optparse'

opt = OptionParser.new
OPTS = {}

opt.on('-w') {|v| OPTS[:w] = v }
opt.on('-l') {|v| OPTS[:l] = v }
opt.on('-c') {|v| OPTS[:c] = v }

opt.parse!(ARGV)
# p ARGV
# p OPTS

tWordNum = 0
tLineNum = 0
tCharNum = 0

ARGV.each do |f|
  file = open(f)

  wNum = 0
  lNum = 0
  cNum = 0

  file.each do |line|
    lNum += 1
    cNum += line.size  # wcは改行文字も含んだバイト数を出力するので取り除く前に
    line.chomp!           # 改行を取り除く
    words = line.split(/\s+/).reject{|w| w.empty?}  # スペースでsplit、行頭がスペースの場合wordsに入ってしまうので取り除く
    wNum += words.size
  end

  if OPTS.empty?
    puts "#{lNum} #{wNum} #{cNum} #{f}"
  else
    OPTS.each{|key, value|
      if key == :l && value == true
        print "#{lNum} "
      elsif key == :w && value == true
        print  "#{wNum} "
      elsif key == :c && value == true
        print "#{cNum} "
      end
    }
    puts f
  end

  tLineNum += lNum
  tWordNum += wNum
  tCharNum += cNum
  
  file.close
end

if ARGV.count > 1
  puts "#{tLineNum} #{tWordNum} #{tCharNum} total"
end
