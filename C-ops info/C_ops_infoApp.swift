//
//  C_ops_infoApp.swift
//  C-ops info
//
//  Created by andr on 09.03.2024.
//

import SwiftUI

@main
struct C_ops_infoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
