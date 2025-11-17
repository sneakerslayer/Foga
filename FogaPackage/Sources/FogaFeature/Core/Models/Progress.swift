import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Progress model for tracking user's transformation
/// 
/// **Learning Note**: This stores progress photos and measurements.
/// `photoData` is stored as Data (binary) because Core Data/UserDefaults work with Data.
public struct Progress: Identifiable, Codable {
    public let id: UUID
    public var photoData: Data? // UIImage converted to Data
    public var measurements: FaceMeasurement
    public var date: Date
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        photoData: Data? = nil,
        measurements: FaceMeasurement,
        date: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.photoData = photoData
        self.measurements = measurements
        self.date = date
        self.notes = notes
    }
    
    /// Convert photoData to UIImage for display
    /// 
    /// **Learning Note**: UIImage is UIKit's image type.
    /// SwiftUI uses `Image`, but we need UIImage to work with Data.
    #if canImport(UIKit)
    public var photo: UIImage? {
        guard let data = photoData else { return nil }
        return UIImage(data: data)
    }
    #endif
}

