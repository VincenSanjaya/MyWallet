import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var categories: [Category]
    
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
        .onAppear(perform: createDefaultCategories)
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
}
