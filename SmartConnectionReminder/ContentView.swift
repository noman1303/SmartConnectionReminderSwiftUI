//
//  ContentView.swift
//  SmartConnectionReminder
//
//  Created by Noman belim on 06/01/26.
//
import SwiftUI

import SwiftUI

struct ContentView: View {

    @StateObject private var network = NetworkMonitor()
    @StateObject private var store = SafeWiFiStore()
    @StateObject private var locationManager = LocationManager()
    private let items = [
        "Wallet", "Keys", "Cards", "Bag", "Tablet", "Headphones"
    ]
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                Button("Mark Current Wi-Fi as Safe 🏠") {
                    store.markCurrentWiFiSafe()
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.selectedItems.isEmpty || !network.isOnWiFi)

                Text("Connected Wi-Fi: \(store.currentSSID ?? "None")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !store.safeNetworks.isEmpty {
                    Text("Safe Networks: \(store.safeNetworks.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }

                List(items, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        if store.selectedItems.contains(item) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        store.toggleItem(item)
                    }
                }

                Text(network.isOnWiFi ? "📶 Wi-Fi Connected" : "❌ Wi-Fi Disconnected")
                    .foregroundColor(network.isOnWiFi ? .green : .red)
                    .font(.headline)
            }
            .padding()
            .navigationTitle("Smart Reminder")
            .onChange(of: network.isOnWiFi) { value in
                value ? store.onWiFiConnected() : store.onWiFiDisconnected()
            }
        }
    }
}
#Preview {
    ContentView()
}
