import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) var allTransactions: [Transaction]
    @State private var selectedDate: Date = .now
    @State private var transactionToEdit: Transaction?

    private func deleteTransaction(at offsets: IndexSet, from transactions: [Transaction]) {
        for index in offsets {
            let transaction = transactions[index]
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
                DatePicker("Pilih Tanggal", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .background(Color.white.shadow(color: .black.opacity(0.05), radius: 4, y: 4))

                let transactionsOnSelectedDate = allTransactions.filter { transaction in
                    Calendar.current.isDate(transaction.date, inSameDayAs: selectedDate)
                }
                
                if !transactionsOnSelectedDate.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        let totalIncome = transactionsOnSelectedDate.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
                        let totalExpense = transactionsOnSelectedDate.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }

                        Text("RINGKASAN TANGGAL INI")
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
                
                if transactionsOnSelectedDate.isEmpty {
                    Spacer()
                    ContentUnavailableView("Tidak Ada Data", systemImage: "calendar.badge.exclamationmark", description: Text("Tidak ada transaksi pada tanggal yang dipilih."))
                    Spacer()
                } else {
                    List {
                        ForEach(transactionsOnSelectedDate) { transaction in
                            Button(action: { transactionToEdit = transaction }) {
                                TransactionRowView(transaction: transaction)
                            }
                            .listRowBackground(Color.appBackground)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { offsets in
                            deleteTransaction(at: offsets, from: transactionsOnSelectedDate)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.appBackground)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Riwayat Transaksi")
        }
        .sheet(item: $transactionToEdit) { transaction in
            TransactionFormView(transactionToEdit: transaction)
        }
    }
}
