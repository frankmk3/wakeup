import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var activity: NSObjectProtocol?
    private var endDate: Date?
    private var timer: Timer?
    private var activeTag: Int?
    private var durationItems: [NSMenuItem] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
        configureMenu()
        updateStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopKeepingAwake()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }

        button.image = NSImage(
            systemSymbolName: "cup.and.saucer",
            accessibilityDescription: "WakeUp"
        )
        button.imagePosition = .imageLeading
        button.toolTip = "WakeUp: system sleep is allowed"
    }

    private func configureMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Keep Mac Awake", action: nil, keyEquivalent: ""))
        menu.addItem(.separator())

        for (title, tag) in [("5 Minutes", 5), ("10 Minutes", 10), ("15 Minutes", 15)] {
            let item = NSMenuItem(
                title: title,
                action: #selector(selectDuration(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = tag
            durationItems.append(item)
            menu.addItem(item)
        }

        let indefinitely = NSMenuItem(
            title: "Indefinitely",
            action: #selector(selectDuration(_:)),
            keyEquivalent: ""
        )
        indefinitely.target = self
        indefinitely.tag = -1
        durationItems.append(indefinitely)
        menu.addItem(indefinitely)

        menu.addItem(.separator())

        let allowSleep = NSMenuItem(
            title: "Allow Sleep",
            action: #selector(allowSleep),
            keyEquivalent: ""
        )
        allowSleep.target = self
        menu.addItem(allowSleep)

        menu.addItem(.separator())

        let quit = NSMenuItem(
            title: "Quit WakeUp",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quit)

        statusItem.menu = menu
    }

    @objc private func selectDuration(_ sender: NSMenuItem) {
        startKeepingAwake(minutes: sender.tag == -1 ? nil : sender.tag)
    }

    private func startKeepingAwake(minutes: Int?) {
        stopKeepingAwake()

        activity = ProcessInfo.processInfo.beginActivity(
            options: [.idleSystemSleepDisabled],
            reason: "WakeUp was enabled from the menu bar"
        )
        activeTag = minutes ?? -1
        endDate = minutes.map { Date().addingTimeInterval(TimeInterval($0 * 60)) }

        if endDate != nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.tick()
                }
            }
        }

        updateStatusItem()
    }

    @objc private func allowSleep() {
        stopKeepingAwake()
        updateStatusItem()
    }

    private func stopKeepingAwake() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        activeTag = nil

        if let activity {
            ProcessInfo.processInfo.endActivity(activity)
            self.activity = nil
        }
    }

    private func tick() {
        if let endDate, endDate <= Date() {
            stopKeepingAwake()
        }
        updateStatusItem()
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else { return }

        durationItems.forEach { $0.state = $0.tag == activeTag ? .on : .off }

        guard activity != nil else {
            button.image = NSImage(
                systemSymbolName: "cup.and.saucer",
                accessibilityDescription: "WakeUp inactive"
            )
            button.title = ""
            button.toolTip = "WakeUp: system sleep is allowed"
            return
        }

        button.image = NSImage(
            systemSymbolName: "cup.and.saucer.fill",
            accessibilityDescription: "WakeUp active"
        )

        if let endDate {
            let remaining = max(0, Int(ceil(endDate.timeIntervalSinceNow)))
            button.title = String(format: " %d:%02d", remaining / 60, remaining % 60)
            button.toolTip = "WakeUp: keeping the Mac awake for \(remaining / 60)m \(remaining % 60)s"
        } else {
            button.title = " On"
            button.toolTip = "WakeUp: keeping the Mac awake indefinitely"
        }
    }
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.run()
