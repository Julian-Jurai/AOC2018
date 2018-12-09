
# File handlers
FILE = "./polymer.txt"

def read_input
  polymer = nil
  File.foreach(FILE) { |line| polymer = line }
  polymer
end

def polymer
  @polymer ||= read_input
end

polymer.length