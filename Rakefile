require 'rspec/core/rake_task'

directory "coverage"

desc "Removed generated artefacts"
task :clobber do
  rm_rf "coverage"
  rm Dir.glob("**/coverage.data"), force: true
  puts "Clobbered"
end

desc "Complexity analysis"
task :metrics do
  print " Complexity Metrics ".center(80, "*") + "\n"
  print `find lib -name \\*.rb | xargs flog --continue`
  print "*" * 80+ "\n"
end

desc "Exercises specifications"
::RSpec::Core::RakeTask.new(:spec)

desc "Exercises specifications with coverage analysis"
task :coverage => :spec do
  require 'cover_me'
  CoverMe.complete!
end

task :default => [:clobber, :metrics, :coverage]
