import AppKit
import WebKit

private extension NSToolbarItem.Identifier {
    static let dashboardBack = NSToolbarItem.Identifier("dashboard.back")
    static let dashboardForward = NSToolbarItem.Identifier("dashboard.forward")
    static let dashboardReload = NSToolbarItem.Identifier("dashboard.reload")
    static let dashboardHome = NSToolbarItem.Identifier("dashboard.home")
    static let dashboardSettings = NSToolbarItem.Identifier("dashboard.settings")
}

@MainActor
final class DashboardWindowController: NSWindowController, NSToolbarDelegate, WKNavigationDelegate, WKUIDelegate {
    private let settings: DashboardConfiguration
    private let webView: WKWebView
    private var backItem: NSToolbarItem?
    private var forwardItem: NSToolbarItem?

    init(settings: DashboardConfiguration = DashboardConfiguration()) {
        self.settings = settings

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = .default()
        webConfiguration.applicationNameForUserAgent = "HermesDashboardMac"
        webConfiguration.preferences.isElementFullscreenEnabled = true

        webView = WKWebView(frame: .zero, configuration: webConfiguration)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 820),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        super.init(window: window)

        window.title = "Hermes Dashboard"
        window.minSize = NSSize(width: 760, height: 520)
        window.center()
        window.setFrameAutosaveName("HermesDashboardMainWindow")
        window.contentView = webView
        window.tabbingMode = .disallowed

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsMagnification = true

        let toolbar = NSToolbar(identifier: "HermesDashboardToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        window.toolbar = toolbar
        window.toolbarStyle = .unified
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        loadDashboard()
    }

    @objc func loadDashboard() {
        webView.load(URLRequest(url: settings.dashboardURL))
    }

    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc func reloadDashboard() {
        webView.reload()
    }

    @objc func openDashboardInBrowser() {
        NSWorkspace.shared.open(webView.url ?? settings.dashboardURL)
    }

    @objc func showConnectionSettings() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Dashboard Connection"
        alert.informativeText = "Enter the HTTP or HTTPS address of the Hermes dashboard. This setting is stored locally on this Mac."
        alert.addButton(withTitle: "Connect")
        alert.addButton(withTitle: "Cancel")

        let field = NSTextField(string: settings.dashboardURL.absoluteString)
        field.frame = NSRect(x: 0, y: 0, width: 420, height: 24)
        field.placeholderString = "http://127.0.0.1:9119"
        alert.accessoryView = field
        alert.window.initialFirstResponder = field

        guard alert.runModal() == .alertFirstButtonReturn else {
            return
        }

        guard let url = DashboardConfiguration.normalizeURL(field.stringValue) else {
            let invalid = NSAlert()
            invalid.alertStyle = .warning
            invalid.messageText = "Invalid dashboard address"
            invalid.informativeText = "Use an HTTP or HTTPS URL, for example http://127.0.0.1:9119."
            invalid.runModal()
            showConnectionSettings()
            return
        }

        settings.saveDashboardURL(url)
        loadDashboard()
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.dashboardBack, .dashboardForward, .dashboardReload, .dashboardHome, .flexibleSpace, .dashboardSettings]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.dashboardBack, .dashboardForward, .dashboardReload, .dashboardHome, .flexibleSpace, .dashboardSettings]
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)

        switch itemIdentifier {
        case .dashboardBack:
            configure(item, label: "Back", symbol: "chevron.left", action: #selector(goBack))
            backItem = item
        case .dashboardForward:
            configure(item, label: "Forward", symbol: "chevron.right", action: #selector(goForward))
            forwardItem = item
        case .dashboardReload:
            configure(item, label: "Reload", symbol: "arrow.clockwise", action: #selector(reloadDashboard))
        case .dashboardHome:
            configure(item, label: "Dashboard", symbol: "house", action: #selector(loadDashboard))
        case .dashboardSettings:
            configure(item, label: "Connection", symbol: "network", action: #selector(showConnectionSettings))
        default:
            return nil
        }

        updateNavigationItems()
        return item
    }

    private func configure(_ item: NSToolbarItem, label: String, symbol: String, action: Selector) {
        item.label = label
        item.paletteLabel = label
        item.toolTip = label
        item.target = self
        item.action = action
        item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)
    }

    private func updateNavigationItems() {
        backItem?.isEnabled = webView.canGoBack
        forwardItem?.isEnabled = webView.canGoForward

        if let host = webView.url?.host {
            window?.title = "Hermes Dashboard — \(host)"
        } else {
            window?.title = "Hermes Dashboard"
        }
    }

    private func showLoadError(_ error: Error) {
        let escaped = error.localizedDescription
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        let html = """
        <!doctype html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            :root { color-scheme: light dark; font-family: -apple-system, BlinkMacSystemFont, sans-serif; }
            body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: Canvas; color: CanvasText; }
            main { width: min(560px, calc(100vw - 64px)); text-align: center; }
            h1 { font-size: 24px; margin-bottom: 10px; }
            p { color: color-mix(in srgb, CanvasText 65%, transparent); line-height: 1.5; }
            .error { margin: 20px 0; padding: 14px; border-radius: 10px; background: color-mix(in srgb, red 10%, Canvas); font-family: ui-monospace, monospace; font-size: 12px; }
            a { display: inline-block; margin: 6px; padding: 9px 14px; border-radius: 8px; color: white; background: #0053fd; text-decoration: none; }
            a.secondary { background: color-mix(in srgb, CanvasText 12%, Canvas); color: CanvasText; }
          </style>
        </head>
        <body>
          <main>
            <h1>Unable to reach Hermes</h1>
            <p>Start the dashboard, verify its address, and try again.</p>
            <div class="error">\(escaped)</div>
            <a href="hermes-dashboard-action://retry">Retry</a>
            <a class="secondary" href="hermes-dashboard-action://settings">Connection settings</a>
          </main>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationItems()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateNavigationItems()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showLoadError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showLoadError(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.scheme == "hermes-dashboard-action" {
            decisionHandler(.cancel)

            if url.host == "retry" {
                loadDashboard()
            } else if url.host == "settings" {
                showConnectionSettings()
            }
            return
        }

        guard url.scheme == "http" || url.scheme == "https" else {
            decisionHandler(.cancel)
            NSWorkspace.shared.open(url)
            return
        }

        if navigationAction.targetFrame == nil {
            decisionHandler(.cancel)
            webView.load(navigationAction.request)
            return
        }

        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let request = navigationAction.request.url {
            webView.load(URLRequest(url: request))
        }
        return nil
    }

    func webView(
        _ webView: WKWebView,
        runOpenPanelWith parameters: WKOpenPanelParameters,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping @MainActor @Sendable ([URL]?) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.canChooseDirectories = parameters.allowsDirectories
        panel.canChooseFiles = true

        panel.beginSheetModal(for: window!) { response in
            completionHandler(response == .OK ? panel.urls : nil)
        }
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping @MainActor @Sendable () -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = message
        alert.beginSheetModal(for: window!) { _ in completionHandler() }
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping @MainActor @Sendable (Bool) -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: window!) { response in completionHandler(response == .alertFirstButtonReturn) }
    }

    @available(macOS 12.0, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping @MainActor @Sendable (WKPermissionDecision) -> Void
    ) {
        decisionHandler(.prompt)
    }
}
