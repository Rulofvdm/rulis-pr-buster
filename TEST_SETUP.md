# PRBuster Test Setup Guide

This guide will help you set up and run the tests for the PRBuster project.

## 🚀 Quick Start (Recommended)

### Option 1: Using the Test Runner Script

1. **Navigate to the project directory:**
   ```bash
   cd /Users/rulof/personal/rulis-pr-buster
   ```

2. **Run the quick test (fastest way to verify everything works):**
   ```bash
   ./run_tests.sh quick
   ```

3. **If that works, run all tests:**
   ```bash
   ./run_tests.sh all
   ```

### Option 2: Using Xcode GUI

1. **Open the project in Xcode:**
   ```bash
   open PRBuster.xcodeproj
   ```

2. **Add the QuickTest.swift file to your project:**
   - Right-click on your project in Xcode
   - Choose "Add Files to PRBuster"
   - Navigate to `PRBusterTests/QuickTest.swift`
   - Make sure "Add to target" is checked for your main app target

3. **Run tests:**
   - Press `Cmd + U` in Xcode
   - Or go to `Product > Test`

## 🔧 Full Test Suite Setup

### Step 1: Create Test Target in Xcode

1. **Open Xcode Project:**
   ```bash
   open PRBuster.xcodeproj
   ```

2. **Add Test Target:**
   - Select the project in the navigator
   - Click the "+" button at the bottom of the target list
   - Choose "macOS" → "Unit Testing Bundle"
   - Name it "PRBusterTests"
   - Make sure "PRBuster" is selected as the target to be tested

3. **Configure Test Target:**
   - Select the PRBusterTests target
   - Go to Build Settings
   - Set "Bundle Identifier" to `com.yourcompany.PRBusterTests`
   - Set "Test Host" to `$(BUILT_PRODUCTS_DIR)/PRBuster.app/Contents/MacOS/PRBuster`

### Step 2: Add Test Files

1. **Add Test Infrastructure:**
   - Right-click on PRBusterTests group
   - Choose "Add Files to PRBusterTests"
   - Add all files from `PRBusterTests/TestInfrastructure/`

2. **Add Unit Tests:**
   - Add all files from `PRBusterTests/UnitTests/`

3. **Add Integration Tests:**
   - Add all files from `PRBusterTests/IntegrationTests/`

4. **Add End-to-End Tests:**
   - Add all files from `PRBusterTests/EndToEndTests/`

### Step 3: Run Tests

```bash
# Using command line
xcodebuild test -scheme PRBuster -destination 'platform=macOS'

# Or in Xcode: Cmd + U
```

## 🧪 What the Tests Verify

### Quick Test (Fastest)
- ✅ AppDelegate can be instantiated
- ✅ SettingsManager works correctly
- ✅ Default settings are properly configured
- ✅ PullRequest models can be created
- ✅ Configuration validation works
- ✅ Enum values and display names are correct

### Unit Tests (Comprehensive)
- ✅ AppDelegate lifecycle and state management
- ✅ SettingsManager persistence and validation
- ✅ PullRequestService API integration
- ✅ Error handling and recovery
- ✅ Performance measurement

### Integration Tests
- ✅ Component interactions
- ✅ Data flow between components
- ✅ Settings changes trigger updates
- ✅ Error propagation

### End-to-End Tests
- ✅ Complete application startup flow
- ✅ Data fetching workflow
- ✅ Settings management flow
- ✅ Notification flow
- ✅ Batch operations flow

## 📊 Expected Test Results

### ✅ Successful Test Run
```
Test Suite 'QuickTest' started at 2024-01-XX XX:XX:XX.XXX
Test Case '-[PRBusterTests.QuickTest testBasicFunctionality]' started.
Test Case '-[PRBusterTests.QuickTest testBasicFunctionality]' passed (0.001 seconds).
Test Case '-[PRBusterTests.QuickTest testSettingsConfiguration]' started.
Test Case '-[PRBusterTests.QuickTest testSettingsConfiguration]' passed (0.001 seconds).
Test Case '-[PRBusterTests.QuickTest testPullRequestModels]' started.
Test Case '-[PRBusterTests.QuickTest testPullRequestModels]' passed (0.001 seconds).
Test Case '-[PRBusterTests.QuickTest testAppSettings]' started.
Test Case '-[PRBusterTests.QuickTest testAppSettings]' passed (0.001 seconds).
Test Case '-[PRBusterTests.QuickTest testReviewerVoteEnum]' started.
Test Case '-[PRBusterTests.QuickTest testReviewerVoteEnum]' passed (0.001 seconds).
Test Case '-[PRBusterTests.QuickTest testPullRequestStatusEnum]' started.
Test Case '-[PRBusterTests.QuickTest testPullRequestStatusEnum]' passed (0.001 seconds).
Test Suite 'QuickTest' passed at 2024-01-XX XX:XX:XX.XXX.
Executed 6 tests, with 0 failures (0 unexpected) in 0.006 (0.006) seconds
```

### ❌ Failed Test (if there are issues)
```
Test Case '-[PRBusterTests.QuickTest testBasicFunctionality]' failed (0.001 seconds).
```

## 🛠️ Troubleshooting

### Common Issues

1. **"Cannot find 'Creator' in scope"**
   - ✅ **Fixed**: Updated test to use correct model names (`User` instead of `Creator`)

2. **"Missing arguments for parameters"**
   - ✅ **Fixed**: Updated test to match actual model constructors

3. **"Extra argument" errors**
   - ✅ **Fixed**: Removed incorrect parameters and used correct model structure

4. **Import errors**
   - Make sure `@testable import PRBuster` is correct
   - Check that the module name matches your app target

5. **Build errors**
   - Ensure the app target builds successfully first
   - Check that all model files are included in the app target

### If Tests Don't Run

1. **Check Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```

2. **Verify project structure:**
   ```bash
   ls -la PRBuster.xcodeproj/
   ```

3. **Check test target configuration:**
   - Open Xcode project
   - Select PRBusterTests target
   - Verify build settings

### If You Get Build Errors

1. **Clean and rebuild:**
   ```bash
   xcodebuild clean -scheme PRBuster
   xcodebuild build -scheme PRBuster
   ```

2. **Check dependencies:**
   - Ensure all source files are included in the app target
   - Verify that the app builds successfully before running tests

## 🎯 Next Steps

Once the quick test passes:

1. **Run unit tests:** `./run_tests.sh unit`
2. **Run integration tests:** `./run_tests.sh integration`
3. **Run end-to-end tests:** `./run_tests.sh e2e`
4. **Run all tests:** `./run_tests.sh all`

## 📈 Test Coverage

The test suite provides:
- **Unit Tests**: 90%+ code coverage target
- **Integration Tests**: 80%+ integration coverage
- **End-to-End Tests**: 100% user flow coverage
- **Performance Tests**: Load testing and stress testing

## 🔄 Continuous Integration

For automated testing:
```bash
# Run with coverage
xcodebuild test -scheme PRBuster -destination 'platform=macOS' -enableCodeCoverage YES

# Generate coverage report
xcrun xccov view --report DerivedData/Logs/Test/*.xcresult
```

This comprehensive test suite ensures the PRBuster application is reliable, maintainable, and provides a great user experience!

