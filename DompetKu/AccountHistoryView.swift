import SwiftUI
import SwiftData

struct AccountHistoryView: View {
    let account: WalletAccount

    var body: some View {
        List(account.logs.sorted(by: { $0.date > $1.date })) { log in
            HStack {
                VStack(alignment: .leading) {
                    Text("Saldo Ditambahkan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(log.amountAdded, format: .currency(code: "IDR"))
                        .font(.headline)
                        .foregroundStyle(.green)
                }
                Spacer()
                Text(log.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Riwayat \(account.name)")
    }
}
