import SwiftUI
import SwiftData

struct AddBudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var amount: Double = 0
    @State private var selectedCategory: String = "Makanan"

    let categories = ["Makanan", "Transportasi", "Hiburan", "Belanja", "Lainnya"]

    private func saveBudget() {
        let newBudget = Budget(amount: amount, category: selectedCategory)
        modelContext.insert(newBudget)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detail Budget") {
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }

                    TextField("Jumlah Budget", value: $amount, format: .currency(code: "IDR"))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Budget Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        guard amount > 0 else { return }
                        saveBudget()
                        dismiss()
                    }
                }
            }
        }
    }
}
