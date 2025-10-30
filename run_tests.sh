#!/bin/bash

# PRBuster Test Runner Script
# This script helps you run tests for the PRBuster project

echo "🚀 PRBuster Test Runner"
echo "======================="

# Check if we're in the right directory
if [ ! -f "PRBuster.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the PRBuster project root directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected: /Users/rulof/personal/rulis-pr-buster"
    exit 1
fi

echo "📁 Project directory: $(pwd)"
echo ""

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found. Please install Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

echo "🔧 Xcode Command Line Tools: ✅"
echo ""

# Function to run tests
run_tests() {
    local test_type="$1"
    local description="$2"
    
    echo "🧪 Running $description..."
    echo "----------------------------------------"
    
    if [ "$test_type" = "all" ]; then
        xcodebuild test -scheme PRBuster -destination 'platform=macOS' -quiet
    elif [ "$test_type" = "quick" ]; then
        xcodebuild test -scheme PRBuster -destination 'platform=macOS' -only-testing:PRBusterTests/QuickTest -quiet
    elif [ "$test_type" = "unit" ]; then
        xcodebuild test -scheme PRBuster -destination 'platform=macOS' -only-testing:PRBusterTests/UnitTests -quiet
    elif [ "$test_type" = "integration" ]; then
        xcodebuild test -scheme PRBuster -destination 'platform=macOS' -only-testing:PRBusterTests/IntegrationTests -quiet
    elif [ "$test_type" = "e2e" ]; then
        xcodebuild test -scheme PRBuster -destination 'platform=macOS' -only-testing:PRBusterTests/EndToEndTests -quiet
    else
        echo "❌ Unknown test type: $test_type"
        return 1
    fi
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ $description completed successfully!"
    else
        echo "❌ $description failed with exit code $exit_code"
    fi
    
    echo ""
    return $exit_code
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  quick        Run quick tests only (recommended for first run)"
    echo "  unit         Run unit tests"
    echo "  integration  Run integration tests"
    echo "  e2e          Run end-to-end tests"
    echo "  all          Run all tests"
    echo "  help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 quick        # Run quick tests (fastest)"
    echo "  $0 unit         # Run unit tests"
    echo "  $0 all          # Run all tests"
    echo ""
}

# Parse command line arguments
case "${1:-help}" in
    "quick")
        run_tests "quick" "Quick Tests"
        ;;
    "unit")
        run_tests "unit" "Unit Tests"
        ;;
    "integration")
        run_tests "integration" "Integration Tests"
        ;;
    "e2e")
        run_tests "e2e" "End-to-End Tests"
        ;;
    "all")
        run_tests "all" "All Tests"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ Unknown option: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

echo "🎉 Test run completed!"

