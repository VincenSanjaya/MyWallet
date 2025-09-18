//
//  BudgetView.swift
//  DompetKu
//
//  Created by Vincen Sanjaya on 18/09/25.
//


import SwiftUI
import SwiftData

struct BudgetView: View {
    @Query var budgets: [Budget]
    @Query var transactions: [Transaction]
    @State private var isShowingAddBudgetView = false

    private func spending(for category: String, in month: Int, year: Int) -> Double {
        transactions.filter { transaction in
            let transactionMonth = Calendar.current.component(.month, from: transaction.date)
            let transactionYear = Calendar.current.component(.year, from: transaction.date)
            return transaction.category == category && transactionMonth == month && transactionYear == year
        }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            VStack {
                let currentMonth = Calendar.current.component(.month, from: .now)
                let currentYear = Calendar.current.component(.year, from: .now)
                let monthlyBudgets = budgets.filter { $0.month == currentMonth && $0.year == currentYear }

                if monthlyBudgets.isEmpty {
                    ContentUnavailableView("Belum Ada Budget", systemImage: "chart.pie", description: Text("Tekan tombol + untuk membuat budget pertamamu bulan ini."))
                } else {
                    List(monthlyBudgets) { budget in
                        VStack(spacing: 10) {
                            let currentSpending = spending(for: budget.category, in: currentMonth, year: currentYear)
                            let progress = min(currentSpending / budget.amount, 1.0)

                            HStack {
                                Text(budget.category).font(.headline)
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.secondary)
                            }

                            ProgressView(value: progress)
                                .tint(progress > 0.9 ? .red : .blue)

                            HStack {
                                Text(currentSpending, format: .currency(code: "IDR"))
                                    .font(.subheadline.bold())
                                Spacer()
                                Text(budget.amount, format: .currency(code: "IDR"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
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