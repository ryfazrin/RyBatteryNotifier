import Foundation
import IOKit.ps
import UserNotifications

class BatteryService: ObservableObject {
    @Published var batteryPercentage: Int = 0
    @Published var isCharging: Bool = false

    var timer: Timer?

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        // Jalankan pengecekan awal
        updateBatteryInfo()

        // Monitoring charger setiap 30 detik
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.updateBatteryInfo()
        }
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

                if isCharging {
                    self.monitorChargingStatus(percent: percent)
                }
            }
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
