import Foundation
import SwiftData

@Model
class AccountLog {
    @Attribute(.unique) var id: String
    var amountAdded: Double
    var date: Date

    var account: WalletAccount?

    init(amountAdded: Double, date: Date, account: WalletAccount?) {
        self.id = UUID().uuidString
        self.amountAdded = amountAdded
        self.date = date
        self.account = account
    }
}
