require 'optparse'

opt = OptionParser.new
OPTS = {}

opt.on('-w') {|v| OPTS[:w] = v }
opt.on('-l') {|v| OPTS[:l] = v }
opt.on('-c') {|v| OPTS[:c] = v }

opt.parse!(ARGV)
# p ARGV
# p OPTS

wordNum = 0
lineNum = 0
charNum = 0

fileName = ARGV[0]
#fileName = "text.txt"
file = open(fileName)

file.each {|line|
  lineNum += 1
  charNum += line.size  # wcは改行文字も含んだバイト数を出力するので取り除く前に
  line.chomp!           # 改行を取り除く
  words = line.split(/\s+/).reject{|w| w.empty?}  # スペースでsplit、行頭がスペースの場合wordsに入ってしまうので取り除く
  wordNum += words.size
}

if OPTS.empty?
  puts "#{lineNum} #{wordNum} #{charNum} #{fileName}"
else
  OPTS.each{|key, value|
    if key == :l && value == true
      print "#{lineNum} "
    elsif key == :w && value == true
      print  "#{wordNum} "
    elsif key == :c && value == true
      print "#{charNum} "
    end
  }
  puts fileName
end

file.close
