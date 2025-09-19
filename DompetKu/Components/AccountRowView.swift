import SwiftUI

struct AccountRowView: View {
    let account: WalletAccount
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 5)
                .fill(account.color)
                .frame(width: 5)

            accountIcon(for: account)

            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                Text(account.balance, format: .currency(code: "IDR"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
    
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
}
