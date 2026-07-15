import XCTest
@testable import HermesDashboard

final class DashboardConfigurationTests: XCTestCase {
    func testRejectsEmptyAndNonHTTPValues() {
        XCTAssertNil(DashboardConfiguration.normalizeURL(""))
        XCTAssertNil(DashboardConfiguration.normalizeURL("file:///tmp"))
    }

    func testAddsSchemeToBareLoopbackAddress() {
        XCTAssertEqual(
            DashboardConfiguration.normalizeURL("127.0.0.1:9119")?.absoluteString,
            "http://127.0.0.1:9119/"
        )
    }

    func testNormalizesSchemeAndRemovesFragment() {
        XCTAssertEqual(
            DashboardConfiguration.normalizeURL(" HTTPS://example.com/dashboard#fragment ")?.absoluteString,
            "https://example.com/dashboard"
        )
    }

    func testPersistsDashboardURL() {
        let suite = "HermesDashboardTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defer { defaults.removePersistentDomain(forName: suite) }

        let configuration = DashboardConfiguration(defaults: defaults)
        let custom = URL(string: "http://localhost:9191/")!
        configuration.saveDashboardURL(custom)

        XCTAssertEqual(configuration.dashboardURL, custom)
    }
}

