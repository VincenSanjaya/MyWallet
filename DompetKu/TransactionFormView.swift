import SwiftUI
import SwiftData

struct TransactionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var transactionToEdit: Transaction?
    
    @State private var name: String = ""
    @State private var amount: Double = 0
    @State private var category: String = "Makanan"
    @State private var date: Date = .now
    @State private var selectedAccountID: String?
    
    @Query var accounts: [WalletAccount]
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    let categories = ["Makanan", "Transportasi", "Hiburan", "Belanja", "Lainnya"]
    
    @State private var originalAmount: Double = 0
    @State private var originalAccount: WalletAccount?
    
    private var selectedAccount: WalletAccount? {
        guard let selectedAccountID = selectedAccountID else { return nil }
        return accounts.first { $0.id == selectedAccountID }
    }

    private func save() {
        guard let accountID = selectedAccountID,
              let selectedAccount = accounts.first(where: { $0.id == accountID }) else {
            alertMessage = "Anda harus memilih sumber dana."
            isShowingAlert = true
            return
        }
        
        if let transaction = transactionToEdit {
            originalAccount?.balance += originalAmount
            transaction.name = name
            transaction.amount = amount
            transaction.category = category
            transaction.date = date
            transaction.account = selectedAccount
            selectedAccount.balance -= amount
        } else {
            selectedAccount.balance -= amount
            let newTransaction = Transaction(name: name, category: category, amount: amount, date: date, account: selectedAccount)
            modelContext.insert(newTransaction)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detail Pengeluaran") {
                    TextField("Nama Pengeluaran", text: $name)
                    TextField("Jumlah", value: $amount, format: .currency(code: "IDR")).keyboardType(.decimalPad)
                    Picker("Kategori", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    DatePicker("Tanggal", selection: $date, displayedComponents: .date)
                }
                
                Section("Sumber Dana") {
                    if accounts.isEmpty {
                        Text("Harap buat akun di tab Wallet terlebih dahulu.").foregroundStyle(.secondary)
                    } else {
                        NavigationLink(destination: AccountPickerView(selectedAccountID: $selectedAccountID)) {
                            HStack {
                                Text("Dibayar Dengan")
                                Spacer()
                                if let selectedAccountName = selectedAccount?.name {
                                    Text(selectedAccountName)
                                } else {
                                    Text("Pilih Akun")
                                }
                            }
                        }
                    }
                }
            }
            .foregroundStyle(.primary)
            .alert(alertMessage, isPresented: $isShowingAlert) { Button("OK") {} }
            .navigationTitle(transactionToEdit == nil ? "Transaksi Baru" : "Edit Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            alertMessage = "Nama pengeluaran tidak boleh kosong."
                            isShowingAlert = true
                        } else if amount <= 0 {
                            alertMessage = "Jumlah harus lebih besar dari nol."
                            isShowingAlert = true
                        } else {
                            save()
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                if let transaction = transactionToEdit {
                    name = transaction.name
                    amount = transaction.amount
                    category = transaction.category
                    date = transaction.date
                    selectedAccountID = transaction.account?.id
                    originalAmount = transaction.amount
                    originalAccount = transaction.account
                }
            }
        }
    }
}
