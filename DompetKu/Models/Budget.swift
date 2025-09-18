import Foundation
import SwiftData

@Model
class Budget {
    @Attribute(.unique) var id: String
    var amount: Double
    var category: String
    var month: Int
    var year: Int

    init(amount: Double, category: String, date: Date = .now) {
        self.id = UUID().uuidString
        self.amount = amount
        self.category = category

        let calendar = Calendar.current
        self.month = calendar.component(.month, from: date)
        self.year = calendar.component(.year, from: date)
    }
}
