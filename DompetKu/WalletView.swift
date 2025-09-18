import SwiftUI
import SwiftData
import Charts

struct WalletView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WalletAccount.name) var accounts: [WalletAccount]
    @State private var isShowingAddAccountView = false
    @State private var accountToEdit: WalletAccount?

    @ViewBuilder
    private func accountIcon(for account: WalletAccount) -> some View {
        if let imageData = account.iconImageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            Image(systemName: account.iconName)
                .font(.title2)
                .foregroundStyle(account.color)
                .frame(width: 40)
        }
    }
    
    private func deleteAccount(at offsets: IndexSet) {
        for offset in offsets {
            let account = accounts[offset]
            modelContext.delete(account)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if accounts.isEmpty {
                    ContentUnavailableView("Belum Ada Akun", systemImage: "wallet.pass", description: Text("Tekan tombol + untuk menambahkan akun pertamamu (misal: Cash, ATM)."))
                } else {
                    VStack {
                        Chart(accounts) { account in
                            SectorMark(angle: .value("Saldo", account.balance), innerRadius: .ratio(0.6))
                                .foregroundStyle(account.color)
                        }
                        .frame(height: 200)
                        .padding(.bottom)
                        
                        let totalBalance = accounts.reduce(0) { $0 + $1.balance }
                        Text("Total Saldo").font(.caption).foregroundStyle(.secondary)
                        Text(totalBalance, format: .currency(code: "IDR")).font(.largeTitle.bold())
                    }
                    .padding()
                    
                    List {
                        Section("Daftar Akun") {
                            ForEach(accounts) { account in
                                NavigationLink(destination: AccountHistoryView(account: account)) {
                                    HStack {
                                        accountIcon(for: account)
                                        
                                        VStack(alignment: .leading) {
                                            Text(account.name).font(.headline)
                                            Text("Saldo: \(account.balance, format: .currency(code: "IDR"))").font(.caption)
                                        }
                                        Spacer()
                                        Button {
                                            accountToEdit = account
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundStyle(.green)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .onDelete(perform: deleteAccount) // <-- Tambahkan modifier ini
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Wallet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isShowingAddAccountView.toggle() } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $isShowingAddAccountView) {
                AddAccountView()
            }
            .sheet(item: $accountToEdit) { account in
                AddBalanceView(account: account)
            }
        }
    }
}
