//
//  Pokemon_IOSApp.swift
//  Pokemon-IOS
//
//  Created by Carlos Molina Sáenz on 07/12/23.
//

import SwiftUI

@main
struct Pokemon_IOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
