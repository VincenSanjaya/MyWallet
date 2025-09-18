import Foundation
import SwiftData

enum TransactionType: String, Codable {
    case income = "Pemasukan"
    case expense = "Pengeluaran"
}

@Model
class Transaction {
    @Attribute(.unique) var id: String
    var name: String
    var category: String?
    var amount: Double
    var date: Date
    var transactionType: TransactionType
    var account: WalletAccount?
    
    init(name: String, category: String?, amount: Double, date: Date, transactionType: TransactionType, account: WalletAccount?) {
        self.id = UUID().uuidString
        self.name = name
        self.category = category
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.account = account
    }
}
