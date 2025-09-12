import Foundation
import SwiftData

@Model
class Transaction {
    @Attribute(.unique) var id: String
    var name: String
    var category: String
    var amount: Double
    var date: Date
    
    var account: WalletAccount?
    
    init(name: String, category: String, amount: Double, date: Date, account: WalletAccount?) {
        self.id = UUID().uuidString
        self.name = name
        self.category = category
        self.amount = amount
        self.date = date
        self.account = account
    }
}
