import Foundation
import SwiftData
import SwiftUI

@Model
class WalletAccount {
    @Attribute(.unique) var id: String
    var name: String
    var balance: Double
    var colorData: Data
    var iconName: String
    var iconImageData: Data?
    
    @Relationship(deleteRule: .cascade, inverse: \AccountLog.account)
    var logs: [AccountLog] = []

    @Transient var color: Color {
        get {
            if let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
                return Color(uiColor)
            }
            return .black
        }
        set {
            if let colorData = UIColor(newValue).encode() {
                self.colorData = colorData
            }
        }
    }
    
    init(name: String, balance: Double, color: Color, iconName: String, iconImageData: Data? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.balance = balance
        self.colorData = Data()
        self.iconName = iconName
        self.iconImageData = iconImageData
        self.color = color 
    }
}

extension UIColor {
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
