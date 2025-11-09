#!/bin/bash

# Make the file executable
chmod +x fix-and-run.sh

# Move test file to proper location
if [ -f "carrer/carrerTests.swift" ]; then
  echo "Moving carrerTests.swift to carrerTests directory..."
  mkdir -p carrerTests
  mv carrer/carrerTests.swift carrerTests/carrerTests.swift
fi

# Update project.pbxproj to properly link XCTest
echo "Updating project configuration..."
plutil -convert xml1 carrer.xcodeproj/project.pbxproj -o /tmp/project.xml
sed -i '' 's|<string>carrer/carrerTests.swift</string>|<string>carrerTests/carrerTests.swift</string>|g' /tmp/project.xml
plutil -convert binary1 /tmp/project.xml -o carrer.xcodeproj/project.pbxproj

# Add XCTest framework to the test target
echo "Adding XCTest framework to test target..."
cat <<EOF > add_xctest.rb
#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'carrer.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the test target
test_target = nil
project.targets.each do |target|
  if target.name == 'carrerTests'
    test_target = target
    break
  end
end

if test_target
  # Add XCTest framework if it's missing
  xctest_framework_ref = project.frameworks_group.new_reference('System/Library/Frameworks/XCTest.framework')
  xctest_framework_ref.source_tree = 'SDKROOT'
  
  # Check if the framework is already added
  framework_already_added = false
  test_target.frameworks_build_phase.files.each do |build_file|
    if build_file.file_ref.path == 'System/Library/Frameworks/XCTest.framework'
      framework_already_added = true
      break
    end
  end
  
  # Add the framework to the target if it's not already added
  if !framework_already_added
    test_target.frameworks_build_phase.add_file_reference(xctest_framework_ref)
    puts "Added XCTest.framework to carrerTests target"
  else
    puts "XCTest.framework already added to carrerTests target"
  end
  
  # Save the project
  project.save
else
  puts "Couldn't find carrerTests target"
end
EOF

# Make the Ruby script executable and run it
chmod +x add_xctest.rb
if command -v ruby >/dev/null 2>&1 && command -v gem >/dev/null 2>&1; then
  # Check if xcodeproj gem is installed
  if ! gem list -i xcodeproj >/dev/null 2>&1; then
    echo "Installing xcodeproj gem..."
    sudo gem install xcodeproj
  fi
  
  # Run the Ruby script
  ruby add_xctest.rb
else
  echo "Ruby or RubyGems not found. Manual intervention required."
  echo "Please add XCTest.framework to your test target in Xcode."
fi

echo "Fix completed. Please clean and rebuild your project."