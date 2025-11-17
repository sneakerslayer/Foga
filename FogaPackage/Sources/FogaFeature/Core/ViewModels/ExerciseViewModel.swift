import Foundation
import SwiftUI

/// ViewModel for exercise features
@MainActor
public class ExerciseViewModel: ObservableObject {
    /// Available exercises
    @Published public var exercises: [Exercise] = []
    
    /// Currently selected exercise
    @Published public var selectedExercise: Exercise?
    
    /// Exercise timer state
    @Published public var timeRemaining: TimeInterval = 0
    @Published public var isPlaying: Bool = false
    
    /// Timer for exercise countdown
    nonisolated(unsafe) private var timer: Timer?
    
    public init() {
        loadExercises()
    }
    
    /// Load exercises (from JSON file or hardcoded for now)
    private func loadExercises() {
        // Sample exercises - in production, load from JSON file
        exercises = [
            Exercise(
                name: "Jawline Lift",
                description: "Tilt your head back and push your lower jaw forward. Hold for 5 seconds.",
                duration: 30,
                isPremium: false,
                category: .jawline
            ),
            Exercise(
                name: "Neck Stretch",
                description: "Slowly turn your head to the right, hold for 5 seconds, then left.",
                duration: 60,
                isPremium: false,
                category: .neck
            ),
            Exercise(
                name: "Chin Tuck",
                description: "Pull your chin back and down, creating a double chin. Hold for 10 seconds.",
                duration: 45,
                isPremium: true,
                category: .jawline
            )
        ]
    }
    
    /// Start exercise timer
    public func startExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        timeRemaining = exercise.duration
        isPlaying = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopExercise()
                }
            }
        }
    }
    
    /// Stop exercise timer
    public func stopExercise() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
        timeRemaining = 0
    }
    
    deinit {
        timer?.invalidate()
    }
}

