//
//  ContentView.swift
//  RyBatteryNotifier
//
//  Created by Ryan Pazrin on 21/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var batteryService = BatteryService()
    @AppStorage("maxLimit") var maxLimit: Int = 80
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔋 RyBattery Notifier")
                .font(.largeTitle)
                .padding(.top)

            Text("Baterai Sekarang: \(batteryService.batteryPercentage)%")
                .font(.title2)

            Stepper(value: $maxLimit, in: 50...100, step: 5) {
                Text("Batas Maksimal: \(maxLimit)%")
            }

            Text(batteryService.isCharging ? "🔌 Sedang Charging" : "🔋 Tidak Charging")
                .foregroundColor(batteryService.isCharging ? .green : .red)
            
            Spacer()

        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

#Preview {
    ContentView()
}
