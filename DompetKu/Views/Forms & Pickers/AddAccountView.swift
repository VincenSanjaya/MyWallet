import SwiftUI
import SwiftData
import PhotosUI

struct AddAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var balance: Double = 0
    @State private var selectedColor: Color = .blue
    @State private var selectedIcon: String = "dollarsign.circle.fill"
    
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?

    private func saveAccount() {
        let newAccount = WalletAccount(name: name, balance: balance, color: selectedColor, iconName: selectedIcon, iconImageData: photoData)
        modelContext.insert(newAccount)
        
        if balance > 0 {
            let initialLog = AccountLog(amountAdded: balance, date: .now, account: newAccount)
            modelContext.insert(initialLog)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tampilan Akun") {
                    HStack {
                        if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable().scaledToFit().frame(width: 50, height: 50).clipShape(Circle())
                        } else {
                            Image(systemName: selectedIcon)
                                .font(.largeTitle).frame(width: 50, height: 50).foregroundStyle(selectedColor)
                        }
                        
                        TextField("Nama Akun (e.g., Cash, ATM BCA)", text: $name)
                    }
                    
                    ColorPicker("Pilih Warna", selection: $selectedColor, supportsOpacity: false)
                }
                
                Section("Ikon") {
                    NavigationLink(destination: IconPickerView(selectedIcon: $selectedIcon)) {
                        Text("Pilih dari Daftar Ikon")
                    }
                    
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Text("Pilih dari Galeri Foto")
                    }
                }
                
                Section("Saldo Awal") {
                    TextField("Saldo Awal", value: $balance, format: .currency(code: "IDR"))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Akun Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        saveAccount()
                        dismiss()
                    }
                }
            }
            .onChange(of: photoItem) {
                Task {
                    if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                        self.photoData = data
                    }
                }
            }
        }
    }
}
