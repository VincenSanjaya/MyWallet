import SwiftUI
import SwiftData

struct BudgetView: View {
    @Query var budgets: [Budget]
    @Query var transactions: [Transaction]
    @State private var isShowingAddBudgetView = false

    private func spending(for category: String, in month: Int, year: Int) -> Double {
        transactions.filter { transaction in
            guard transaction.transactionType == .expense,
                  let transactionCategory = transaction.category else { return false }
            
            let transactionMonth = Calendar.current.component(.month, from: transaction.date)
            let transactionYear = Calendar.current.component(.year, from: transaction.date)
            
            return transactionCategory == category && transactionMonth == month && transactionYear == year
        }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                let currentMonth = Calendar.current.component(.month, from: .now)
                let currentYear = Calendar.current.component(.year, from: .now)
                let monthlyBudgets = budgets.filter { $0.month == currentMonth && $0.year == currentYear }
                
                if monthlyBudgets.isEmpty {
                    Spacer()
                    ContentUnavailableView("Belum Ada Budget", systemImage: "chart.pie", description: Text("Tekan tombol + untuk membuat budget pertamamu bulan ini."))
                    Spacer()
                } else {
                    List {
                        ForEach(monthlyBudgets) { budget in
                            let currentSpending = spending(for: budget.category, in: currentMonth, year: currentYear)
                            BudgetRowView(budget: budget, currentSpending: currentSpending)
                                .listRowBackground(Color.appBackground)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Budget Bulan Ini")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isShowingAddBudgetView.toggle() } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $isShowingAddBudgetView) {
                AddBudgetView()
            }
        }
    }
}
