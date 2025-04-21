//
//  AppDelegate.swift
//  RyBatteryNotifier
//
//  Created by Ryan Pazrin on 21/04/25.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController(
            dischargeAction: {
                print("🔋 Mode Discharge diaktifkan (simulasi)")
                // Kamu bisa tambahkan logika real untuk SMC atau logik internal
            },
            showAppAction: {
                NSApp.activate(ignoringOtherApps: true)
            }
        )
    }
}
