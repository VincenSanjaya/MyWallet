import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingAddView = false
    @State private var transactionToEdit: Transaction?
    @Query(sort: \Transaction.date, order: .reverse) var allTransactions: [Transaction]

    @State private var selectedCategory: String = "All"
    let categories = ["All", "Makanan", "Transportasi", "Hiburan", "Belanja", "Lainnya"]

    private func deleteTransaction(at offsets: IndexSet, from filteredTransactions: [Transaction]) {
        let transactionsToDelete = offsets.map { filteredTransactions[$0] }
        for transaction in transactionsToDelete {
            if let account = transaction.account {
                account.balance += transaction.amount
            }
            modelContext.delete(transaction)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                let filteredTodaysTransactions = allTransactions.filter { transaction in
                    let isToday = Calendar.current.isDateInToday(transaction.date)
                    let matchesCategory = selectedCategory == "All" || transaction.category == selectedCategory
                    return isToday && matchesCategory
                }
                
                if !filteredTodaysTransactions.isEmpty {
                    let totalsByAccount = Dictionary(grouping: filteredTodaysTransactions, by: { $0.account?.name ?? "Lainnya" })
                        .mapValues { $0.reduce(0) { $0 + $1.amount } }
                        .sorted(by: { $0.key < $1.key })

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Ringkasan Hari Ini")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 2)
                        
                        ForEach(totalsByAccount, id: \.key) { accountName, total in
                            HStack {
                                Text(accountName)
                                Spacer()
                                Text(total, format: .currency(code: "IDR"))
                            }
                            .font(.subheadline)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Keseluruhan")
                                .font(.headline)
                            Spacer()
                            let grandTotal = filteredTodaysTransactions.reduce(0) { $0 + $1.amount }
                            Text(grandTotal, format: .currency(code: "IDR"))
                                .font(.headline.bold())
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
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
                            Button {
                                transactionToEdit = transaction
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(transaction.name).font(.headline)
                                        HStack(spacing: 4) {
                                            Text(transaction.category)
                                            if let accountName = transaction.account?.name {
                                                Text("•")
                                                Image(systemName: "wallet.pass.fill")
                                                Text(accountName)
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(transaction.amount, format: .currency(code: "IDR")).font(.headline.bold()).foregroundStyle(.red)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .onDelete { offsets in
                            deleteTransaction(at: offsets, from: filteredTodaysTransactions)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(selectedCategory == "All" ? "Hari Ini" : selectedCategory)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Kategori", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { Text($0) }
                        }
                    } label: { Image(systemName: "line.3.horizontal.decrease.circle").font(.title2) }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isShowingAddView.toggle() } label: { Image(systemName: "plus") }
                }
            }
        }
        .sheet(isPresented: $isShowingAddView) {
            TransactionFormView()
        }
        .sheet(item: $transactionToEdit) { transaction in
            TransactionFormView(transactionToEdit: transaction)
        }
    }
}
