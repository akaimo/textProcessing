require 'optparse'

opt = OptionParser.new
OPTS = {}
opt.on('-w') { |v| OPTS[:w] = v }
opt.on('-l') { |v| OPTS[:l] = v }
opt.on('-c') { |v| OPTS[:c] = v }
opt.parse!(ARGV)

word_array = []
line_array = []
char_array = []

ARGV.each do |f|
  file = open(f)

  w_num = 0
  l_num = 0
  c_num = 0

  file.each do |line|
    l_num += 1
    c_num += line.size
    line.chomp! # remove LF
    words = line.split(/\s+/).reject(&:empty?) # split space
    w_num += words.size
  end

  word_array.push(w_num)
  line_array.push(l_num)
  char_array.push(c_num)

  file.close
end

def sum(ary)
  total = 0
  ary.each do |n|
    total += n
  end
  total
end

total_line = sum(line_array)
total_word = sum(word_array)
total_char = sum(char_array)
digit = [total_line, total_word, total_char].max.to_s.length + 2

ARGV.count.times do |n|
  if OPTS.empty?
    puts "#{format('%*d', digit, line_array[n])} \
    #{format('%*d', digit, word_array[n])} \
    #{format('%*d', digit, char_array[n])} " + ARGV[n]
  else
    OPTS.each do|key, value|
      if key == :l && value == true
        print format('%*d', digit, line_array[n])
      elsif key == :w && value == true
        print format('%*d', digit, word_array[n])
      elsif key == :c && value == true
        print format('%*d', digit, char_array[n])
      end
    end
    puts " #{ARGV[n]}"
  end
end

if ARGV.count > 1
  if OPTS.empty?
    puts "#{format('%*d', digit, total_line)} \
    #{format('%*d', digit, total_word)} \
    #{format('%*d', digit, total_char)} " + 'total'
  else
    OPTS.each do|key, value|
      if key == :l && value == true
        print format('%*d', digit, total_line)
      elsif key == :w && value == true
        print format('%*d', digit, total_word)
      elsif key == :c && value == true
        print format('%*d', digit, total_char)
      end
    end
    puts ' total'
  end
end
