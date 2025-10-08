import SwiftUI
import Charts

/// Dashboard view for displaying conversation analytics
struct ConversationAnalyticsDashboard: View {
    @StateObject private var analytics = ConversationAnalytics()
    @State private var selectedPeriod: AnalyticsPeriod = .week
    @State private var showingExportOptions = false
    @State private var exportFormat: ExportFormat = .summary
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    periodSelector
                    
                    // Key Metrics Cards
                    keyMetricsSection
                    
                    // Charts Section
                    chartsSection
                    
                    // Phase Analytics
                    phaseAnalyticsSection
                    
                    // User Insights
                    userInsightsSection
                    
                    // Export Button
                    exportSection
                }
                .padding()
            }
            .navigationTitle("Conversation Analytics")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsView(
                    analytics: analytics,
                    period: selectedPeriod,
                    format: $exportFormat
                )
            }
        }
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        let periods: [AnalyticsPeriod] = [.today, .week, .month, .quarter, .year]
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(periods, id: \.self) { period in
                    periodButton(for: period)
                }
            }
        }
    }
    
    private func periodButton(for period: AnalyticsPeriod) -> some View {
        Button(action: { selectedPeriod = period }) {
            Text(period.description)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(backgroundColorForPeriod(period))
                .foregroundColor(foregroundColorForPeriod(period))
                .cornerRadius(20)
        }
    }
    
    private func backgroundColorForPeriod(_ period: AnalyticsPeriod) -> Color {
        selectedPeriod == period ? Color.blue : Color.gray.opacity(0.2)
    }
    
    private func foregroundColorForPeriod(_ period: AnalyticsPeriod) -> Color {
        selectedPeriod == period ? .white : .primary
    }
    
    // MARK: - Key Metrics Section
    
    private var keyMetricsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                MetricCard(
                    title: "Success Rate",
                    value: String(format: "%.1f%%", analytics.completionRate),
                    trend: .up,
                    trendValue: "+2.3%",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                MetricCard(
                    title: "Active Sessions",
                    value: "\(analytics.currentMetrics.activeSessions)",
                    icon: "person.2.fill",
                    color: .blue
                )
            }
            
            HStack(spacing: 16) {
                MetricCard(
                    title: "Avg. Duration",
                    value: formatDuration(analytics.averageSessionDuration),
                    trend: .down,
                    trendValue: "-45s",
                    icon: "clock.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Total Messages",
                    value: "\(analytics.currentMetrics.totalMessages)",
                    icon: "bubble.left.and.bubble.right.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Charts Section
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Conversation Trends")
                .font(.headline)
            
            // Success Rate Chart
            ConversationTrendChart(
                data: getChartData(),
                period: selectedPeriod
            )
            .frame(height: 200)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            // Phase Completion Chart
            PhaseCompletionChart(
                analytics: analytics
            )
            .frame(height: 250)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Phase Analytics Section
    
    private var phaseAnalyticsSection: some View {
        let phases = ConversationPhase.allCases
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Phase Performance")
                .font(.headline)
            
            ForEach(phases, id: \.self) { phase in
                PhaseAnalyticsRow(
                    phase: phase,
                    analytics: analytics.getPhaseAnalytics(phase)
                )
            }
        }
    }
    
    // MARK: - User Insights Section
    
    private var userInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("User Behavior Insights")
                .font(.headline)
            
            let insights = analytics.getUserInsights()
            
            InsightCard(
                title: "Preferred Mode",
                value: insights.preferredMode.displayName,
                icon: "star.fill"
            )
            
            InsightCard(
                title: "Clarification Rate",
                value: String(format: "%.1f%%", insights.clarificationRate),
                icon: "questionmark.circle.fill"
            )
            
            InsightCard(
                title: "Peak Usage Hours",
                value: formatPeakHours(insights.peakUsageHours),
                icon: "clock.fill"
            )
            
            InsightCard(
                title: "Common Topics",
                value: insights.commonTopics.prefix(3).joined(separator: ", "),
                icon: "tag.fill"
            )
        }
    }
    
    // MARK: - Export Section
    
    private var exportSection: some View {
        Button(action: { showingExportOptions = true }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export Analytics")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getChartData() -> [ChartDataPoint] {
        // Generate sample data based on period
        // In real implementation, this would come from analytics
        var data: [ChartDataPoint] = []
        
        switch selectedPeriod {
        case .today:
            data = getTodayData()
        case .week:
            data = getWeekData()
        case .month:
            data = getMonthData()
        case .quarter:
            data = getQuarterData()
        case .year:
            data = getYearData()
        case .custom:
            data = getCustomData()
        }
        
        return data
    }
    
    private func getTodayData() -> [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        for hour in 0..<24 {
            data.append(ChartDataPoint(
                label: "\(hour):00",
                value: Double.random(in: 60...95)
            ))
        }
        return data
    }
    
    private func getWeekData() -> [ChartDataPoint] {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days.map { day in
            ChartDataPoint(
                label: day,
                value: Double.random(in: 70...90)
            )
        }
    }
    
    private func getMonthData() -> [ChartDataPoint] {
        return (1...4).map { week in
            ChartDataPoint(
                label: "Week \(week)",
                value: Double.random(in: 75...85)
            )
        }
    }
    
    private func getQuarterData() -> [ChartDataPoint] {
        let months = ["Month 1", "Month 2", "Month 3"]
        return months.map { month in
            ChartDataPoint(
                label: month,
                value: Double.random(in: 75...85)
            )
        }
    }
    
    private func getYearData() -> [ChartDataPoint] {
        return (1...12).map { month in
            ChartDataPoint(
                label: "M\(month)",
                value: Double.random(in: 70...90)
            )
        }
    }
    
    private func getCustomData() -> [ChartDataPoint] {
        // For custom periods, return sample data
        // In real implementation, this would be based on the custom date range
        return (1...7).map { day in
            ChartDataPoint(
                label: "Day \(day)",
                value: Double.random(in: 70...90)
            )
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    private func formatPeakHours(_ hours: [Int]) -> String {
        guard !hours.isEmpty else { return "N/A" }
        
        let ranges = hours.map { hour in
            let nextHour = (hour + 1) % 24
            return "\(hour):00-\(nextHour):00"
        }
        
        return ranges.prefix(2).joined(separator: ", ")
    }
}

// MARK: - Metric Card View

struct MetricCard: View {
    let title: String
    let value: String
    var trend: Trend? = nil
    var trendValue: String? = nil
    let icon: String
    let color: Color
    
    enum Trend {
        case up, down
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                if let trend = trend, let trendValue = trendValue {
                    HStack(spacing: 4) {
                        Image(systemName: trend == .up ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text(trendValue)
                            .font(.caption)
                    }
                    .foregroundColor(trend == .up ? .green : .red)
                }
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Chart Views

struct ConversationTrendChart: View {
    let data: [ChartDataPoint]
    let period: AnalyticsPeriod
    
    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Time", point.label),
                y: .value("Success Rate", point.value)
            )
            .foregroundStyle(Color.blue)
            
            AreaMark(
                x: .value("Time", point.label),
                y: .value("Success Rate", point.value)
            )
            .foregroundStyle(Color.blue.opacity(0.2))
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}

struct PhaseCompletionChart: View {
    let analytics: ConversationAnalytics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Phase Completion Rates")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(ConversationPhase.allCases, id: \.self) { phase in
                HStack {
                    Text(phase.rawValue.capitalized)
                        .font(.caption)
                        .frame(width: 100, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 20)
                            
                            Rectangle()
                                .fill(phaseColor(for: phase))
                                .frame(
                                    width: geometry.size.width * (phaseCompletionRate(for: phase) / 100),
                                    height: 20
                                )
                        }
                        .cornerRadius(10)
                    }
                    .frame(height: 20)
                    
                    Text("\(Int(phaseCompletionRate(for: phase)))%")
                        .font(.caption)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
    }
    
    private func phaseCompletionRate(for phase: ConversationPhase) -> Double {
        // In real implementation, get from analytics
        return Double.random(in: 70...95)
    }
    
    private func phaseColor(for phase: ConversationPhase) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
        let index = ConversationPhase.allCases.firstIndex(of: phase) ?? 0
        return colors[index % colors.count]
    }
}

// MARK: - Phase Analytics Row

struct PhaseAnalyticsRow: View {
    let phase: ConversationPhase
    let analytics: PhaseAnalytics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(phase.rawValue.capitalized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(analytics.completionRate))% completion")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                Label(formatDuration(analytics.averageDuration), systemImage: "clock")
                    .font(.caption)
                
                Label("\(Int(analytics.averageMessages)) messages", systemImage: "bubble.left.and.bubble.right")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            if !analytics.commonIssues.isEmpty {
                Text(analytics.commonIssues.first ?? "")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes)m"
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Export Options View

struct ExportOptionsView: View {
    let analytics: ConversationAnalytics
    let period: AnalyticsPeriod
    @Binding var format: ExportFormat
    @Environment(\.dismiss) var dismiss
    @State private var isExporting = false
    @State private var exportCompleted = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Export Format")
                    .font(.headline)
                    .padding(.top)
                
                ForEach([ExportFormat.summary, .csv, .json], id: \.self) { exportFormat in
                    Button(action: { format = exportFormat }) {
                        HStack {
                            Image(systemName: formatIcon(for: exportFormat))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text(formatName(for: exportFormat))
                                    .fontWeight(.medium)
                                Text(formatDescription(for: exportFormat))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if format == exportFormat {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(format == exportFormat ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                Button(action: performExport) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isExporting ? "Exporting..." : "Export")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isExporting)
            }
            .padding()
            .navigationTitle("Export Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Export Complete", isPresented: $exportCompleted) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Analytics data has been exported successfully.")
            }
        }
    }
    
    private func formatIcon(for format: ExportFormat) -> String {
        switch format {
        case .summary: return "doc.text"
        case .csv: return "tablecells"
        case .json: return "curlybraces"
        }
    }
    
    private func formatName(for format: ExportFormat) -> String {
        switch format {
        case .summary: return "Summary Report"
        case .csv: return "CSV Spreadsheet"
        case .json: return "JSON Data"
        }
    }
    
    private func formatDescription(for format: ExportFormat) -> String {
        switch format {
        case .summary: return "Human-readable report with key insights"
        case .csv: return "Import into Excel or Google Sheets"
        case .json: return "Raw data for custom analysis"
        }
    }
    
    private func performExport() {
        isExporting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let data = analytics.exportData(format: format, period: period) {
                // In a real app, this would save to files or share
                print("Exported \(data.count) bytes")
            }
            
            isExporting = false
            exportCompleted = true
        }
    }
}

// MARK: - Supporting Types

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}