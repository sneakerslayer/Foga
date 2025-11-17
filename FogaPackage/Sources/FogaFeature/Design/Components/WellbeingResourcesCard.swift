import SwiftUI

/// Card component for displaying mental health and wellbeing resources
/// 
/// **Critical Purpose**: Shows mental health resources when concerning behavior patterns
/// are detected. Provides helpline numbers, support resources, and encourages users to
/// seek professional help when needed.
@available(iOS 15.0, *)
public struct WellbeingResourcesCard: View {
    @State private var showFullResources = false
    
    let riskLevel: RiskLevel
    let riskAssessment: RiskAssessment?
    
    public init(
        riskLevel: RiskLevel,
        riskAssessment: RiskAssessment? = nil
    ) {
        self.riskLevel = riskLevel
        self.riskAssessment = riskAssessment
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: riskLevelIcon)
                    .foregroundColor(riskLevelColor)
                    .font(.title2)
                
                Text("Wellbeing Support")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            // Risk Level Badge
            HStack {
                Text(riskLevel.displayName)
                    .font(AppTypography.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(riskLevelColor)
                    .cornerRadius(8)
                
                Spacer()
            }
            
            // Action Message
            Text(MentalHealthResources.getActionMessage(for: riskLevel))
                .font(AppTypography.body)
                .foregroundColor(.secondary)
            
            // Key Resources (Top 3)
            VStack(alignment: .leading, spacing: 12) {
                Text("Support Resources:")
                    .font(AppTypography.body.bold())
                    .foregroundColor(.primary)
                
                ForEach(Array(resources.prefix(3).enumerated()), id: \.offset) { index, resource in
                    ResourceRow(resource: resource)
                }
            }
            
            // Show More Button
            if resources.count > 3 {
                Button(action: {
                    showFullResources.toggle()
                }) {
                    HStack {
                        Text("View All Resources")
                            .font(AppTypography.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            
            // Recommendations (if available)
            if let assessment = riskAssessment, !assessment.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations:")
                        .font(AppTypography.body.bold())
                        .foregroundColor(.primary)
                    
                    ForEach(Array(assessment.recommendations.enumerated()), id: \.offset) { index, recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(recommendation)
                                .font(AppTypography.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(riskLevelBackgroundColor.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(riskLevelColor.opacity(0.3), lineWidth: 1)
        )
        .sheet(isPresented: $showFullResources) {
            FullResourcesView(riskLevel: riskLevel)
        }
    }
    
    // MARK: - Computed Properties
    
    private var resources: [MentalHealthResources.Resource] {
        return MentalHealthResources.getResourcesForRiskLevel(riskLevel)
    }
    
    private var riskLevelIcon: String {
        switch riskLevel {
        case .low:
            return "checkmark.circle.fill"
        case .medium:
            return "exclamationmark.triangle.fill"
        case .high:
            return "exclamationmark.octagon.fill"
        }
    }
    
    private var riskLevelColor: Color {
        switch riskLevel {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    private var riskLevelBackgroundColor: Color {
        return riskLevelColor
    }
}

// MARK: - Resource Row

struct ResourceRow: View {
    let resource: MentalHealthResources.Resource
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: resourceIcon)
                .foregroundColor(AppColors.primary)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(resource.title)
                    .font(AppTypography.body.bold())
                    .foregroundColor(.primary)
                
                // Description
                Text(resource.description)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Phone Number (if available)
                if let phoneNumber = resource.phoneNumber {
                    Button(action: {
                        callPhoneNumber(phoneNumber)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.caption)
                            Text(MentalHealthResources.formatPhoneNumber(phoneNumber))
                                .font(AppTypography.caption.bold())
                        }
                        .foregroundColor(AppColors.primary)
                    }
                }
                
                // Website Link (if available)
                if let urlString = resource.websiteURL, let url = URL(string: urlString) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                            Text("Visit Website")
                                .font(AppTypography.caption)
                        }
                        .foregroundColor(AppColors.primary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var resourceIcon: String {
        switch resource.resourceType {
        case .helpline:
            return resource.isCrisisLine ? "phone.fill" : "phone"
        case .website:
            return "globe"
        case .supportGroup:
            return "person.3.fill"
        case .professionalReferral:
            return "stethoscope"
        case .educational:
            return "book.fill"
        }
    }
    
    private func callPhoneNumber(_ phoneNumber: String) {
        // Remove non-numeric characters
        let cleanedNumber = phoneNumber.filter { $0.isNumber || $0 == "+" }
        if let url = URL(string: "tel://\(cleanedNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Full Resources View

struct FullResourcesView: View {
    @Environment(\.dismiss) private var dismiss
    
    let riskLevel: RiskLevel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Disclaimer
                    Text(MentalHealthResources.getDisclaimerMessage())
                        .font(AppTypography.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    
                    // All Resources
                    ForEach(MentalHealthResources.getResourcesForRiskLevel(riskLevel)) { resource in
                        ResourceRow(resource: resource)
                    }
                }
                .padding()
            }
            .navigationTitle("Support Resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct WellbeingResourcesCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Low Risk
            WellbeingResourcesCard(
                riskLevel: .low,
                riskAssessment: RiskAssessment(
                    riskLevel: .low,
                    riskScore: 0.3,
                    concerns: [],
                    assessmentDate: Date(),
                    recommendations: ["Your usage patterns look healthy."]
                )
            )
            
            // Medium Risk
            WellbeingResourcesCard(
                riskLevel: .medium,
                riskAssessment: RiskAssessment(
                    riskLevel: .medium,
                    riskScore: 1.2,
                    concerns: [
                        RiskConcern.excessiveDailyMeasurements(count: 6, threshold: 5)
                    ],
                    assessmentDate: Date(),
                    recommendations: [
                        "We've noticed some patterns that may indicate you're focusing too much on measurements.",
                        "Consider taking breaks between measurements."
                    ]
                )
            )
            
            // High Risk
            WellbeingResourcesCard(
                riskLevel: .high,
                riskAssessment: RiskAssessment(
                    riskLevel: .high,
                    riskScore: 2.1,
                    concerns: [
                        RiskConcern.excessiveDailyMeasurements(count: 10, threshold: 5),
                        RiskConcern.frequentNegativeSatisfaction(percentage: 0.8)
                    ],
                    assessmentDate: Date(),
                    recommendations: [
                        "We're concerned about your usage patterns. Please take a break from measurements.",
                        "Consider speaking with a mental health professional or healthcare provider."
                    ]
                )
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

