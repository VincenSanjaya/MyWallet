//
//  Category.swift
//  DompetKu
//
//  Created by Vincen Sanjaya on 18/09/25.
//


import Foundation
import SwiftData

@Model
class Category {
    @Attribute(.unique) var id: String
    var name: String

    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
    }
}