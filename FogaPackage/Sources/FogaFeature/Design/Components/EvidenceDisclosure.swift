import SwiftUI

/// Component for displaying scientific evidence disclosure and transparency information
/// 
/// **Critical Purpose**: Provides honest, evidence-based information about facial exercises,
/// their limitations, and scientific citations. Never promises fat loss or makes unsubstantiated claims.
@available(iOS 15.0, *)
public struct EvidenceDisclosure: View {
    @StateObject private var viewModel = ScientificDisclosureViewModel()
    @State private var showCitations = false
    @State private var showFullDisclaimer = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Scientific Evidence")
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            // Evidence Level
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Evidence Level:")
                        .font(AppTypography.body)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.facialExerciseEvidenceLevel.displayName)
                        .font(AppTypography.body.bold())
                        .foregroundColor(evidenceLevelColor)
                }
                
                Text(viewModel.facialExerciseEvidenceLevel.description)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
            
            // Key Limitations
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Limitations:")
                    .font(AppTypography.body.bold())
                    .foregroundColor(.primary)
                
                ForEach(Array(viewModel.limitations.prefix(3).enumerated()), id: \.offset) { index, limitation in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(limitation)
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Citations Button
            Button(action: {
                showCitations.toggle()
            }) {
                HStack {
                    Image(systemName: "book.fill")
                        .font(.caption)
                    Text("View Scientific Citations")
                        .font(AppTypography.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(AppColors.primary)
            }
            
            // Full Disclaimer Button
            Button(action: {
                showFullDisclaimer.toggle()
            }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                    Text("Read Full Disclaimer")
                        .font(AppTypography.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(AppColors.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showCitations) {
            CitationsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showFullDisclaimer) {
            FullDisclaimerView(viewModel: viewModel)
        }
    }
    
    private var evidenceLevelColor: Color {
        switch viewModel.facialExerciseEvidenceLevel {
        case .strong:
            return .green
        case .moderate:
            return .orange
        case .limited, .insufficient:
            return .red
        }
    }
}

/// Detailed citations view
struct CitationsView: View {
    @ObservedObject var viewModel: ScientificDisclosureViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.citations) { citation in
                        CitationCard(citation: citation, viewModel: viewModel)
                    }
                }
                .padding()
            }
            .navigationTitle("Scientific Citations")
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

/// Individual citation card
struct CitationCard: View {
    let citation: ScientificDisclosureViewModel.ScientificCitation
    @ObservedObject var viewModel: ScientificDisclosureViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Evidence Level Badge
            HStack {
                Text(citation.evidenceLevel.displayName)
                    .font(AppTypography.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(evidenceLevelColor)
                    .cornerRadius(8)
                
                Spacer()
            }
            
            // Title
            Text(citation.title)
                .font(AppTypography.headline)
                .foregroundColor(.primary)
            
            // Authors and Journal
            VStack(alignment: .leading, spacing: 4) {
                Text(citation.authors)
                    .font(AppTypography.body)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(citation.journal)
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(citation.year)")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Key Finding
            Text("Key Finding:")
                .font(AppTypography.caption.bold())
                .foregroundColor(.primary)
            
            Text(citation.keyFinding)
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
            
            // DOI and Link
            if let doi = citation.doi {
                HStack {
                    Text("DOI:")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    Text(doi)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            // Open Link Button
            if citation.url != nil {
                Button(action: {
                    viewModel.openCitation(citation)
                }) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text("Open Research Paper")
                            .font(AppTypography.body)
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var evidenceLevelColor: Color {
        switch citation.evidenceLevel {
        case .strong:
            return .green
        case .moderate:
            return .orange
        case .limited, .insufficient:
            return .red
        }
    }
}

/// Full disclaimer view
struct FullDisclaimerView: View {
    @ObservedObject var viewModel: ScientificDisclosureViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Evidence Level
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Evidence Level")
                            .font(AppTypography.headline)
                            .foregroundColor(.primary)
                        
                        Text(viewModel.facialExerciseEvidenceLevel.displayName)
                            .font(AppTypography.title3)
                            .foregroundColor(evidenceLevelColor)
                        
                        Text(viewModel.explanation(for: viewModel.facialExerciseEvidenceLevel))
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Limitations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Limitations")
                            .font(AppTypography.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(Array(viewModel.limitations.enumerated()), id: \.offset) { index, limitation in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text(limitation)
                                    .font(AppTypography.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // General Disclaimer
                    VStack(alignment: .leading, spacing: 8) {
                        Text("General Disclaimer")
                            .font(AppTypography.headline)
                            .foregroundColor(.primary)
                        
                        Text(viewModel.generateEvidenceDisclaimer())
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Full Disclaimer")
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
    
    private var evidenceLevelColor: Color {
        switch viewModel.facialExerciseEvidenceLevel {
        case .strong:
            return .green
        case .moderate:
            return .orange
        case .limited, .insufficient:
            return .red
        }
    }
}

/// Preview
struct EvidenceDisclosure_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EvidenceDisclosure()
                .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

