import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var dashboardWindowController: DashboardWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png"),
           let icon = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = icon
        }

        let controller = DashboardWindowController()
        dashboardWindowController = controller
        buildMainMenu(controller: controller)
        controller.start()
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            dashboardWindowController?.showWindow(nil)
            dashboardWindowController?.window?.makeKeyAndOrderFront(nil)
        }
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func buildMainMenu(controller: DashboardWindowController) {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "About Hermes Dashboard", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())

        let settings = NSMenuItem(title: "Connection Settings…", action: #selector(DashboardWindowController.showConnectionSettings), keyEquivalent: ",")
        settings.target = controller
        appMenu.addItem(settings)
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide Hermes Dashboard", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit Hermes Dashboard", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        let navigationMenuItem = NSMenuItem()
        mainMenu.addItem(navigationMenuItem)
        let navigationMenu = NSMenu(title: "Navigate")
        navigationMenuItem.submenu = navigationMenu

        let reload = NSMenuItem(title: "Reload", action: #selector(DashboardWindowController.reloadDashboard), keyEquivalent: "r")
        reload.target = controller
        navigationMenu.addItem(reload)

        let home = NSMenuItem(title: "Dashboard Home", action: #selector(DashboardWindowController.loadDashboard), keyEquivalent: "0")
        home.target = controller
        navigationMenu.addItem(home)

        let browser = NSMenuItem(title: "Open in Browser", action: #selector(DashboardWindowController.openDashboardInBrowser), keyEquivalent: "o")
        browser.keyEquivalentModifierMask = [.command, .shift]
        browser.target = controller
        navigationMenu.addItem(browser)

        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        NSApp.windowsMenu = windowMenu

        NSApp.mainMenu = mainMenu
    }
}

@main
enum HermesDashboardApplication {
    @MainActor
    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        application.setActivationPolicy(.regular)
        application.run()
    }
}
