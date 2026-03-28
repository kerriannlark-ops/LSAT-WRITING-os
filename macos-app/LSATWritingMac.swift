import Cocoa
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate {
  private let appTitle = "Kerri — LSAT Argumentative Writing Course"
  private let appDisplayName = "Kerri LSAT Writing"
  private var windows: [NSWindow] = []

  func applicationDidFinishLaunching(_ notification: Notification) {
    buildMenus()
    let window = makeWindow(titleSuffix: nil, targetURL: nil, configuration: nil)
    windows.append(window)
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }

  private func buildMenus() {
    let mainMenu = NSMenu()

    let appMenuItem = NSMenuItem()
    mainMenu.addItem(appMenuItem)

    let appMenu = NSMenu()
    appMenuItem.submenu = appMenu
    appMenu.addItem(withTitle: "Quit \(appDisplayName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

    let windowMenuItem = NSMenuItem()
    mainMenu.addItem(windowMenuItem)

    let windowMenu = NSMenu(title: "Window")
    windowMenuItem.submenu = windowMenu
    windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
    windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
    windowMenu.addItem(.separator())
    windowMenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")

    NSApp.mainMenu = mainMenu
    NSApp.windowsMenu = windowMenu
  }

  private func makeWindow(titleSuffix: String?, targetURL: URL?, configuration: WKWebViewConfiguration?) -> NSWindow {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 1480, height: 980),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.title = titleSuffix == nil ? appTitle : "\(appTitle) — \(titleSuffix!)"
    window.center()

    let webView = makeWebView(configuration: configuration)
    window.contentView = webView
    loadApp(in: webView, targetURL: targetURL)
    return window
  }

  private func makeWebView(configuration: WKWebViewConfiguration?) -> WKWebView {
    let config = configuration ?? makeConfiguration()
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = self
    webView.uiDelegate = self
    webView.autoresizingMask = [.width, .height]
    return webView
  }

  private func makeConfiguration() -> WKWebViewConfiguration {
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = .default()
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    return configuration
  }

  private func resourceRootURL() -> URL {
    guard let resourceURL = Bundle.main.resourceURL else {
      fatalError("Bundle resources are missing.")
    }
    return resourceURL.appendingPathComponent("Web", isDirectory: true)
  }

  private func rootIndexURL() -> URL {
    resourceRootURL().appendingPathComponent("index.html")
  }

  private func loadApp(in webView: WKWebView, targetURL: URL?) {
    let url = targetURL ?? rootIndexURL()
    webView.loadFileURL(url, allowingReadAccessTo: resourceRootURL())
  }

  private func isExternalURL(_ url: URL) -> Bool {
    guard let scheme = url.scheme?.lowercased() else {
      return false
    }
    return ["http", "https", "mailto"].contains(scheme)
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let url = navigationAction.request.url, isExternalURL(url) {
      NSWorkspace.shared.open(url)
      decisionHandler(.cancel)
      return
    }
    decisionHandler(.allow)
  }

  func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
    guard let url = navigationAction.request.url else {
      return nil
    }

    if isExternalURL(url) {
      NSWorkspace.shared.open(url)
      return nil
    }

    let window = makeWindow(titleSuffix: "Practice", targetURL: url, configuration: configuration)
    windows.append(window)
    window.makeKeyAndOrderFront(nil)
    return window.contentView as? WKWebView
  }
}

@main
struct LSATWritingMacMain {
  static func main() {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.setActivationPolicy(.regular)
    app.delegate = delegate
    app.run()
  }
}
