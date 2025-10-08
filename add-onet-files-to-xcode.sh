#!/bin/bash

echo "🔧 Adding O*NET integration files to Xcode project..."

# Define the new files that need to be added (Recipe C v3.0)
NEW_FILES=(
    "carrer/Services/Networking/SnowflakeService.swift"
    "carrer/Models/CareerExplorer/ONetOccupation.swift"
    "carrer/Models/CareerExplorer/CareerSkill.swift"
    "carrer/Models/CareerExplorer/JobSearchStrategy.swift"
    "carrer/ViewModels/CareerExplorer/ONetCareerViewModel.swift"
    "carrer/Views/CareerExplorer/ONetCareerDetailView.swift"
    "carrer/Views/Onboarding/WorkValuesView.swift"
)

echo ""
echo "📂 Files to add to Xcode project:"
for file in "${NEW_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file (exists)"
    else
        echo "  ❌ $file (NOT FOUND)"
    fi
done

echo ""
echo "📝 Manual Steps Required:"
echo "1. Open carrer.xcodeproj in Xcode"
echo "2. Right-click on the appropriate group in the Project Navigator"
echo "3. Select 'Add Files to carrer...'"
echo "4. Add each of these files:"
echo ""
echo "   Services/Networking/"
echo "   └── SnowflakeService.swift"
echo ""
echo "   Models/CareerExplorer/"
echo "   ├── ONetOccupation.swift"
echo "   ├── CareerSkill.swift"
echo "   └── JobSearchStrategy.swift"
echo ""
echo "   ViewModels/CareerExplorer/"
echo "   └── ONetCareerViewModel.swift"
echo ""
echo "   Views/CareerExplorer/"
echo "   └── ONetCareerDetailView.swift"
echo ""
echo "   Views/Onboarding/"
echo "   └── WorkValuesView.swift  ⭐ (Recipe C v3.0)"
echo ""
echo "5. Make sure 'Copy items if needed' is UNCHECKED"
echo "6. Make sure 'carrer' target is CHECKED"
echo "7. Click 'Add'"
echo ""
echo "✨ After adding files, build the project to verify!"
