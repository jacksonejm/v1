#!/bin/bash

# Move test file to proper location
if [ -f "carrer/carrerTests.swift" ]; then
  echo "Moving carrerTests.swift to carrerTests directory..."
  mkdir -p carrerTests
  mv carrer/carrerTests.swift carrerTests/carrerTests.swift
fi

echo "Fix completed. Please open Xcode and make the following changes:"
echo "1. In Xcode, select the carrerTests target"
echo "2. Go to Build Phases > Link Binary With Libraries"
echo "3. Click + button and add 'XCTest.framework'"
echo "4. Clean and rebuild your project (Command+Shift+K then Command+B)"