import SwiftUI
import SwiftData

struct AccountPickerView: View {
    @Binding var selectedAccountID: String?
    @Query var accounts: [WalletAccount]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List(accounts) { account in
            Button(action: {
                selectedAccountID = account.id
                dismiss()
            }) {
                HStack {
                    Text(account.name)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(account.balance, format: .currency(code: "IDR"))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Pilih Akun")
        .navigationBarTitleDisplayMode(.inline)
    }
}
