# PRBuster Testing Suite

This directory contains the comprehensive testing suite for the PRBuster macOS application. The testing strategy covers unit tests, integration tests, end-to-end tests, and performance tests.

## Test Structure

```
PRBusterTests/
├── TestInfrastructure/          # Test infrastructure and utilities
│   ├── TestDataFactory.swift   # Factory for creating test data
│   ├── MockObjects.swift       # Mock objects for testing
│   └── TestHelpers.swift       # Helper functions for testing
├── TestConfiguration/          # Test configuration and environment
│   └── TestEnvironment.swift   # Test environment setup and teardown
├── UnitTests/                  # Unit tests for individual components
│   ├── AppDelegateTests.swift  # AppDelegate unit tests
│   ├── SettingsManagerTests.swift # SettingsManager unit tests
│   └── PullRequestServiceTests.swift # PullRequestService unit tests
├── IntegrationTests/           # Integration tests for component interactions
│   └── ComponentInteractionTests.swift # Component interaction tests
├── EndToEndTests/             # End-to-end tests for complete workflows
│   ├── ApplicationStartupFlowTests.swift # Application startup tests
│   └── DataFetchingFlowTests.swift # Data fetching workflow tests
├── TestRunner/                # Test execution and reporting
│   └── TestSuite.swift         # Main test suite runner
└── README.md                  # This file
```

## Test Categories

### 1. Unit Tests
Test individual components in isolation with mocked dependencies.

**Coverage:**
- AppDelegate lifecycle and state management
- SettingsManager persistence and validation
- PullRequestService API integration
- NotificationManager permission and scheduling
- MenuBuilder dynamic menu construction

**Key Features:**
- Isolated component testing
- Mock object integration
- Error handling validation
- Performance measurement

### 2. Integration Tests
Test component interactions and data flow between components.

**Coverage:**
- Settings changes → Component updates
- PR data fetching → State updates → UI updates
- Error states → User feedback → Recovery
- Component communication patterns

**Key Features:**
- Component interaction validation
- Data flow verification
- Error propagation testing
- Performance integration testing

### 3. End-to-End Tests
Test complete user workflows from start to finish.

**Coverage:**
- Application startup flow
- Data fetching workflow
- Settings management flow
- Notification flow
- Batch operations flow

**Key Features:**
- Complete workflow testing
- User experience validation
- Error recovery testing
- Performance under load

### 4. Performance Tests
Test application performance under various conditions.

**Coverage:**
- Startup performance
- Data fetching performance
- Menu building performance
- Settings performance
- Memory usage

**Key Features:**
- Performance benchmarking
- Memory usage monitoring
- Load testing
- Stress testing

## Test Infrastructure

### TestDataFactory
Factory class for creating consistent test data across all tests.

```swift
// Create test PRs
let testPRs = TestDataFactory.createAssignedPRsScenario()

// Create test settings
let testSettings = TestDataFactory.createAppSettings(
    email: "test@example.com",
    pat: "test-pat"
)
```

### MockObjects
Mock implementations of external dependencies for isolated testing.

```swift
// Mock PullRequestService
let mockService = MockPullRequestService()
mockService.assignedPRs = testPRs

// Mock NotificationManager
let mockNotificationManager = MockNotificationManager()
mockNotificationManager.permissionsGranted = true
```

### TestHelpers
Utility functions for common testing operations.

```swift
// Wait for async operations
TestHelpers.waitForAsyncOperation(timeout: 2.0)

// Assert status item title
TestHelpers.assertStatusItemTitle(statusItem, expectedTitle: "3/5 2/8")
```

## Running Tests

### Run All Tests
```bash
# Run all tests
xcodebuild test -scheme PRBuster -destination 'platform=macOS'

# Run specific test suite
xcodebuild test -scheme PRBuster -destination 'platform=macOS' -only-testing:PRBusterTests/TestSuite
```

### Run Unit Tests Only
```bash
xcodebuild test -scheme PRBuster -destination 'platform=macOS' -only-testing:PRBusterTests/UnitTests
```

### Run Integration Tests Only
```bash
xcodebuild test -scheme PRBuster -destination 'platform=macOS' -only-testing:PRBusterTests/IntegrationTests
```

