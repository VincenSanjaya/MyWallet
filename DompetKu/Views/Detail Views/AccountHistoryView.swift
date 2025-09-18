import SwiftUI
import SwiftData

struct AccountHistoryView: View {
    let account: WalletAccount
    
    @State private var historyType: HistoryType = .pemasukan

    enum HistoryType: String, CaseIterable {
        case pemasukan = "Pemasukan"
        case pengeluaran = "Pengeluaran"
    }
    
    var body: some View {
        VStack {
            Picker("Pilih Riwayat", selection: $historyType) {
                ForEach(HistoryType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if historyType == .pemasukan {
                if account.logs.isEmpty {
                    ContentUnavailableView("Tidak Ada Pemasukan", systemImage: "plus.circle", description: Text("Belum ada saldo yang ditambahkan ke akun ini."))
                } else {
                    List(account.logs.sorted(by: { $0.date > $1.date })) { log in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Saldo Ditambahkan")
                                    .font(.headline)
                                Text(log.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(log.amountAdded, format: .currency(code: "IDR"))
                                .font(.headline.bold())
                                .foregroundStyle(.green)
                        }
                    }
                }
            } else {
                let transactions = account.transactions ?? []
                if transactions.isEmpty {
                    ContentUnavailableView("Tidak Ada Pengeluaran", systemImage: "minus.circle", description: Text("Akun ini belum pernah digunakan untuk transaksi."))
                } else {
                    List(transactions.sorted(by: { $0.date > $1.date })) { transaction in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(transaction.name)
                                    .font(.headline)
                                
                                if let categoryName = transaction.category {
                                    Text(categoryName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(transaction.amount, format: .currency(code: "IDR"))
                                    .font(.headline.bold())
                                    .foregroundStyle(.red)
                                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Riwayat \(account.name)")
    }
}
