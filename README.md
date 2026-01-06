# 📡 Smart Connection Reminder (SwiftUI)

> A smart iOS demo app built using SwiftUI that reminds users to carry important items (wallet, keys, bag, etc.) when they leave a trusted Wi-Fi network like home or office.

This project demonstrates real-world iOS system behavior, Apple privacy rules, and proper use of networking and notifications using SwiftUI.

---

## 🚀 Features

- ✅ Detects Wi-Fi connection & disconnection
- ✅ Supports multiple trusted Wi-Fi networks
- ✅ Stores different reminder items per Wi-Fi
- ✅ Automatically reloads saved items when reconnecting
- ✅ Sends local notifications on Wi-Fi disconnect
- ✅ Built using SwiftUI + Combine
- ✅ Apple App Store–compliant approach

---

https://github.com/user-attachments/assets/0d0c0557-46bf-45d4-9844-0bff201005c4



## 🧠 How the App Works (High Level)

1. **User connects to a Wi-Fi network** (Home / Office)
2. **User selects important items** (wallet, keys, bag, etc.)
3. **User taps "Mark Current Wi-Fi as Safe"**
4. **App saves:**
   - Wi-Fi name (SSID)
   - Selected reminder items
5. **When Wi-Fi disconnects:**
   - App assumes the user is leaving
   - Sends a local notification with selected items
6. **When the same Wi-Fi reconnects:**
   - Previously selected items are auto-loaded
   - User does not need to select again

---

## 📱 Example Scenario

| Wi-Fi Name | Saved Items  | Notification |
|------------|--------------|--------------|
| nomanwifi  | Wallet, Keys | Don't forget your Wallet, Keys |
| myWifi     | Bag          | Don't forget your Bag |

---

## 🏗️ Project Architecture (SwiftUI)

```
SmartConnectionReminder
│
├── SmartConnectionReminderApp.swift
├── ContentView.swift
│
├── NetworkMonitor.swift
├── SafeWiFiStore.swift
├── WiFiHelper.swift
├── LocationManager.swift
└── NotificationManager.swift
```

> 🔹 **Business logic files are shared with UIKit**  
> 🔹 **Only the UI layer is SwiftUI**

---

## 📂 File-Wise Explanation

### 🔹 SmartConnectionReminderApp.swift
- App entry point using SwiftUI's `@main` attribute
- Requests notification permission on launch
- Registers notification delegate so banners show even when app is active

**Key code:**
```swift
@main
struct SmartDisconnectionReminderApp: App {
    let delegate = NotificationDelegate()
    
    init() {
        NotificationManager.shared.requestPermission()
        UNUserNotificationCenter.current().delegate = delegate
    }
}
```

### 🔹 ContentView.swift

**Main SwiftUI view that:**
- Displays current Wi-Fi name
- Shows selectable items using SwiftUI `List`
- Provides "Mark Current Wi-Fi as Safe" button
- Observes network changes using `@StateObject`
- Triggers save and notification logic via `SafeWiFiStore`

**Key implementation:**
```swift
@StateObject private var network = NetworkMonitor()
@StateObject private var store = SafeWiFiStore()

var body: some View {
    NavigationView {
        VStack {
            Button("Mark Current Wi-Fi as Safe 🏠") {
                store.markCurrentWiFiSafe()
            }
            .disabled(store.selectedItems.isEmpty || !network.isOnWiFi)
            
            List(items, id: \.self) { item in
                HStack {
                    Text(item)
                    Spacer()
                    if store.selectedItems.contains(item) {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                .onTapGesture {
                    store.toggleItem(item)
                }
            }
        }
        .onChange(of: network.isOnWiFi) { value in
            value ? store.onWiFiConnected() : store.onWiFiDisconnected()
        }
    }
}
```

**SwiftUI features used:**
- `@StateObject` for reactive state management
- `.onChange(of:)` modifier for network state observation
- Declarative UI with `List` and `Button`
- Automatic view updates via `@Published` properties

### 🔹 NetworkMonitor.swift

Uses `NWPathMonitor` to detect network changes in real-time.

**Key code:**
```swift
final class NetworkMonitor: ObservableObject {
    @Published var isOnWiFi = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isOnWiFi = path.usesInterfaceType(.wifi)
            }
        }
        monitor.start(queue: queue)
    }
}
```

This is the Apple-recommended API for network monitoring and publishes Wi-Fi state changes via `@Published var isOnWiFi`.

### 🔹 SafeWiFiStore.swift (Core Logic)

**The brain of the app.**

**Responsibilities:**
- Stores Wi-Fi → item mapping
- Persists data using `UserDefaults`
- Loads saved items on Wi-Fi reconnect
- Sends notification on Wi-Fi disconnect

**Key methods:**

**1. Marking a Wi-Fi as safe:**
```swift
func markCurrentWiFiSafe() {
    let ssid = WiFiHelper.currentSSID() ?? "WiFi_\(Date().timeIntervalSince1970)"
    wifiData[ssid] = Array(selectedItems)
    
    if !safeNetworks.contains(ssid) {
        safeNetworks.append(ssid)
    }
    
    save() // Persist to UserDefaults
}
```

**2. Handling Wi-Fi connect:**
```swift
func onWiFiConnected() {
    let ssid = WiFiHelper.currentSSID() ?? lastKnownSSID ?? "Unknown"
    currentSSID = ssid
    
    // Load saved items for this network
    if let savedItems = wifiData[ssid] {
        selectedItems = Set(savedItems)
    }
    
    wasOnWiFi = true
}
```

