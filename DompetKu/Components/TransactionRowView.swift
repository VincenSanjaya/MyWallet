import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    private var categoryIcon: String {
        switch transaction.category {
            case "Makanan": return "fork.knife"
            case "Transportasi": return "car.fill"
            case "Hiburan": return "gamecontroller.fill"
            case "Belanja": return "bag.fill"
            case "Kesehatan": return "heart.fill"
            case "Pendidikan": return "book.fill"
            default: return "tag.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.brandPrimary)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                
                HStack(spacing: 6) {
                    Image(systemName: categoryIcon)
                    if let categoryName = transaction.category {
                        Text(categoryName)
                    }
                    if let accountName = transaction.account?.name {
                        Text("•")
                        Text(accountName)
                    }
                }
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            Text(transaction.amount, format: .currency(code: "IDR"))
                .font(.headline)
                .foregroundStyle(transaction.transactionType == .income ? Color.accentIncome : Color.accentExpense)
        }
        .padding(.vertical, 8)
    }
}
