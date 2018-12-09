def read_input
  input = []
  File.foreach( 'frequency_list.txt' ) do |line|
    input << line.to_f
  end
  input
end

def input
  @freq_input ||= read_input
end

def cum_freq
  input.reduce(0) { |acc, f| acc += f }
end

def first_repeat_cum_freq
  freq_history = Hash.new(0)

  freq_history[0] += 1
  curr_acc = 0

  while true
    curr_acc = input.reduce(curr_acc) do |acc, f|
      new_acc = acc + f
      if freq_history[new_acc] == 1
        return new_acc
      else
        freq_history[new_acc] += 1
      end
      new_acc
    end
  end
end

puts first_repeat_cum_freq
