import XCTest
@testable import SOAPNetwork

final class SOAPNetworkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SOAPNetwork().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
