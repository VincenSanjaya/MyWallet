import SwiftUI

struct BudgetRowView: View {
    let budget: Budget
    let currentSpending: Double

    private var progress: Double {
        return min(currentSpending / budget.amount, 1.0)
    }

    private var progressColor: Color {
        if progress > 0.9 {
            return Color.accentExpense
        } else if progress > 0.7 {
            return .orange
        }
        return Color.brandPrimary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.category)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(progress, format: .percent)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.textSecondary)
            }

            ProgressView(value: progress)
                .tint(progressColor)

            HStack {
                Text(currentSpending, format: .currency(code: "IDR"))
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(budget.amount, format: .currency(code: "IDR"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}
