import SwiftUI

/// Circular progress ring component
/// 
/// **Learning Note**: This creates a custom progress indicator using SwiftUI's drawing APIs.
/// We use `Path` and `Shape` to draw the ring, then animate it smoothly.
/// 
/// **Swift Concepts**:
/// - `Shape` protocol: Lets us create custom shapes
/// - `@State`: Tracks local view state (the animation progress)
/// - `withAnimation`: Animates state changes smoothly
@available(iOS 15.0, *)
public struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let color: Color
    
    /// Track the animated progress (starts at 0, animates to actual progress)
    @State private var animatedProgress: Double = 0
    
    public init(
        progress: Double,
        lineWidth: CGFloat = 12,
        color: Color = AppColors.primary
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.color = color
    }
    
    public var body: some View {
        ZStack {
            // Background ring (gray)
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress ring (colored)
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90)) // Start from top
        }
        .onAppear {
            // Animate progress when view appears
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            // Animate when progress changes
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

/// Preview for development
struct ProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            ProgressRing(progress: 0.3)
                .frame(width: 100, height: 100)
            
            ProgressRing(progress: 0.7, color: AppColors.secondary)
                .frame(width: 100, height: 100)
            
            ProgressRing(progress: 1.0)
                .frame(width: 100, height: 100)
        }
        .padding()
    }
}

