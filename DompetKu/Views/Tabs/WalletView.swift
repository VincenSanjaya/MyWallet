import SwiftUI
import SwiftData
import Charts

struct WalletView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WalletAccount.name) var accounts: [WalletAccount]
    @State private var isShowingAddAccountView = false
    @State private var accountToAddBalance: WalletAccount?

    private func deleteAccount(at offsets: IndexSet) {
        for offset in offsets {
            let account = accounts[offset]
            modelContext.delete(account)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if accounts.isEmpty {
                    Spacer()
                    ContentUnavailableView("Belum Ada Akun", systemImage: "wallet.pass", description: Text("Tekan tombol + untuk menambahkan akun pertamamu."))
                    Spacer()
                } else {
                    VStack {
                        let totalBalance = accounts.reduce(0) { $0 + $1.balance }
                        Text("TOTAL SALDO GABUNGAN")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        
                        Text(totalBalance, format: .currency(code: "IDR"))
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.textPrimary)
                        
                        Chart(accounts) { account in
                            SectorMark(angle: .value("Saldo", account.balance), innerRadius: .ratio(0.7))
                                .foregroundStyle(account.color)
                        }
                        .frame(height: 200)
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding()
                    
                    List {
                        ForEach(accounts) { account in
                            NavigationLink(destination: AccountHistoryView(account: account)) {
                                AccountRowView(account: account)
                            }
                            .listRowBackground(Color.appBackground)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(account)
                                } label: {
                                    Label("Hapus", systemImage: "trash.fill")
                                }
                                
                                Button {
                                    accountToAddBalance = account
                                } label: {
                                    Label("Tambah Saldo", systemImage: "plus.circle.fill")
                                }
                                .tint(.green)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Wallet")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        NavigationLink(destination: CategoriesView()) { Image(systemName: "tag.fill") }
                        NavigationLink(destination: RecurringView()) { Image(systemName: "arrow.2.circlepath") }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isShowingAddAccountView.toggle() } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $isShowingAddAccountView) { AddAccountView() }
            .sheet(item: $accountToAddBalance) { account in AddBalanceView(account: account) }
        }
    }
}