### Run End-to-End Tests Only
```bash
xcodebuild test -scheme PRBuster -destination 'platform=macOS' -only-testing:PRBusterTests/EndToEndTests
```

## Test Configuration

### Test Environment Setup
The test environment is automatically configured in `TestEnvironment.swift`:

```swift
// Setup test environment
TestEnvironment.shared.setup()

// Configure for specific test types
TestEnvironment.shared.configureForUnitTests()
TestEnvironment.shared.configureForIntegrationTests()
TestEnvironment.shared.configureForEndToEndTests()
```

### Test Data Management
Test data is automatically created and cleaned up:

```swift
// Create test data
let testPRs = TestEnvironment.shared.createTestPullRequests(count: 5)
let testSettings = TestEnvironment.shared.createTestSettings()

// Cleanup test data
TestEnvironment.shared.cleanupTestData()
```

## Test Coverage

### Target Coverage
- **Unit Tests**: 90%+ code coverage
- **Integration Tests**: 80%+ integration coverage
- **End-to-End Tests**: 100% user flow coverage

### Coverage Reporting
```bash
# Generate coverage report
xcodebuild test -scheme PRBuster -destination 'platform=macOS' -enableCodeCoverage YES

# View coverage report
xcrun xccov view --report DerivedData/Logs/Test/*.xcresult
```

## Test Maintenance

### Adding New Tests
1. Create test file in appropriate directory
2. Follow naming convention: `ComponentNameTests.swift`
3. Implement test methods with descriptive names
4. Use TestDataFactory for test data
5. Use MockObjects for dependencies
6. Add to TestSuite if needed

### Updating Existing Tests
1. Update test data if component changes
2. Update mocks if dependencies change
3. Update assertions if behavior changes
4. Maintain test coverage

### Test Documentation
- Document test purpose in comments
- Use descriptive test method names
- Include setup and teardown documentation
- Document expected behavior

## Best Practices

### Test Organization
- Group related tests in same file
- Use descriptive test method names
- Follow AAA pattern (Arrange, Act, Assert)
- Keep tests independent and isolated

### Test Data
- Use TestDataFactory for consistent data
- Create realistic test scenarios
- Clean up test data after tests
- Use meaningful test data values

### Mock Usage
- Mock external dependencies
- Use MockObjects for consistency
- Verify mock interactions
- Keep mocks simple and focused

### Performance Testing
- Measure performance consistently
- Test under realistic conditions
- Monitor memory usage
- Test with large datasets

### Error Testing
- Test error conditions
- Test error recovery
- Test edge cases
- Test invalid input

## Troubleshooting

### Common Issues
1. **Test failures due to async operations**: Use `TestHelpers.waitForAsyncOperation()`
2. **Mock not working**: Ensure mock is properly injected
3. **Test data conflicts**: Use `TestEnvironment.shared.cleanupTestData()`
4. **Performance test failures**: Check system resources and test conditions

### Debug Tips
1. Use `print()` statements for debugging
2. Check test logs for detailed error information
3. Verify test environment setup
4. Check mock object configuration

### Test Isolation
- Each test should be independent
- Use `setUp()` and `tearDown()` for cleanup
- Avoid shared state between tests
- Use unique test data for each test

## Continuous Integration

### Pre-commit Hooks
- Run unit tests before commits
- Check test coverage
- Validate test structure
- Ensure all tests pass

### Pull Request Validation
- Run full test suite on PRs
- Check test coverage changes
- Validate new test additions
- Ensure no test regressions

### Nightly Builds
- Run comprehensive test suite
- Generate coverage reports
- Performance regression testing
- Test environment validation

## Contributing

### Adding New Test Cases
1. Follow existing test patterns
2. Use appropriate test infrastructure
3. Document test purpose
4. Ensure test independence
5. Add to test suite if needed

### Updating Test Infrastructure
1. Maintain backward compatibility
2. Update documentation
3. Test infrastructure changes
4. Update all dependent tests

### Test Review Process
1. Review test coverage
2. Validate test quality
3. Check test performance
4. Ensure test maintainability

This comprehensive testing suite ensures the PRBuster application is reliable, maintainable, and provides a great user experience. The testing strategy covers all aspects of the application from individual components to complete user workflows.

