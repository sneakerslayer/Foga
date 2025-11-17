import SwiftUI

/// Gradient background component
/// 
/// **Learning Note**: This creates a reusable background with gradients.
/// Using components like this makes it easy to maintain consistent backgrounds.
@available(iOS 15.0, *)
public struct GradientBackground: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    public init(
        colors: [Color] = [AppColors.primary.opacity(0.1), AppColors.secondary.opacity(0.1)],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    public var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .ignoresSafeArea()
    }
}

