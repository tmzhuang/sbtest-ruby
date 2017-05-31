require_relative 'sbengine'
require 'pry'
if __FILE__ == $PROGRAM_NAME
  app_root = "/home/tianming/proj/sbengine"
  bundles_root = "/home/tianming/proj/bundles"
  sbengine = SBEngine.new(app_root, bundles_root)
  puts sbengine.get_launch_time(bundle: "AddressBook")
end
