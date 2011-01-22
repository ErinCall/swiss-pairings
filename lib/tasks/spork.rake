require 'spork'
require 'spork/runner'

namespace :spork do
  desc 'Start a spork worker for all test frameworks'
  task :all => [:rspec, :cucumber]

  desc 'Start a spork worker for RSpec'
  task :rspec do
    run_spork_runner('rspec')
  end

  desc 'Start a spork worker for Cucumber'
  task :cucumber do
    run_spork_runner('cucumber')
  end

  desc 'Kill all the spork workers'
  task :kill do
    ['rspec', 'cucumber'].each do |f|
      kill_spork_runner(f)
    end
  end
end

def run_spork_runner(framework)
  pid = fork do
    File.open('/dev/null', 'w') do |f|
      STDOUT.reopen(f)
      STDERR.reopen(f)

      Spork::Runner.run([framework], STDOUT, STDERR)
    end
  end
  File.open(File.join(Rails.root, 'tmp', 'pids', "spork.#{framework}.pid"), 'w') {|f| f << pid}

  puts "RSpec #{framework} worker started (PID: #{pid})"
end

def kill_spork_runner(framework)
    pid = IO.read(File.join(Rails.root, 'tmp', 'pids', "spork.#{framework}.pid")).to_i

    puts "Killing #{framework} spork worker (PID: #{pid})"
    Process.kill("HUP", pid)
end
