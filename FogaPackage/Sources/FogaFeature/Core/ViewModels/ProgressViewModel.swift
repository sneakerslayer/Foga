import Foundation
import SwiftUI

/// ViewModel for progress tracking
@MainActor
public class ProgressViewModel: ObservableObject {
    /// Data service
    private let dataService: DataService
    
    /// All progress entries
    @Published public var progressEntries: [Progress] = []
    
    /// Selected progress entry for detail view
    @Published public var selectedProgress: Progress?
    
    public init(dataService: DataService) {
        self.dataService = dataService
        loadProgress()
    }
    
    /// Load progress entries
    private func loadProgress() {
        progressEntries = dataService.progressEntries.sorted { $0.date > $1.date }
    }
    
    /// Add new progress entry
    public func addProgress(_ progress: Progress) {
        dataService.addProgress(progress)
        loadProgress()
    }
    
    /// Get latest progress entry
    public var latestProgress: Progress? {
        return progressEntries.first
    }
    
    /// Get baseline measurement
    public var baselineMeasurement: FaceMeasurement? {
        return progressEntries.last?.measurements
    }
}

