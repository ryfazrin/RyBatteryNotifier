//
//  StatusBarController.swift
//  RyBatteryNotifier
//
//  Created by Ryan Pazrin on 21/04/25.
//

import AppKit
import SwiftUI

class StatusBarController {
    private var statusItem: NSStatusItem!
    private var dischargeAction: () -> Void
    private var showAppAction: () -> Void

    init(dischargeAction: @escaping () -> Void, showAppAction: @escaping () -> Void) {
        self.dischargeAction = dischargeAction
        self.showAppAction = showAppAction

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "battery.100", accessibilityDescription: "Battery Notifier")

        constructMenu()
    }

    private func constructMenu() {
        let menu = NSMenu()

        let dischargeItem = NSMenuItem(title: "Discharge Mode", action: #selector(dischargeMode), keyEquivalent: "d")
        dischargeItem.target = self

        let showAppItem = NSMenuItem(title: "Show App", action: #selector(showApp), keyEquivalent: "s")
        showAppItem.target = self

        let quitItem = NSMenuItem(title: "Quit RyBatteryNotifier", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self

        menu.addItem(dischargeItem)
        menu.addItem(showAppItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)

        statusItem.menu = menu
    }


    @objc private func dischargeMode() {
        dischargeAction()
    }

    @objc private func showApp() {
        showAppAction()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
