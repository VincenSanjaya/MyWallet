import SwiftUI
import SwiftData

struct AddRecurringView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var amount: Double = 0
    @State private var category: String = ""
    @State private var selectedAccountID: String?
    @State private var transactionType: TransactionType = .expense
    @State private var cycle: RecurrenceCycle = .monthly
    @State private var startDate: Date = .now

    @Query(sort: \Category.name) var categories: [Category]
    @Query var accounts: [WalletAccount]

    private func save() {
        guard !name.isEmpty, amount > 0, let accountID = selectedAccountID, let account = accounts.first(where: { $0.id == accountID }) else { return }

        let categoryToSave = transactionType == .expense ? category : nil
        let newRecurring = RecurringTransaction(name: name, category: categoryToSave, amount: amount, transactionType: transactionType, cycle: cycle, startDate: startDate, account: account)
        modelContext.insert(newRecurring)
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Jenis Transaksi", selection: $transactionType) {
                    Text("Pengeluaran").tag(TransactionType.expense)
                    Text("Pemasukan").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)

                Section("Detail") {
                    TextField("Nama (e.g., Bayar Kost)", text: $name)
                    TextField("Jumlah", value: $amount, format: .currency(code: "IDR")).keyboardType(.decimalPad)
                    if transactionType == .expense {
                        Picker("Kategori", selection: $category) {
                            ForEach(categories) { cat in Text(cat.name).tag(cat.name) }
                        }
                    }
                    NavigationLink(destination: AccountPickerView(selectedAccountID: $selectedAccountID)) {
                        HStack {
                            Text(transactionType == .expense ? "Sumber Dana" : "Tujuan Dana")
                            Spacer()
                            Text(accounts.first { $0.id == selectedAccountID }?.name ?? "Pilih Akun")
                        }
                    }
                }

                Section("Jadwal") {
                    Picker("Frekuensi", selection: $cycle) {
                        ForEach(RecurrenceCycle.allCases, id: \.self) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                    DatePicker("Mulai Tanggal", selection: $startDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Transaksi Berulang Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        save()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let firstCategory = categories.first {
                    category = firstCategory.name
                }
            }
        }
    }
}
