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
            VStack {
                DatePicker("Pilih Tanggal", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)

                let transactionsOnSelectedDate = allTransactions.filter { transaction in
                    Calendar.current.isDate(transaction.date, inSameDayAs: selectedDate)
                }
                
                if !transactionsOnSelectedDate.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        let totalIncome = transactionsOnSelectedDate.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
                        let totalExpense = transactionsOnSelectedDate.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }

                        Text("Ringkasan Tanggal Ini")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 2)
                        
                        HStack {
                            Text("Pemasukan")
                            Spacer()
                            Text(totalIncome, format: .currency(code: "IDR"))
                                .foregroundStyle(.green)
                        }
                        .font(.subheadline)
                        
                        HStack {
                            Text("Pengeluaran")
                            Spacer()
                            Text(totalExpense, format: .currency(code: "IDR"))
                                .foregroundStyle(.red)
                        }
                        .font(.subheadline)
                        
                        Divider()
                        
                        HStack {
                            Text("Arus Kas Bersih")
                                .font(.headline)
                            Spacer()
                            Text(totalIncome - totalExpense, format: .currency(code: "IDR"))
                                .font(.headline.bold())
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                if transactionsOnSelectedDate.isEmpty {
                    Spacer()
                    ContentUnavailableView("Tidak Ada Data", systemImage: "calendar.badge.exclamationmark", description: Text("Tidak ada transaksi pada tanggal yang dipilih."))
                    Spacer()
                } else {
                    List {
                        ForEach(transactionsOnSelectedDate) { transaction in
                            Button(action: { transactionToEdit = transaction }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(transaction.name).font(.headline)
                                        HStack(spacing: 4) {
                                            if let categoryName = transaction.category {
                                                Text(categoryName)
                                            }

                                            if let accountName = transaction.account?.name {
                                                Text(transaction.category == nil ? "" : "•")
                                                Image(systemName: "wallet.pass.fill")
                                                Text(accountName)
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(transaction.amount, format: .currency(code: "IDR"))
                                        .font(.headline.bold())
                                        .foregroundStyle(transaction.transactionType == .income ? .green : .red)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .onDelete { offsets in
                            deleteTransaction(at: offsets, from: transactionsOnSelectedDate)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Riwayat Transaksi")
        }
        .sheet(item: $transactionToEdit) { transaction in
            TransactionFormView(transactionToEdit: transaction)
        }
    }
}
