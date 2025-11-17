import Foundation

/// Exercise model representing a face yoga exercise
/// 
/// **Learning Note**: This model stores exercise information.
/// The `videoURL` can be a local file path or remote URL.
public struct Exercise: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String
    public var duration: TimeInterval // in seconds
    public var videoURL: String? // Local file path or remote URL
    public var isPremium: Bool
    public var category: ExerciseCategory
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        duration: TimeInterval,
        videoURL: String? = nil,
        isPremium: Bool = false,
        category: ExerciseCategory = .jawline
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.videoURL = videoURL
        self.isPremium = isPremium
        self.category = category
    }
}

/// Exercise categories
public enum ExerciseCategory: String, Codable, CaseIterable {
    case jawline = "Jawline"
    case neck = "Neck"
    case cheeks = "Cheeks"
    case overall = "Overall"
}

