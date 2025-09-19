import SwiftUI
import SwiftData

struct TransactionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var transactionToEdit: Transaction?
    
    @State private var name: String = ""
    @State private var amount: Double = 0
    @State private var category: String = ""
    @State private var date: Date = .now
    @State private var selectedAccountID: String?
    @State private var transactionType: TransactionType = .expense
    
    @Query(sort: \Category.name) var categories: [Category]
    @Query var accounts: [WalletAccount]
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    @State private var originalAmount: Double = 0
    @State private var originalAccount: WalletAccount?
    @State private var originalType: TransactionType = .expense
    
    private var selectedAccount: WalletAccount? {
        guard let selectedAccountID = selectedAccountID else { return nil }
        return accounts.first { $0.id == selectedAccountID }
    }

    private func save() {
        guard let accountID = selectedAccountID,
              let selectedAccount = accounts.first(where: { $0.id == accountID }) else {
            alertMessage = "Anda harus memilih sumber/tujuan dana."
            isShowingAlert = true
            return
        }
        
        let categoryToSave = transactionType == .expense ? category : nil
        
        if let transaction = transactionToEdit {
            originalAccount?.balance += (originalType == .income ? -originalAmount : originalAmount)
            transaction.name = name
            transaction.amount = amount
            transaction.category = categoryToSave
            transaction.date = date
            transaction.account = selectedAccount
            transaction.transactionType = transactionType
            selectedAccount.balance += (transactionType == .income ? amount : -amount)
        } else {
            let amountToChange = transactionType == .income ? amount : -amount
            selectedAccount.balance += amountToChange
            let newTransaction = Transaction(name: name, category: categoryToSave, amount: amount, date: date, transactionType: transactionType, account: selectedAccount)
            modelContext.insert(newTransaction)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Jenis Transaksi", selection: $transactionType) {
                    Text("Pengeluaran").tag(TransactionType.expense)
                    Text("Pemasukan").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                
                Section("Detail Transaksi") {
                    if transactionType == .income {
                        TextField("Nama Pemasukan (e.g., Gaji)", text: $name)
                    } else {
                        TextField("Nama Pengeluaran", text: $name)
                    }
                    
                    TextField("Jumlah", value: $amount, format: .currency(code: "IDR")).keyboardType(.decimalPad)
                    
                    if transactionType == .expense {
                        Picker("Kategori", selection: $category) {
                            ForEach(categories) { cat in
                                Text(cat.name).tag(cat.name)
                            }
                        }
                    }
                    
                    DatePicker("Tanggal", selection: $date, displayedComponents: .date)
                }
                
                Section(transactionType == .expense ? "Sumber Dana" : "Tujuan Dana") {
                    NavigationLink(destination: AccountPickerView(selectedAccountID: $selectedAccountID)) {
                        HStack {
                            Text(transactionType == .expense ? "Dibayar Dengan" : "Masuk Ke")
                            Spacer()
                            Text(accounts.first { $0.id == selectedAccountID }?.name ?? "Pilih Akun")
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
                            alertMessage = "Nama transaksi tidak boleh kosong."
                            isShowingAlert = true
                        } else if amount <= 0 {
                            alertMessage = "Jumlah harus lebih besar dari nol."
                            isShowingAlert = true
                        } else if transactionType == .expense && category.isEmpty {
                            alertMessage = "Anda harus memilih kategori."
                            isShowingAlert = true
                        }
                        else {
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
                    category = transaction.category ?? ""
                    date = transaction.date
                    selectedAccountID = transaction.account?.id
                    transactionType = transaction.transactionType
                    
                    originalAmount = transaction.amount
                    originalAccount = transaction.account
                    originalType = transaction.transactionType
                } else if let firstCategory = categories.first {
                    category = firstCategory.name
                }
            }
        }
        .tint(Color.brandPrimary)
    }
}
