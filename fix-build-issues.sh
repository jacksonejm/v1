#!/bin/bash

echo "Fixing build issues in the MyPath app..."

# 1. Make sure the aicoatch.swift has the correct references
sed -i '' 's/EnhancedSystemPromptGenerator/MyPathPromptGenerator/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift

# 2. Check if we need to find and fix references in riasec-scoring.swift
echo "Checking riasec-scoring.swift file..."
if grep -q "UserDataKey" /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift; then
  echo "Fixing UserDataKey references in riasec-scoring.swift..."
  # Use string literals instead of enum references
  sed -i '' 's/\[\.riasecResponses\]/\["riasecResponses"\]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
  sed -i '' 's/\[\.interests\]/\["interests"\]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
  sed -i '' 's/\[\.extracurriculars\]/\["extracurriculars"\]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
  sed -i '' 's/\[\.riasecResults\]/\["riasecResults"\]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
fi

echo "Fixes applied. Please try building the project again."
echo "If issues persist, you may need to update other files manually."