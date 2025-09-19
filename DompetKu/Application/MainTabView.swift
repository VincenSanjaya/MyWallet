import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var categories: [Category]
    @Query var recurringTransactions: [RecurringTransaction]
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Hari Ini", systemImage: "sun.max.fill") }
            
            HistoryView()
                .tabItem { Label("Riwayat", systemImage: "calendar") }
            
            BudgetView()
                .tabItem { Label("Budget", systemImage: "chart.pie.fill") }
            
            ReportsView()
                .tabItem { Label("Laporan", systemImage: "chart.bar.xaxis") }

            WalletView()
                .tabItem { Label("Wallet", systemImage: "wallet.pass.fill") }
        }
        .onAppear {
            createDefaultCategories()
            processRecurringTransactions()
        }
    }
    
    private func createDefaultCategories() {
        if categories.isEmpty {
            let defaultCategories = [
                Category(name: "Makanan"),
                Category(name: "Transportasi"),
                Category(name: "Hiburan"),
                Category(name: "Belanja"),
                Category(name: "Kesehatan"),
                Category(name: "Pendidikan"),
                Category(name: "Lainnya")
            ]
            
            for category in defaultCategories {
                modelContext.insert(category)
            }
        }
    }
    
    private func processRecurringTransactions() {
        let calendar = Calendar.current
        
        for item in recurringTransactions {
            while item.nextOccurrenceDate <= .now {
                let newTransaction = Transaction(
                    name: item.name,
                    category: item.category,
                    amount: item.amount,
                    date: item.nextOccurrenceDate,
                    transactionType: item.transactionType,
                    account: item.account
                )
                
                modelContext.insert(newTransaction)
                
                if let account = item.account {
                    let amountToChange = item.transactionType == .income ? item.amount : -item.amount
                    account.balance += amountToChange
                }
                
                switch item.cycle {
                case .daily:
                    item.nextOccurrenceDate = calendar.date(byAdding: .day, value: 1, to: item.nextOccurrenceDate) ?? item.nextOccurrenceDate
                case .weekly:
                    item.nextOccurrenceDate = calendar.date(byAdding: .weekOfYear, value: 1, to: item.nextOccurrenceDate) ?? item.nextOccurrenceDate
                case .monthly:
                    item.nextOccurrenceDate = calendar.date(byAdding: .month, value: 1, to: item.nextOccurrenceDate) ?? item.nextOccurrenceDate
                case .yearly:
                    item.nextOccurrenceDate = calendar.date(byAdding: .year, value: 1, to: item.nextOccurrenceDate) ?? item.nextOccurrenceDate
                }
            }
        }
    }
}
