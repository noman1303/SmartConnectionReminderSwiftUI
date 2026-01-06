 📡 Smart Connection Reminder (SwiftUI)

A smart iOS demo app built using SwiftUI that reminds users to carry important items (wallet, keys, bag, etc.) when they leave a trusted Wi-Fi network like home or office.

⸻

🚀 Features
    •    ✅ Detects Wi-Fi connection & disconnection
    •    ✅ Allows users to mark multiple Wi-Fi networks as safe
    •    ✅ Stores different reminder items for each Wi-Fi
    •    ✅ Automatically reloads saved items when reconnecting
    •    ✅ Sends local notification when Wi-Fi disconnects
    •    ✅ Built with SwiftUI + Combine
    •    ✅ Apple-policy compliant implementation

⸻

🧠 How This App Works (High Level)
    1.    User connects to a Wi-Fi (Home / Office)
    2.    User selects important items (wallet, keys, bag, etc.)
    3.    User marks the current Wi-Fi as Safe
    4.    App saves:
    •    Wi-Fi name (SSID)
    •    Selected items
    5.    When Wi-Fi disconnects:
    •    App assumes user is leaving
    •    Sends a local notification reminding selected items
    6.    If the same Wi-Fi reconnects later:
    •    Previously selected items are auto-loaded
    •    No need to select again

⸻

📱 Example

Wi-Fi Name    Selected Items    Notification
nomanwifi    Wallet, Keys    Don’t forget your Wallet, Keys
myWifi    Bag    Don’t forget your Bag


⸻

🏗️ Project Architecture

SmartConnectionReminder
│
├── SmartConnectionReminderApp.swift
├── ContentView.swift
│
├── NetworkMonitor.swift
├── SafeWiFiStore.swift
├── WiFiHelper.swift
├── LocationManager.swift
├── NotificationManager.swift


⸻

📂 File-Wise Explanation

🔹 SmartConnectionReminderApp.swift
    •    App entry point
    •    Requests notification permission
    •    Registers notification delegate (to show banners in foreground)

⸻

🔹 ContentView.swift
    •    Main SwiftUI UI
    •    Shows:
    •    Current Wi-Fi name
    •    List of selectable items
    •    “Mark Wi-Fi as Safe” button
    •    Observes Wi-Fi changes using NetworkMonitor
    •    Triggers save / notify logic via SafeWiFiStore

⸻

🔹 NetworkMonitor.swift

Uses NWPathMonitor to detect:
    •    Wi-Fi connected
    •    Wi-Fi disconnected

path.usesInterfaceType(.wifi)

This is Apple-recommended way to monitor network changes.

⸻

🔹 SafeWiFiStore.swift (Core Logic)

This is the brain of the app.

Responsibilities:
    •    Stores Wi-Fi → items mapping
    •    Saves data using UserDefaults
    •    Loads items when Wi-Fi reconnects
    •    Sends notification when Wi-Fi disconnects

Example storage structure:

[
  "nomanwifi": ["Wallet", "Keys"],
  "myWifi": ["Bag"]
]


⸻

🔹 WiFiHelper.swift

Fetches the current Wi-Fi name (SSID) using:

CNCopyCurrentNetworkInfo

⚠️ Requires:
    •    Location permission
    •    Access Wi-Fi Information capability
    •    Real iPhone (not Simulator)

⸻

🔹 LocationManager.swift

Requests Location permission, required by iOS to access Wi-Fi name.

manager.requestWhenInUseAuthorization()


⸻

🔹 NotificationManager.swift

Handles:
    •    Notification permission
    •    Local notification scheduling

Uses:
    •    UNUserNotificationCenter
    •    UNTimeIntervalNotificationTrigger

⸻

🔔 Notification Example

🚶 You’re leaving
Don’t forget your Wallet, Keys

Only the selected items are included.

⸻

🔐 Required Permissions & Capabilities

📌 Info.plist

NSLocationWhenInUseUsageDescription

📌 Xcode → Signing & Capabilities
    •    ✅ Access Wi-Fi Information
    •    ✅ Background Modes (optional, for better reliability)

⸻

⚠️ Important Apple Limitations (Very Important)
    •    ❌ iOS Simulator cannot detect real Wi-Fi names SOMETIMES 
    •    ❌ SSID may not be available if app is force-killed
    •    ❌ Continuous background tracking is not allowed

✅ This app follows Apple’s privacy & security rules

⸻

🧪 Testing Notes

✔ Test on real iPhone
✔ Allow Location & Notification permissions
✔ App should be in foreground or background (not killed)

⸻

🎯 Use Cases
    •    Forgetting wallet or keys at home
    •    Leaving office without laptop bag
    •    Gym / hostel reminders
    •    Demo for network-based automation

⸻

🧩 Technologies Used
    •    SwiftUI
    •    Combine
    •    Network framework
    •    CoreLocation
    •    UserNotifications

⸻

📌 Why This Project Is Valuable
    •    Real-world iOS use case
    •    Demonstrates Apple limitations correctly
    •    Interview-ready explanation
    •    Can be extended to:
    •    CoreLocation
    •    Time-based reminders
    •    Custom item creation

⸻

🏁 Conclusion

Smart Connection Reminder is a practical SwiftUI demo that shows how to build a Wi-Fi-aware reminder system while respecting Apple’s privacy rules. It demonstrates clean architecture, system frameworks, and real-world constraints every iOS developer must understand.

⸻
 
