class LaunchTimeRunner
  def init_event?(line)
    line =~ /IO: Queue \[1\] gre\.init/
  end

  def parse_result(result)
    init_event = ""
    result.each_line do |line|
      init_event = line if init_event?(line)
    end
    parse_init_event(init_event)
  end

  def parse_init_event(init_event)
    # Expecting init event to look like
    # EVENT  [0.074]:IO: Queue [1] gre.init 
    regexp = /EVENT\s+\[(.*)\]:IO:(.*)/
    # Extracting the elapsed time 0.074
    match = init_event.match(regexp)[1]
    match.to_f
  end

  # Returns launch time in ms
  def get_launch_time(opts, bundle)
    sbengine = Thread.new { run(opts, bundle) }
    iogen = Thread.new { run_iogen(bundle) }
    sbengine.join
    iogen.join

    # Since sbengine ran in verbose mode, we
    # parse the log for timestamp on the gre.init event.
    (parse_result(sbengine.value) * 1000).round
  end
end
