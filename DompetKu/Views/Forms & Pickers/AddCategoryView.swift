import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nama Kategori Baru", text: $name)
            }
            .navigationTitle("Kategori Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        let newCategory = Category(name: name)
                        modelContext.insert(newCategory)
                        dismiss()
                    }
                }
            }
        }
    }
}
