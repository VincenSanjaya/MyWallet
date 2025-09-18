import SwiftUI
import SwiftData

@main
struct DompetKuApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Transaction.self, WalletAccount.self, AccountLog.self, Budget.self, Category.self, RecurringTransaction.self])

    }
}
