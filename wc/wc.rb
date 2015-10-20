file = open(ARGV[0])
wordNum = 0
lineNum = 0
charNum = 0

file.each {|line|
  lineNum += 1
  charNum += line.size      # wcは改行文字も含んだバイト数を出力するので取り除く前に
  line.chomp!               # 改行を取り除く
  words = line.split(/\s+/) # スペースでsplit
  wordNum += words.size
}

puts "#{lineNum} #{wordNum} #{charNum} #{ARGV[0]}"
file.close
