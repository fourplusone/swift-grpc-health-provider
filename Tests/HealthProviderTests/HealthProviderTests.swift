import XCTest
@testable import HealthProvider

final class HealthProviderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HealthProvider().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
