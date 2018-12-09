def checksum_counter(id)
  counter = Hash.new(0)

  result = {2 => 0, 3 => 0}

  id.split('').each do |c|
    counter[c] += 1
  end

  counter.to_a.map(&:last).each do |count|
    result[2] = 1 if count == 2
    result[3] = 1 if count == 3
    return result if result[2] == 1 && result[3] == 1
  end

  result
end

def generate_checksum
  twos = 0
  threes = 0

  read_input.map {|id| checksum_counter(id) }.each do |counter|
    twos += counter[2]
    threes += counter[3]
  end

  twos * threes
end

def read_input
  @input ||= []
  File.foreach('box_ids.txt') do |id|
    @input << id
  end
  @input
end

def string_diff(str1, str2)
  return {diff: -1, curr_diff_index: nil} if str1.length != str2.length

  diff = 0
  curr_diff_index = nil

  str1.length.times do |i|
    unless str1[i] == str2[i]
      diff += 1
      curr_diff_index = i
    end
  end

  {diff: diff, curr_diff_index: curr_diff_index}
end

def sanitze_two_correct_with_diff_hash(ids, diff_hash)
  diff_index = diff_hash[:curr_diff_index]

  result = ids.map { |id| id[0...diff_index] +  id[diff_index + 1 ...-1]}.uniq
  return result.one? ? result.first : throw('Ids have more than one difference')
end

# find two ids with exactly one char diff
def find_two_correct
  two_correct = nil
  two_correct_diff_hash = nil

  read_input.each_with_index do |id1|
    break if two_correct
    read_input.each_with_index do |id2|
      string_diff_result = string_diff(id1, id2)
      if string_diff_result[:diff] == 1 && string_diff_result[:curr_diff_index]
        two_correct = sanitze_two_correct_with_diff_hash([id1, id2], string_diff_result)
        break
      end
    end
  end

  puts two_correct
end

puts find_two_correct