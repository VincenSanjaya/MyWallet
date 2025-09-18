import SwiftUI
import SwiftData

struct RecurringView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecurringTransaction.nextOccurrenceDate) var recurringTransactions: [RecurringTransaction]
    @State private var isShowingAddSheet = false

    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            let item = recurringTransactions[offset]
            modelContext.delete(item)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(recurringTransactions) { item in
                    VStack(alignment: .leading) {
                        Text(item.name).font(.headline)
                        HStack {
                            Text(item.amount, format: .currency(code: "IDR"))
                                .foregroundStyle(item.transactionType == .income ? .green : .red)
                            Text("• \(item.cycle.rawValue)")
                        }
                        .font(.subheadline)
                        Text("Berikutnya: \(item.nextOccurrenceDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Transaksi Berulang")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isShowingAddSheet.toggle() } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddRecurringView()
            }
        }
    }
}
