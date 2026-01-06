//
//  SmartConnectionReminderApp.swift
//  SmartConnectionReminder
//
//  Created by Noman belim on 06/01/26.
//
import SwiftUI
import UserNotifications

@main
struct SmartDisconnectionReminderApp: App {

    let delegate = NotificationDelegate()

    init() {
        NotificationManager.shared.requestPermission()
        UNUserNotificationCenter.current().delegate = delegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
 
 
