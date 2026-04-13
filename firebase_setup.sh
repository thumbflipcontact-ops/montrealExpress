#!/bin/bash

# Firebase Setup Script for AbdoulExpress
# This script ensures the correct Ruby version is used to avoid xcodeproj errors

echo "🔧 Setting up environment for Firebase configuration..."

# Use Homebrew Ruby instead of system Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$PATH:$HOME/.pub-cache/bin"

echo "✅ Ruby version: $(ruby --version)"
echo "✅ FlutterFire CLI: $(flutterfire --version)"

# Verify xcodeproj gem is available
ruby -e "require 'xcodeproj'" 2>/dev/null && echo "✅ xcodeproj gem loaded successfully" || echo "❌ xcodeproj gem missing"

echo ""
echo "🚀 Running FlutterFire configuration..."
echo ""

# Run flutterfire configure
flutterfire configure

echo ""
echo "✅ Firebase setup complete!"
