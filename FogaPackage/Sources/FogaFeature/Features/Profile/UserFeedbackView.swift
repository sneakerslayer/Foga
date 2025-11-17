import SwiftUI

/// View for collecting user feedback during UAT
@available(iOS 15.0, *)
public struct UserFeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var overallSatisfaction: Int = 3
    @State private var usabilityScore: Int = 3
    @State private var scientificHonestyScore: Int = 3
    @State private var trustScore: Int = 3
    @State private var likelihoodToRecommend: Int = 3
    
    @State private var transparencyUnderstanding: String = ""
    @State private var whatLikedMost: String = ""
    @State private var whatLikedLeast: String = ""
    @State private var whatConfused: String = ""
    @State private var improvements: String = ""
    @State private var additionalComments: String = ""
    
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    
    public init() {}
    
    public var body: some View {
        Form {
                // Rating Section
                Section("Overall Ratings") {
                    RatingRow(
                        title: "Overall Satisfaction",
                        rating: $overallSatisfaction,
                        description: "How satisfied are you with the app?"
                    )
                    
                    RatingRow(
                        title: "Usability",
                        rating: $usabilityScore,
                        description: "How easy is the app to use?"
                    )
                    
                    RatingRow(
                        title: "Scientific Honesty",
                        rating: $scientificHonestyScore,
                        description: "How much do you appreciate the app's honesty about limitations?"
                    )
                    
                    RatingRow(
                        title: "Trust",
                        rating: $trustScore,
                        description: "How much do you trust the app?"
                    )
                    
                    RatingRow(
                        title: "Likelihood to Recommend",
                        rating: $likelihoodToRecommend,
                        description: "How likely are you to recommend this app?"
                    )
                }
                
                // Transparency Understanding
                Section("Transparency & Understanding") {
                    TextEditor(text: $transparencyUnderstanding)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if transparencyUnderstanding.isEmpty {
                                    Text("What did you understand about the app's scientific limitations and transparency?")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                // Open Feedback
                Section("What did you like most?") {
                    TextEditor(text: $whatLikedMost)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if whatLikedMost.isEmpty {
                                    Text("Tell us what you liked most about the app...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section("What did you like least?") {
                    TextEditor(text: $whatLikedLeast)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if whatLikedLeast.isEmpty {
                                    Text("Tell us what you liked least about the app...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section("What confused you or was unclear?") {
                    TextEditor(text: $whatConfused)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if whatConfused.isEmpty {
                                    Text("Tell us what was confusing or unclear...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section("What would you improve?") {
                    TextEditor(text: $improvements)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if improvements.isEmpty {
                                    Text("Tell us what you would improve...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section("Additional Comments") {
                    TextEditor(text: $additionalComments)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if additionalComments.isEmpty {
                                    Text("Any additional comments or suggestions?")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: submitFeedback) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
            .alert("Thank You!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your feedback has been submitted. Thank you for helping us improve the app!")
            }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        // Create feedback object
        let feedback = UserFeedback(
            timestamp: Date(),
            overallSatisfaction: overallSatisfaction,
            usabilityScore: usabilityScore,
            scientificHonestyScore: scientificHonestyScore,
            trustScore: trustScore,
            likelihoodToRecommend: likelihoodToRecommend,
            transparencyUnderstanding: transparencyUnderstanding,
            whatLikedMost: whatLikedMost,
            whatLikedLeast: whatLikedLeast,
            whatConfused: whatConfused,
            improvements: improvements,
            additionalComments: additionalComments
        )
        
        // In production, this would send to backend
        // For now, save locally or print for testing
        print("Feedback submitted: \(feedback)")
        
        // Simulate network delay using Swift Concurrency
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            isSubmitting = false
            showSuccessAlert = true
        }
    }
}

/// Rating row component
@available(iOS 15.0, *)
private struct RatingRow: View {
    let title: String
    @Binding var rating: Int
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { value in
                    Button(action: {
                        rating = value
                    }) {
                        Image(systemName: value <= rating ? "star.fill" : "star")
                            .foregroundColor(value <= rating ? .yellow : .gray)
                            .font(.title3)
                    }
                }
                
                Spacer()
                
                Text("\(rating)/5")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// User feedback data model
public struct UserFeedback: Codable {
    let timestamp: Date
    let overallSatisfaction: Int
    let usabilityScore: Int
    let scientificHonestyScore: Int
    let trustScore: Int
    let likelihoodToRecommend: Int
    let transparencyUnderstanding: String
    let whatLikedMost: String
    let whatLikedLeast: String
    let whatConfused: String
    let improvements: String
    let additionalComments: String
    
    var averageScore: Double {
        let sum = Double(overallSatisfaction + usabilityScore + scientificHonestyScore + trustScore + likelihoodToRecommend)
        return sum / 5.0
    }
}

