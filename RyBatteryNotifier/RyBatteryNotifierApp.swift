//
//  RyBatteryNotifierApp.swift
//  RyBatteryNotifier
//
//  Created by Ryan Pazrin on 21/04/25.
//

import SwiftUI
import UserNotifications

@main
struct RyBatteryNotifierApp: App {
    init() {
        // Minta izin notifikasi saat pertama kali app dijalankan
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Terjadi kesalahan saat meminta izin notifikasi: \(error.localizedDescription)")
            } else if granted {
                print("✅ Izin notifikasi diberikan.")
            } else {
                print("⚠️ Izin notifikasi ditolak.")
            }
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
