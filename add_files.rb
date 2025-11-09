#!/usr/bin/env ruby
require 'securerandom'

# Files to add to the project
files_to_add = [
  'carrer/ViewModels/CareerExplorer/CareerTracksViewModel.swift',
  'carrer/Models/CareerExplorer/CareerTrackModels.swift',
  'carrer/Views/CareerExplorer/AddToTrackSheet.swift',
  'carrer/Views/CareerExplorer/SkillAssessmentSheet.swift',
  'carrer/Views/CareerExplorer/AllRecommendationsView.swift',
  'carrer/Services/Analytics/AnalyticsService.swift'
]

pbxproj_path = 'carrer.xcodeproj/project.pbxproj'
content = File.read(pbxproj_path)

# Find the PBXBuildFile section
build_file_section = content[/\/\* Begin PBXBuildFile section \*\/(.*?)\/\* End PBXBuildFile section \*\//m, 1]
file_ref_section = content[/\/\* Begin PBXFileReference section \*\/(.*?)\/\* End PBXFileReference section \*\//m, 1]

# Find the Sources build phase
sources_build_phase = content[/A4B5211E2DDF1AFF00B71A54 \/\* Sources \*\/ = \{[^}]*files = \((.*?)\);/m, 1]

new_build_files = []
new_file_refs = []
new_source_entries = []

files_to_add.each do |file_path|
  file_name = File.basename(file_path)

  # Generate UUIDs (24 chars hex, uppercase)
  file_ref_id = SecureRandom.hex(12).upcase
  build_file_id = SecureRandom.hex(12).upcase

  # Create PBXFileReference entry
  new_file_refs << "\t\t#{file_ref_id} /* #{file_name} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"#{file_name}\"; sourceTree = \"<group>\"; };"

  # Create PBXBuildFile entry
  new_build_files << "\t\t#{build_file_id} /* #{file_name} in Sources */ = {isa = PBXBuildFile; fileRef = #{file_ref_id} /* #{file_name} */; };"

  # Create Sources build phase entry
  new_source_entries << "\t\t\t\t#{build_file_id} /* #{file_name} in Sources */,"
end

# Insert new entries
content.sub!(/\/\* End PBXBuildFile section \*\//) do
  new_build_files.join("\n") + "\n/* End PBXBuildFile section */"
end

content.sub!(/\/\* End PBXFileReference section \*\//) do
  new_file_refs.join("\n") + "\n/* End PBXFileReference section */"
end

content.sub!(/(A4B5211E2DDF1AFF00B71A54 \/\* Sources \*\/ = \{[^}]*files = \([^)]*)()\);/m) do
  "#{$1}#{new_source_entries.join("\n")}\n\t\t\t);"
end

File.write(pbxproj_path, content)
puts "Added #{files_to_add.length} files to project"
