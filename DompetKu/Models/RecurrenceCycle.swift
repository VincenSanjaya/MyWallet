import Foundation
import SwiftData

enum RecurrenceCycle: String, Codable, CaseIterable {
    case daily = "Harian"
    case weekly = "Mingguan"
    case monthly = "Bulanan"
    case yearly = "Tahunan"
}

@Model
class RecurringTransaction {
    @Attribute(.unique) var id: String
    var name: String
    var category: String?
    var amount: Double
    var transactionType: TransactionType

    var cycle: RecurrenceCycle
    var startDate: Date
    var nextOccurrenceDate: Date

    @Relationship(deleteRule: .nullify)
    var account: WalletAccount?

    init(name: String, category: String?, amount: Double, transactionType: TransactionType, cycle: RecurrenceCycle, startDate: Date, account: WalletAccount?) {
        self.id = UUID().uuidString
        self.name = name
        self.category = category
        self.amount = amount
        self.transactionType = transactionType
        self.cycle = cycle
        self.startDate = startDate
        self.nextOccurrenceDate = startDate
        self.account = account
    }
}
