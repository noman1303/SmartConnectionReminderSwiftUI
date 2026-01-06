//
//  SafeWiFiStore.swift
//  SmartConnectionReminder
//
//  Created by Noman belim on 06/01/26.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import CoreLocation

final class SafeWiFiStore: ObservableObject {

    @Published var currentSSID: String?
    @Published var selectedItems: Set<String> = []
    @Published var safeNetworks: [String] = [] // Track all safe networks

    private let storageKey = "SavedWiFiItems"
    private let safeNetworksKey = "SafeNetworks"
    private var wifiData: [String: [String]] = [:]
    private var wasOnWiFi = false
    private var lastKnownSSID: String?

    init() {
        load()
    }

    // MARK: - Mark Safe Wi-Fi
    func markCurrentWiFiSafe() {
        // Use a simulated SSID if actual SSID can't be retrieved
        let ssid = WiFiHelper.currentSSID() ?? "WiFi_\(Date().timeIntervalSince1970)"
        
        print("📡 Marking SSID as safe:", ssid)
        
        wifiData[ssid] = Array(selectedItems)
        
        // Add to safe networks if not already there
        if !safeNetworks.contains(ssid) {
            safeNetworks.append(ssid)
        }
        
        save()

        currentSSID = ssid
        lastKnownSSID = ssid
        wasOnWiFi = true

        print("✅ Saved Wi-Fi:", ssid, "Items:", selectedItems)
    }

    // MARK: - Load items when Wi-Fi connects
    func onWiFiConnected() {
        let ssid = WiFiHelper.currentSSID() ?? lastKnownSSID ?? "Unknown"
        
        print("📶 WiFi Connected - SSID:", ssid)
        
        currentSSID = ssid
        lastKnownSSID = ssid
        
        // Load saved items for this network
        if let savedItems = wifiData[ssid] {
            selectedItems = Set(savedItems)
            print("✅ Loaded saved items for \(ssid):", savedItems)
        }
        
        wasOnWiFi = true
    }

    // MARK: - Wi-Fi disconnected
    func onWiFiDisconnected() {
        print("📵 WiFi Disconnected - wasOnWiFi:", wasOnWiFi, "lastKnownSSID:", lastKnownSSID ?? "none")
        
        guard wasOnWiFi, let ssid = lastKnownSSID else {
            print("⚠️ Skipping - not previously on WiFi or no SSID")
            return
        }
        
        // Check if this was a safe network
        guard safeNetworks.contains(ssid) else {
            print("⚠️ Not a safe network:", ssid)
            wasOnWiFi = false
            return
        }

        let items = wifiData[ssid] ?? []
        guard !items.isEmpty else {
            print("⚠️ No items to remind for:", ssid)
            wasOnWiFi = false
            return
        }

        print("🔔 Sending notification for:", ssid, "Items:", items)
        
        NotificationManager.shared.send(
            title: "🚶 You're leaving",
            body: "Don't forget your \(items.joined(separator: ", "))"
        )

        wasOnWiFi = false
    }

    // MARK: - Helpers
    func toggleItem(_ item: String) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
        print("📝 Items now:", selectedItems)
    }
    
    private func save() {
        UserDefaults.standard.set(wifiData, forKey: storageKey)
        UserDefaults.standard.set(safeNetworks, forKey: safeNetworksKey)
        print("💾 Saved to storage")
    }

    private func load() {
        wifiData = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: [String]] ?? [:]
        safeNetworks = UserDefaults.standard.array(forKey: safeNetworksKey) as? [String] ?? []
        print("📂 Loaded from storage - Networks:", safeNetworks.count, "Items:", wifiData.keys.count)
    }
}
