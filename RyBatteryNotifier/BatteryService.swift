import Foundation
import IOKit.ps
import UserNotifications

class BatteryService: ObservableObject {
    @Published var batteryPercentage: Int = 0
    @Published var isCharging: Bool = false
    
    @Published var autoDischargeEnabled: Bool = UserDefaults.standard.bool(forKey: "autoDischargeEnabled")
    @Published var isInDischargeMode: Bool = false

    var timer: Timer?

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        // Monitoring charger setiap 30 detik
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.updateBatteryInfo()
        }
        // Jalankan pengecekan awal
        updateBatteryInfo()
    }

    func updateBatteryInfo() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return
        }

        for ps in sources {
            if let info = IOPSGetPowerSourceDescription(snapshot, ps)?.takeUnretainedValue() as? [String: Any],
               let isCharging = info[kIOPSIsChargingKey as String] as? Bool,
               let capacity = info[kIOPSCurrentCapacityKey as String] as? Int,
               let max = info[kIOPSMaxCapacityKey as String] as? Int {

                let percent = Int((Double(capacity) / Double(max)) * 100)

                DispatchQueue.main.async {
                    self.batteryPercentage = percent
                    self.isCharging = isCharging
                }

                let maxLimit = UserDefaults.standard.integer(forKey: "maxLimit")

                // Auto Discharge Logic
                if autoDischargeEnabled {
                    if isCharging && percent >= maxLimit {
                        // Simulasi masuk ke mode discharge
                        DispatchQueue.main.async {
                            self.isInDischargeMode = true
                        }
                        sendDischargePrompt()
                        print("🛑 Masuk ke mode Discharge otomatis")
                        return
                    } else {
                        DispatchQueue.main.async {
                            self.isInDischargeMode = false
                        }
                    }
                }

                if isCharging && !isInDischargeMode && percent >= maxLimit {
                    self.sendNotification()
                }
            }
        }
    }
    
    func sendDischargePrompt() {
        let content = UNMutableNotificationContent()
        content.title = "🔋 Auto Discharge Aktif"
        content.body = "Charger tetap terpasang, tapi mode Discharge diaktifkan. Cabut charger secara manual."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func forceDischargeViaCLI() {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["aldente-cli", "discharge", "true"]

        do {
            try process.run()
        } catch {
            print("❌ Gagal menjalankan perintah discharge: \(error)")
        }
    }

    func monitorChargingStatus(percent: Int) {
        let maxLimit = UserDefaults.standard.integer(forKey: "maxLimit")
        if percent >= maxLimit {
            sendNotification()
        }
    }

    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "⚡ Baterai Mencapai Batas"
        content.body = "Baterai sudah mencapai batas maksimum. Silakan cabut charger."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
