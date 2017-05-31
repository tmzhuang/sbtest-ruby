require 'open3'
require 'pry'
require 'timeout'

require_relative 'sbevent.rb'

class SBEngine
  attr_reader :app_root, :bundles_root, :bin, :plugins, :lib
  def initialize(app_root, bundles_root)
    @app_root = app_root
    @bundles_root = bundles_root
    @bin = File.join(@app_root, 'bin')
    @plugins = File.join(@app_root, 'plugins')
    @lib = File.join(@app_root, 'lib')
  end

  # Run and collect data until the first instance of end_event is found 
  # or sbengine hangs for wait_max seconds, whichever comes first
  # Returns a list of events
  def collect_data(opts: "", 
                   bundle:,
                   wait_max: 3,
                   event_names: ["gre.init"],
                   end_event: "gre.init")
    events = []
    sbengine = File.join(@bin,'sbengine')
    # Add verbosity arg to sbengine 
    # This is required to get the event necesssary for 
    # calculating the launch time
    opts += " -vvvv"
    # Set necessary options
    ENV['SB_PLUGINS'] = @plugins
    ENV['LD_LIBRARY_PATH'] = @lib

    bundle = File.join(@bundles_root, bundle) + '.gapp'

    # Build command string to be executed
    cmd = "#{sbengine} #{opts} #{bundle}"
    # Run command with popen since this allows us to stream the processes
    # STDOUT output
    Open3.popen2(cmd) do |i,o,t|
      begin
        # Kill process if we have to wait longer than wait_max
        Timeout::timeout(wait_max) do
          # Parse each line of stdout output from sbengine
          while line=o.gets do 
            # If the line looks like an event
            if SBEvent::is_event?(line)
              # Parse it into an event object
              event = SBEvent.new(line)
              # If it's a event we're interested in, add it to
              # the returning list of events
              if event_names.include? event.name
                events << event
              end
              break if event.name == end_event
            end
          end
        end
      rescue Timeout::Error
        Process.kill("KILL", t.pid)
      end
    end
    { events: events }
  end

  # Returns launch time in ms
  def get_launch_time(opts: "", bundle:)
    events = collect_data(opts: opts, bundle: bundle)[:events]
    if events.size == 1 && events.first.name == "gre.init"
      return (events.first.time * 1000).round
    end
    return -1
  end
end
