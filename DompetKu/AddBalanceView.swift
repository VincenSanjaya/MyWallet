import SwiftUI
import SwiftData

struct AddBalanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    let account: WalletAccount
    @State private var amountToAdd: Double = 0

    private func saveLogAndUpdateBalance() {
        guard amountToAdd > 0 else { return }

        account.balance += amountToAdd

        let newLog = AccountLog(amountAdded: amountToAdd, date: .now, account: account)
        modelContext.insert(newLog)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tambah Saldo untuk \(account.name)") {
                    TextField("Jumlah", value: $amountToAdd, format: .currency(code: "IDR"))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Tambah Saldo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        saveLogAndUpdateBalance()
                        dismiss()
                    }
                }
            }
        }
    }
}
