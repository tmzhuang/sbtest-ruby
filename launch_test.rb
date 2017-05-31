require_relative 'helpers/launch_reporter.rb'
require_relative 'helpers/sbengine.rb'
require 'minitest/autorun'
require 'date'

class LaunchTest < Minitest::Test
  opts = [""]
  bundles = ['AddressBook','Thermostat']

  def setup
    ENV['BUILD_ID'] = '123' # This would be set by jenkins
    app_root = "./"
    bundles_root = "/home/tianming/proj/bundles"
    @sbengine = SBEngine.new(app_root, bundles_root)
    @report =
      { launch_report: {
        report_date: DateTime.now.iso8601,
        build: ENV['BUILD_ID'],
        platform: 'linux-x86'}
    }
  end

  opts.each do |opt|
    bundles.each do |bundle|
      define_method "test_launch_sbengine_using_opts_#{opt}_on_#{bundle}" do
        launch_time = @sbengine.get_launch_time(opts: opt, bundle:bundle)
        @report[:launch_report][:launch_options] = opt
        @report[:launch_report][:deployment_bundle] = bundle
        @report[:launch_report][:launch_time] = launch_time
      end
    end
  end

  def teardown
    LaunchReporter::submit(@report)
  end
end
