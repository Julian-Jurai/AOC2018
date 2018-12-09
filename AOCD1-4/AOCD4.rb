require 'pry-byebug'
require 'date'
require "awesome_print"

class Guard
  attr_reader :id
  def initialize(id)
    @id = id
    @shift_log = []
  end

  def add_to_shift_log(log)
    @shift_log << log
  end

  def total_sleep_time
    total_sleep = 0

    sleeping = false
    fell_asleep_at = nil
    woke_up_at = nil
    slept = 0

    @shift_log.each do |shift|
      if is_sleeping?(shift)
        sleeping = true
        fell_asleep_at = DateTime.parse(shift[:date]).to_time
      elsif sleeping && woke_up?(shift)
        woke_up_at = DateTime.parse(shift[:date]).to_time
        sleeping = false
        slept = (woke_up_at - fell_asleep_at) / 60
        total_sleep += slept

        slept = 0
        fell_asleep_at = nil
        woke_up_at = nil
      end
    end
    total_sleep
  end


  def sleepiest_minute
    # 146622
    @midnight_hour_activities ||=  track_midnight_hour_activities_sleep_activity(sleep_intervals)
    @midnight_hour_activities.max_by { |min, count| count }.first
  end

  def sleepiest_minute_with_count
    # 146622
    @midnight_hour_activities ||=  track_midnight_hour_activities_sleep_activity(sleep_intervals)
    @midnight_hour_activities.max_by { |min, count| count }
  end


  private

  def sleep_intervals
    sleep_intervals = []

    sleeping = false
    fell_asleep_at = nil
    woke_up_at = nil

    @shift_log.each do |shift|
      if is_sleeping?(shift)
        sleeping = true
        fell_asleep_at = DateTime.parse(shift[:date]).to_time
      elsif sleeping && woke_up?(shift)
        sleeping = false
        woke_up_at = DateTime.parse(shift[:date]).to_time

        sleep_intervals << [fell_asleep_at.min, woke_up_at.min]
        fell_asleep_at = nil
        woke_up_at = nil
      end
    end

    sleep_intervals
  end

  def track_midnight_hour_activities_sleep_activity(sleep_intervals)
    midnight_hour_activities = []

    sleep_intervals.each do |interval|
      sleep_start = interval.first
      sleep_end = interval.last
      duration = Array.new(60, 0).tap do |arr|
        (sleep_start...sleep_end).each { |i| arr[i] = 1 }
      end
      midnight_hour_activities << duration
    end

    frequency_tracker = Hash.new(0)

    (0...60).each do |i|
      midnight_hour_activities.each do |dur_arr|
        if dur_arr[i] > 0
          frequency_tracker[i] += 1
        end
      end
    end

    frequency_tracker
  end

  def is_sleeping?(shift)
    shift[:action] == :sleep_start
  end

  def woke_up?(shift)
    shift[:action] == :woke_up
  end
end

FILE = "guard_schedules.txt"
# FILE = "guard_schedules_test.txt"

def guards
  @guards ||= build_guards(read_input)
end

def build_guards(input)
  guards_hash = {}
  curr_guard = nil

  input.each do |input_hash|
    shift_log = { date: input_hash[:date], action: input_hash[:action] }
    if input_hash[:guard_declaration]
      guard_id = input_hash[:guard_id]
      curr_guard = guards_hash[guard_id] || Guard.new(guard_id)
    end

    curr_guard.add_to_shift_log(shift_log)

    guards_hash[curr_guard.id] ||= curr_guard
  end

  guards_hash
end

def read_input
  input = []
  File.foreach(FILE) do |line|
    input << parse_input(line)
  end
  input.sort_by{ |h| h[:date] } #sorts chronologically
end

def parse_input(input)
  # [1518-07-20 00:03] Guard #811 begins shift
  # [1518-10-07 00:15] wakes up
  # [1518-07-31 00:23] falls asleep

  guard_declaration = false
  guard_id = nil
  action = nil
  message = input.split(']').last.strip
  action_text = message.split(' ')[-2..-1].join(' ')

  action = nil

  case action_text
    when "begins shift"
      action = :shift_start
    when "falls asleep"
      action = :sleep_start
    when "wakes up"
      action = :woke_up
  end

  date = input.split(']').first[1..-1]

  if message[0..."Guard".length] == "Guard"
    guard_declaration = true
    guard_id = message.split(' ')[-3][1..-1]
  end

  {
    date: date,
    guard_declaration: guard_declaration,
    guard_id: guard_id.to_i,
    action: action,
  }
end

def sleepiest_guard
  @sleepiest_guard ||= guards.max_by { |id, guard| guard.total_sleep_time}.last
end

def highest_sleep_midnight_minute_count
  guards
  .map { |id, g| {id: g.id, min_count: g.sleepiest_minute_with_count} }
  .max_by { |min_count_hash| min_count_hash[:min_count]&.last || -1 }
end

a = highest_sleep_midnight_minute_count
ap a[:id] * a[:min_count].first

