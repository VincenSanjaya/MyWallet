import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Transaction.date, order: .reverse) var allTransactions: [Transaction]
    @State private var selectedDate: Date = .now

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
                    let totalsByAccount = Dictionary(grouping: transactionsOnSelectedDate, by: { $0.account?.name ?? "Lainnya" })
                        .mapValues { $0.reduce(0) { $0 + $1.amount } }
                        .sorted(by: { $0.key < $1.key })

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Ringkasan Pengeluaran")
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
                            let grandTotal = transactionsOnSelectedDate.reduce(0) { $0 + $1.amount }
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
                
                if transactionsOnSelectedDate.isEmpty {
                    Spacer()
                    ContentUnavailableView("Tidak Ada Data", systemImage: "calendar.badge.exclamationmark", description: Text("Tidak ada transaksi pada tanggal yang dipilih."))
                    Spacer()
                } else {
                    List {
                        ForEach(transactionsOnSelectedDate) { transaction in
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
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Riwayat Transaksi")
        }
    }
}
