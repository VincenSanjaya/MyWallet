import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingAddView = false
    @State private var transactionToEdit: Transaction?
    @Query(sort: \Transaction.date, order: .reverse) var allTransactions: [Transaction]

    @State private var selectedCategory: String = "All"
    @Query(sort: \Category.name) var categories: [Category]

    private func deleteTransaction(at offsets: IndexSet, from filteredTransactions: [Transaction]) {
        for index in offsets {
            let transaction = filteredTransactions[index]
            if let account = transaction.account {
                let amountToChange = transaction.transactionType == .income ? -transaction.amount : transaction.amount
                account.balance += amountToChange
            }
            modelContext.delete(transaction)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                let filteredTodaysTransactions = allTransactions.filter { transaction in
                    let isToday = Calendar.current.isDateInToday(transaction.date)
                    let matchesCategory = selectedCategory == "All" || transaction.category == selectedCategory
                    return isToday && matchesCategory
                }
                
                if !filteredTodaysTransactions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        let totalIncome = filteredTodaysTransactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
                        let totalExpense = filteredTodaysTransactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }

                        Text("RINGKASAN HARI INI")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.top)
                        
                        HStack {
                            Text("Pemasukan")
                            Spacer()
                            Text(totalIncome, format: .currency(code: "IDR"))
                                .foregroundStyle(Color.accentIncome)
                        }
                        .font(.subheadline)
                        
                        HStack {
                            Text("Pengeluaran")
                            Spacer()
                            Text(totalExpense, format: .currency(code: "IDR"))
                                .foregroundStyle(Color.accentExpense)
                        }
                        .font(.subheadline)
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(totalIncome - totalExpense, format: .currency(code: "IDR"))
                                .font(.headline.bold())
                                .foregroundStyle(Color.textPrimary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding()
                }
                
                if filteredTodaysTransactions.isEmpty {
                    Spacer()
                    let description = selectedCategory == "All"
                        ? "Hari ini belum ada transaksi apa apa."
                        : "Tidak ada transaksi di kategori ini untuk hari ini."
                    ContentUnavailableView("Belum Ada Transaksi", systemImage: "sun.max.fill", description: Text(description))
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTodaysTransactions) { transaction in
                            Button(action: { transactionToEdit = transaction }) {
                                TransactionRowView(transaction: transaction)
                            }
                            .listRowBackground(Color.appBackground)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { offsets in
                            deleteTransaction(at: offsets, from: filteredTodaysTransactions)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.appBackground)
                }
            }
            .background(Color.appBackground)
            .navigationTitle(selectedCategory == "All" ? "Hari Ini" : selectedCategory)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Kategori", selection: $selectedCategory) {
                            Text("All").tag("All")
                            ForEach(categories) { cat in Text(cat.name).tag(cat.name) }
                        }
                    } label: { Image(systemName: "line.3.horizontal.decrease.circle").font(.title2) }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isShowingAddView.toggle() } label: { Image(systemName: "plus") }
                }
            }
        }
        .sheet(isPresented: $isShowingAddView) { TransactionFormView() }
        .sheet(item: $transactionToEdit) { transaction in TransactionFormView(transactionToEdit: transaction) }
    }
}
