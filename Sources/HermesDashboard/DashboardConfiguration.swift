import Foundation

struct DashboardConfiguration {
    static let dashboardURLKey = "dashboardURL"
    static let fallbackDashboardURL = URL(string: "http://127.0.0.1:9119")!

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var dashboardURL: URL {
        if let saved = defaults.string(forKey: Self.dashboardURLKey),
           let normalized = Self.normalizeURL(saved) {
            return normalized
        }

        return Self.bundledDefaultURL
    }

    func saveDashboardURL(_ url: URL) {
        defaults.set(url.absoluteString, forKey: Self.dashboardURLKey)
    }

    static var bundledDefaultURL: URL {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "HermesDashboardDefaultURL") as? String,
              let normalized = normalizeURL(raw) else {
            return fallbackDashboardURL
        }

        return normalized
    }

    static func normalizeURL(_ rawValue: String) -> URL? {
        var value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty else {
            return nil
        }

        if !value.contains("://") {
            value = "http://\(value)"
        }

        guard var components = URLComponents(string: value),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = components.host,
              !host.isEmpty else {
            return nil
        }

        components.scheme = scheme
        components.fragment = nil

        if components.path.isEmpty {
            components.path = "/"
        }

        return components.url
    }
}

