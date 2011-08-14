# -*- ruby -*-

def run_with_ruby(file)
  return unless File.exist?(file)
  puts   "Running #{file}"
  system "ruby", file
  puts
end

def run_spec(file)
  unless File.exist?(file)
    # puts "#{file} does not exist"
    return
  end

  puts   "Running #{file}"
  system "bundle exec rspec #{file}"
  puts
end

watch("spec/.*/.*_spec\.rb") do |match|
  run_spec match[0]
end

watch("spec/.*_spec\.rb") do |match|
  run_spec match[0]
end

watch("lib/imw/(.*/)?(.*)\.rb") do |match|
  run_spec %{spec/#{match[1]}#{match[2]}_spec.rb}
end

watch("examples/(.*)/(.*)\.rb") do |match|
  run_with_ruby match[0]
end
