import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    @Query var transactions: [Transaction]
    @State private var selectedChartType: ChartType = .bar
    
    enum ChartType: String, CaseIterable {
        case bar = "Per Kategori"
        case pie = "Proporsi"
        case line = "Tren Mingguan"
    }
    
    struct SpendingDataPoint: Identifiable {
        let id = UUID()
        let name: String
        let totalAmount: Double
    }
    
    struct DailySpendingPoint: Identifiable {
        let id = UUID()
        let date: Date
        let totalAmount: Double
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                let monthlyTransactions = transactions.filter { transaction in
                    Calendar.current.isDate(transaction.date, equalTo: .now, toGranularity: .month)
                }
                
                let expenseTransactions = monthlyTransactions.filter { $0.transactionType == .expense }

                if expenseTransactions.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "Data Tidak Cukup",
                        systemImage: "chart.bar.xaxis",
                        description: Text("Belum ada pengeluaran bulan ini untuk membuat laporan.")
                    )
                    Spacer()
                } else {
                    VStack {
                        Picker("Pilih Grafik", selection: $selectedChartType) {
                            ForEach(ChartType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom)

                        VStack(alignment: .leading) {
                            let totalSpending = expenseTransactions.reduce(0) { $0 + $1.amount }
                            Text("TOTAL PENGELUARAN BULAN INI")
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                            Text(totalSpending, format: .currency(code: "IDR"))
                                .font(.title.bold())
                                .foregroundStyle(Color.textPrimary)
                            
                            if selectedChartType == .bar {
                                barChartView(from: expenseTransactions)
                            } else if selectedChartType == .pie {
                                pieChartView(from: expenseTransactions)
                            } else {
                                lineChartView(from: expenseTransactions)
                            }
                        }
                        .frame(maxHeight: 400)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding()
                    
                    Spacer()
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Laporan")
        }
    }
    
    private func spendingByCategory(from transactions: [Transaction]) -> [SpendingDataPoint] {
        let uncategorizedLabel = "Tanpa Kategori"

        return Dictionary(grouping: transactions, by: { transaction in
            if let category = transaction.category, !category.isEmpty {
                return category
            }
            return uncategorizedLabel
        })
        .mapValues { $0.reduce(0) { $0 + $1.amount } }
        .map { SpendingDataPoint(name: $0.key, totalAmount: $0.value) }
        .sorted(by: { $0.totalAmount > $1.totalAmount })
    }

    @ViewBuilder
    private func barChartView(from transactions: [Transaction]) -> some View {
        let categoryData = spendingByCategory(from: transactions)

        Chart(categoryData) { data in
            BarMark(
                x: .value("Pengeluaran", data.totalAmount),
                y: .value("Kategori", data.name)
            )
            .foregroundStyle(by: .value("Kategori", data.name))
        }
        .chartLegend(.hidden)
    }

    @ViewBuilder
    private func pieChartView(from transactions: [Transaction]) -> some View {
        let categoryData = spendingByCategory(from: transactions)

        Chart(categoryData) { data in
            SectorMark(
                angle: .value("Pengeluaran", data.totalAmount),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .foregroundStyle(by: .value("Kategori", data.name))
            .cornerRadius(5)
        }
        .chartLegend(position: .bottom, alignment: .center)
    }

    @ViewBuilder
    private func lineChartView(from transactions: [Transaction]) -> some View {
        let spendingByDay = Dictionary(grouping: transactions, by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .map { DailySpendingPoint(date: $0.key, totalAmount: $0.value) }
            .sorted(by: { $0.date < $1.date })

        Chart(spendingByDay) { data in
            LineMark(
                x: .value("Tanggal", data.date, unit: .day),
                y: .value("Total", data.totalAmount)
            )
            .interpolationMethod(.cardinal)
            .symbol(Circle().strokeBorder(lineWidth: 2))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day())
            }
        }
    }
}
