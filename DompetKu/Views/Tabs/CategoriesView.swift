import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) var categories: [Category]
    @State private var isShowingAddCategory = false
    
    private func deleteCategory(at offsets: IndexSet) {
        for offset in offsets {
            let category = categories[offset]
            modelContext.delete(category)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Text(category.name)
                }
                .onDelete(perform: deleteCategory)
            }
            .navigationTitle("Kategori")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isShowingAddCategory.toggle() } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $isShowingAddCategory) {
                AddCategoryView()
            }
        }
    }
}
