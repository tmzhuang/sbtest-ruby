class SBEvent
  class << self
    def event_pattern
      # Examples:
      # EVENT  [341.380]:IO: Queue [1] gre.keydown
      # EVENT  [341.380]:IO: Dispatch [gre.keydown]
      %r{ 
      ^EVENT\s{2}  # EVENT followed by 2 spaces
      \[(?<time>.*)\]: # [time]: eg. [341.380]
      (?<type>.*): # TYPE:
      \s(?<action>\w*) # Action eg. Queue
      (.*)(?<name>gre.(\w*))[\]]? # Name eg. gre.keydown
        }x
    end

    def is_event?(line)
      line.match event_pattern
    end
  end

  attr_reader :time, :type, :action, :name
  def initialize(string)
    match = string.match SBEvent::event_pattern
    @time = match[:time]
    @type = match[:type]
    @action = match[:action]
    @name = match[:name]
  end
end
