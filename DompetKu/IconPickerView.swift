import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) var dismiss

    let iconOptions = [
        "dollarsign.circle.fill", "creditcard.fill", "banknote.fill", "briefcase.fill",
        "cart.fill", "bag.fill", "gift.fill", "house.fill",
        "car.fill", "airplane", "bus.fill", "tram.fill",
        "fuelpump.fill", "gamecontroller.fill", "pc", "headphones",
        "graduationcap.fill", "book.fill", "heart.fill", "cross.case.fill"
    ]

    let columns = [GridItem(.adaptive(minimum: 60))]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(iconOptions, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.largeTitle)
                            .foregroundStyle(selectedIcon == icon ? .white : .primary)
                            .frame(width: 70, height: 70)
                            .background(selectedIcon == icon ? .blue : Color(.systemGray5))
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedIcon = icon
                                dismiss()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Pilih Ikon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
