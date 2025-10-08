#!/bin/bash

# Script to add analytics files to Xcode project

echo "Adding Analytics files to Xcode project..."

PROJECT_FILE="carrer.xcodeproj/project.pbxproj"

# Analytics files to add
declare -a files=(
    "carrer/Services/Analytics/ConversationAnalytics.swift"
    "carrer/Views/AIChat/ConversationAnalyticsDashboard.swift"
)

# Add each file to the project
for file in "${files[@]}"
do
    echo "Adding $file to project..."
    ruby -e "
    require 'xcodeproj'
    
    project_path = 'carrer.xcodeproj'
    project = Xcodeproj::Project.open(project_path)
    
    file_path = '$file'
    file_name = File.basename(file_path)
    
    # Find the appropriate group
    if file_path.include?('Services/Analytics')
        parent_group = project.main_group.find_subpath('carrer/Services/Analytics', true)
    elsif file_path.include?('Views/AIChat')
        parent_group = project.main_group.find_subpath('carrer/Views/AIChat', true)
    else
        parent_group = project.main_group.find_subpath('carrer', true)
    end
    
    # Add file reference
    file_ref = parent_group.new_reference(file_path)
    
    # Add to main target
    main_target = project.targets.first
    main_target.add_file_references([file_ref])
    
    # Save the project
    project.save
    
    puts \"Added #{file_name} to project\"
    "
done

echo "All analytics files have been added to the Xcode project!"
echo "Please rebuild the project in Xcode."