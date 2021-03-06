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
 pid = Process.spawn("bundle exec spork #{framework}", out:
"/dev/null", err: "/dev/null")
 File.open(File.join(Rails.root, 'tmp', 'pids',
"spork.#{framework}.pid"), 'w') {|f| f << pid}

 puts "Starting #{framework} spork worker (PID: #{pid})"
end

def kill_spork_runner(framework)
 pid = IO.read(File.join(Rails.root, 'tmp', 'pids',
"spork.#{framework}.pid")).to_i

 puts "Killing #{framework} spork worker (PID: #{pid})"
 Process.kill("HUP", pid)
end
