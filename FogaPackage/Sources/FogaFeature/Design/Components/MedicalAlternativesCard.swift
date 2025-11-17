import SwiftUI

/// Card component for displaying medical alternatives information
/// 
/// **Critical Purpose**: Provides information about evidence-based medical treatments
/// for submental fat reduction. Positions as informational only and recommends healthcare provider consultation.
@available(iOS 15.0, *)
public struct MedicalAlternativesCard: View {
    @StateObject private var medicalAlternatives = MedicalAlternatives()
    @State private var showFullInformation = false
    @State private var showConsultationRecommendation = false
    
    let userAngle: Double?
    
    public init(userAngle: Double? = nil) {
        self.userAngle = userAngle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "cross.case.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                
                Text("Medical Alternatives")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            // Brief Information
            VStack(alignment: .leading, spacing: 8) {
                Text("Evidence-Based Treatments")
                    .font(AppTypography.body.bold())
                    .foregroundColor(.primary)
                
                Text("If you're interested in evidence-based medical treatments for submental fat reduction, there are several FDA-approved options available.")
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                
                // Treatment Types Preview
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(medicalAlternatives.fdaApprovedTreatments().prefix(2), id: \.id) { treatment in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(treatment.type.displayName)
                                .font(AppTypography.caption)
                                .foregroundColor(.secondary)
                            
                            if let brandName = treatment.type.commonBrandName {
                                Text("(\(brandName))")
                                    .font(AppTypography.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            // Consultation Recommendation Button
            if userAngle != nil {
                Button(action: {
                    showConsultationRecommendation.toggle()
                }) {
                    HStack {
                        Image(systemName: "stethoscope")
                            .font(.caption)
                        Text("Get Consultation Recommendation")
                            .font(AppTypography.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(AppColors.secondary)
                }
            }
            
            // Learn More Button
            Button(action: {
                showFullInformation.toggle()
            }) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                    Text("Learn More About Treatments")
                        .font(AppTypography.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(AppColors.primary)
            }
            
            // Disclaimer
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text("This information is for educational purposes only and is not medical advice. Always consult with a qualified healthcare provider before pursuing any treatment.")
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showFullInformation) {
            MedicalAlternativesFullView(medicalAlternatives: medicalAlternatives)
        }
        .sheet(isPresented: $showConsultationRecommendation) {
            ConsultationRecommendationView(
                medicalAlternatives: medicalAlternatives,
                userAngle: userAngle
            )
        }
    }
}

/// Full medical alternatives information view
struct MedicalAlternativesFullView: View {
    @ObservedObject var medicalAlternatives: MedicalAlternatives
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTreatment: MedicalAlternatives.TreatmentInfo?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Introduction
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Medical Alternatives for Submental Fat Reduction")
                            .font(AppTypography.title2)
                            .foregroundColor(.primary)
                        
                        Text(medicalAlternatives.generateGeneralInformation())
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Treatment Categories
                    VStack(alignment: .leading, spacing: 16) {
                        // FDA-Approved Non-Invasive
                        TreatmentCategorySection(
                            title: "FDA-Approved Non-Invasive Treatments",
                            treatments: medicalAlternatives.nonInvasiveTreatments(),
                            selectedTreatment: $selectedTreatment
                        )
                        
                        // Surgical Options
                        TreatmentCategorySection(
                            title: "Surgical Options",
                            treatments: medicalAlternatives.surgicalTreatments(),
                            selectedTreatment: $selectedTreatment
                        )
                    }
                    
                    Divider()
                    
                    // Disclaimer
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Important Disclaimer")
                            .font(AppTypography.headline)
                            .foregroundColor(.primary)
                        
                        Text(medicalAlternatives.generateDisclaimer())
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Medical Alternatives")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedTreatment) { treatment in
                TreatmentDetailView(treatment: treatment)
            }
        }
    }
}

/// Treatment category section
struct TreatmentCategorySection: View {
    let title: String
    let treatments: [MedicalAlternatives.TreatmentInfo]
    @Binding var selectedTreatment: MedicalAlternatives.TreatmentInfo?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundColor(.primary)
            
            ForEach(treatments) { treatment in
                TreatmentCard(treatment: treatment) {
                    selectedTreatment = treatment
                }
            }
        }
    }
}

/// Treatment card
struct TreatmentCard: View {
    let treatment: MedicalAlternatives.TreatmentInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(treatment.type.displayName)
                        .font(AppTypography.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if treatment.fdaApproved {
                        Text("FDA Approved")
                            .font(AppTypography.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                
                if let brandName = treatment.type.commonBrandName {
                    Text(brandName)
                        .font(AppTypography.body)
                        .foregroundColor(.secondary)
                }
                
                Text(treatment.description)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("Evidence Level:")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    Text(treatment.evidenceLevel)
                        .font(AppTypography.caption.bold())
                        .foregroundColor(evidenceLevelColor(treatment.evidenceLevel))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func evidenceLevelColor(_ level: String) -> Color {
        if level.contains("Strong") {
            return .green
        } else if level.contains("Moderate") {
            return .orange
        } else {
            return .red
        }
    }
}

/// Treatment detail view
struct TreatmentDetailView: View {
    let treatment: MedicalAlternatives.TreatmentInfo
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(treatment.type.displayName)
                                .font(AppTypography.title2)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if treatment.fdaApproved {
                                Text("FDA Approved")
                                    .font(AppTypography.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                        }
                        
                        if let brandName = treatment.type.commonBrandName {
                            Text(brandName)
                                .font(AppTypography.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Description
                    DetailSection(title: "Description", content: treatment.description)
                    
                    // How It Works
                    DetailSection(title: "How It Works", content: treatment.howItWorks)
                    
                    // Effectiveness
                    DetailSection(title: "Effectiveness", content: treatment.effectiveness)
                    
                    // Side Effects
                    DetailSection(
                        title: "Side Effects",
                        content: treatment.sideEffects.joined(separator: "\n• ")
                    )
                    
                    // Recovery Time
                    DetailSection(title: "Recovery Time", content: treatment.recoveryTime)
                    
                    // Cost Range
                    DetailSection(title: "Cost Range", content: treatment.costRange)
                    
                    // Suitable For
                    DetailSection(
                        title: "Suitable For",
                        content: treatment.suitableFor.joined(separator: "\n• ")
                    )
                    
                    // Not Suitable For
                    DetailSection(
                        title: "Not Suitable For",
                        content: treatment.notSuitableFor.joined(separator: "\n• ")
                    )
                    
                    Divider()
                    
                    // Consultation Required
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "stethoscope.fill")
                                .foregroundColor(AppColors.secondary)
                            Text("Consultation Required")
                                .font(AppTypography.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Text("This treatment requires consultation with a qualified healthcare provider. Only a healthcare provider can determine if this treatment is right for you based on your individual health, skin condition, and expectations.")
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Treatment Details")
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

/// Detail section helper
struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(AppTypography.body)
                .foregroundColor(.secondary)
        }
    }
}

/// Consultation recommendation view
struct ConsultationRecommendationView: View {
    @ObservedObject var medicalAlternatives: MedicalAlternatives
    let userAngle: Double?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(medicalAlternatives.generateConsultationRecommendation(
                        userAngle: userAngle,
                        includeTreatments: true
                    ))
                    .font(AppTypography.body)
                    .foregroundColor(.secondary)
                    .padding()
                }
            }
            .navigationTitle("Consultation Recommendation")
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

/// Preview
struct MedicalAlternativesCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MedicalAlternativesCard(userAngle: 115.0)
                .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

