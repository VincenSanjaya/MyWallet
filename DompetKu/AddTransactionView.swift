import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    
    @State private var name: String = ""
    @State private var amount: Double = 0
    @State private var category: String = "Makanan"
    @State private var date: Date = .now
    
    
    @State private var selectedAccountID: String?
    
    
    @Query var accounts: [WalletAccount]
    
    
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    let categories = ["Makanan", "Transportasi", "Hiburan", "Belanja", "Lainnya"]
    
    private func saveTransaction() {
        
        guard let accountID = selectedAccountID,
              let selectedAccount = accounts.first(where: { $0.id == accountID }) else {
            alertMessage = "Anda harus memilih sumber dana."
            isShowingAlert = true
            return
        }
        
        selectedAccount.balance -= amount
        
        let newTransaction = Transaction(
            name: name,
            category: category,
            amount: amount,
            date: date,
            account: selectedAccount
        )
        modelContext.insert(newTransaction)
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
                        Text("Harap buat akun di tab Wallet terlebih dahulu.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Dibayar Dengan", selection: $selectedAccountID) {
                            Text("Pilih Akun").tag(String?.none)
                            ForEach(accounts) { account in
                                Text(account.name).tag(account.id as String?)
                            }
                        }
                    }
                }
            }
            .alert(alertMessage, isPresented: $isShowingAlert) { Button("OK") {} }
            .navigationTitle("Transaksi Baru")
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
                            saveTransaction()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