**3. Handling Wi-Fi disconnect:**
```swift
func onWiFiDisconnected() {
    guard wasOnWiFi, let ssid = lastKnownSSID else { return }
    guard safeNetworks.contains(ssid) else { return }
    
    let items = wifiData[ssid] ?? []
    guard !items.isEmpty else { return }
    
    NotificationManager.shared.send(
        title: "🚶 You're leaving",
        body: "Don't forget your \(items.joined(separator: ", "))"
    )
    
    wasOnWiFi = false
}
```

**Internal storage format:**
```json
{
  "nomanwifi": ["Wallet", "Keys"],
  "myWifi": ["Bag"]
}
```

### 🔹 WiFiHelper.swift

Fetches the current Wi-Fi name (SSID) using Apple's network APIs.

**Key code:**
```swift
static func currentSSID() -> String? {
    guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
    
    for interface in interfaces {
        if let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
            return info[kCNNetworkInfoKeySSID as String] as? String
        }
    }
    return nil
}
```

**⚠️ Requires:**
- Location permission
- Access Wi-Fi Information capability
- Real iPhone device (not Simulator)

### 🔹 LocationManager.swift

Requests location permission, which iOS requires to access Wi-Fi information.

**Key code:**
```swift
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
}
```

Without location permission, `currentSSID()` returns `nil`.

### 🔹 NotificationManager.swift

Handles local notification scheduling and permission requests.

**Key methods:**

**1. Request permission:**
```swift
func requestPermission() {
    UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound]) { granted, _ in
            print("🔔 Notification permission:", granted)
        }
}
```

**2. Send notification:**
```swift
func send(title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: 1,
        repeats: false
    )
    
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(request)
}
```

Notifications appear 1 second after Wi-Fi disconnect.

### 🔹 NotificationDelegate (in NetworkMonitor.swift)

Ensures notifications appear as banners even when the app is in the foreground.

**Key code:**
```swift
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
```

---

## 🔔 Notification Example

```
🚶 You're leaving
Don't forget your Wallet, Keys
```

*Only the items selected for that Wi-Fi are shown.*

---

## 🔐 Required Permissions & Capabilities

### 📌 Info.plist

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to detect Wi-Fi network name</string>
```

### 📌 Xcode → Signing & Capabilities

- ✅ Access Wi-Fi Information
- ✅ Background Modes (optional, improves reliability)

### 📌 Entitlements File

```xml
<key>com.apple.external-accessory.wireless-configuration</key>
<true/>
```

---

## ⚠️ Important Apple Limitations

> **Must Read**

- ❌ iOS Simulator cannot provide real Wi-Fi SSID
- ❌ SSID may not be available if app is force-killed
- ❌ Continuous background Wi-Fi tracking is not allowed

✅ **This app follows Apple's privacy and security rules**

---

## 🧪 Testing Guidelines

- ✔ Test on a real iPhone
- ✔ Allow Location & Notification permissions
- ✔ Keep app in foreground or background (do not force kill)

**Testing flow:**
1. Connect to Wi-Fi
2. Select items (Wallet, Keys)
3. Tap "Mark Current Wi-Fi as Safe"
4. Turn off Wi-Fi or walk away from network
5. Notification appears: "Don't forget your Wallet, Keys"

---

## 🎯 Use Cases

- Forgetting wallet or keys at home
- Leaving office without laptop bag
- Hostel / PG reminders
- Network-based automation demo
- Interview-ready system design example

---

## 🧩 Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for state observation
- **Network framework** - Wi-Fi monitoring via `NWPathMonitor`
- **CoreLocation** - Location permissions for SSID access
- **UserNotifications** - Local notifications
- **SystemConfiguration** - Wi-Fi SSID retrieval

---

## 📌 Why This Project Is Valuable

- Demonstrates real iOS system limitations
- Clean separation of UI and logic
- Shows proper permission handling
- Ideal for:
  - Technical interviews
  - Learning system APIs
  - Utility app demos
  - Understanding SwiftUI patterns

---

## 🔄 UIKit vs SwiftUI

This project is also available in **UIKit**. Both versions share the same business logic:

| Aspect | SwiftUI Version | UIKit Version |
|--------|-----------------|---------------|
| UI Framework | SwiftUI | UIKit |
| Business Logic | ✅ Same | ✅ Same |
| State Management | @StateObject, @Published | Combine + manual updates |
| Code Style | Declarative | Imperative |
| Best For | Modern iOS dev | Learning UIKit |

---

## 🏁 Conclusion

Smart Connection Reminder (SwiftUI) is a practical example of building a Wi-Fi–aware reminder system using SwiftUI while respecting Apple's privacy policies. It demonstrates how to work with system frameworks, persistence, and notifications in a real-world iOS app.

The project showcases:
- Network monitoring with `NWPathMonitor`
- Wi-Fi SSID detection with proper permissions
- Data persistence with `UserDefaults`
- Local notifications with `UNUserNotificationCenter`
- Reactive UI updates with SwiftUI and Combine
- Clean architecture separating UI from business logic
- Declarative UI with SwiftUI's modern syntax

---

## 📝 License

This project is available for educational and demonstration purposes.  
