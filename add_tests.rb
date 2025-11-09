#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'carrer.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the test target
test_target = project.targets.find { |t| t.name == 'carrerTests' }

if test_target.nil?
  puts "Error: Could not find carrerTests target"
  exit 1
end

# Find the carrerTests group
tests_group = project.main_group.find_subpath('carrerTests', false)

if tests_group.nil?
  puts "Error: Could not find carrerTests group"
  exit 1
end

# Test files to add
test_files = [
  'AppViewModelTests.swift',
  'SnowflakeServiceTests.swift',
  'CanadianNOCIntegrationTests.swift'
]

# Add each test file
test_files.each do |filename|
  # Check if file already exists in group
  existing = tests_group.files.find { |f| f.path == filename }

  if existing
    puts "File #{filename} already in project, skipping..."
    next
  end

  # Add file reference
  file_ref = tests_group.new_reference(filename)

  # Add to build phase
  test_target.source_build_phase.add_file_reference(file_ref)

  puts "✅ Added #{filename} to project and test target"
end

# Save the project
project.save

puts ""
puts "✅ Successfully added Phase 0 test files to Xcode project!"
puts ""
puts "Next steps:"
puts "1. Run tests: xcodebuild test -scheme carrer -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:carrerTests"
puts "2. Or open Xcode and press ⌘+U to run tests"
