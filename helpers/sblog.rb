class SBEvent
  class << self
    def event_pattern
      /^EVENT\s{2}\[(?<time>.*)\]:(?<type>.*):\s(?<action>\w*)(.*)(?<event>gre.(\w*))[\]]?/
    end

    def is_event?(line)
      line.match event_pattern
    end
  end
end
