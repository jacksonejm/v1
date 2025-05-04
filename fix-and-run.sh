#!/bin/bash

echo "Applying all fixes and preparing to run the app..."

# 1. Make sure MyPathPromptGenerator.swift is part of the project
echo "Please make sure you've added MyPathPromptGenerator.swift to your Xcode project."
echo "  - Open Xcode"
echo "  - Right-click on the New folder"
echo "  - Select 'Add Files to \"carrer\"...'"
echo "  - Add /Users/eddym/Downloads/app/carrer/carrer/New/MyPathPromptGenerator.swift"
echo ""

# 2. Apply all the fixes
echo "Applying fixes to code references..."
sed -i '' 's/EnhancedSystemPromptGenerator/MyPathPromptGenerator/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift

# 3. Update UserDataKey references in riasec-scoring.swift
echo "Fixing UserDataKey references in riasec-scoring.swift..."
sed -i '' 's/userData\[\.riasecResponses\]/userData["riasecResponses"]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
sed -i '' 's/userData\[\.interests\]/userData["interests"]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
sed -i '' 's/userData\[\.favoriteSubjects\]/userData["favoriteSubjects"]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
sed -i '' 's/userData\[\.extracurriculars\]/userData["extracurriculars"]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
sed -i '' 's/userData\[\.careerInterests\]/userData["careerInterests"]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift
sed -i '' 's/userData\[\.riasecResults\]/userData["riasecResults"]/g' /Users/eddym/Downloads/app/carrer/carrer/New/riasec-scoring.swift

# 4. Update aicoatch to use string keys
echo "Updating aicoatch.swift to use string dictionary keys..."
sed -i '' 's/let userData: \[UserDataKey: AnyHashable\]/let userData: [String: AnyHashable]/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift
sed -i '' 's/\.name:/\"name\":/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift
sed -i '' 's/\.interests:/\"interests\":/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift
sed -i '' 's/\.studentLevel:/\"studentLevel\":/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift
sed -i '' 's/\.favoriteSubjects:/\"favoriteSubjects\":/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift
sed -i '' 's/\.extracurriculars:/\"extracurriculars\":/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift
sed -i '' 's/\.careerInterests:/\"careerInterests\":/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift
sed -i '' 's/\.riasecResults:/\"riasecResults\":/g' /Users/eddym/Downloads/app/carrer/carrer/New/aicoatch.swift

echo ""
echo "All fixes applied!"
echo ""
echo "Next steps:"
echo "1. Build and run your project in Xcode (⌘+R)"
echo "2. Test the AI assistant in different onboarding steps"
echo "3. Confirm that responses are contextual and helpful"
echo ""
echo "If you encounter any more issues, please let me know!"