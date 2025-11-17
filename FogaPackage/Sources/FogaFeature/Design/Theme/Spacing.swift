import SwiftUI

/// Spacing system for consistent layout
/// 
/// **Learning Note**: Using a spacing system ensures consistent gaps between UI elements.
/// This follows the "8-point grid" system used by many design teams.
public struct AppSpacing {
    /// Extra small spacing - 4pt
    public static let xs: CGFloat = 4
    
    /// Small spacing - 8pt
    public static let small: CGFloat = 8
    
    /// Medium spacing - 16pt (most common)
    public static let medium: CGFloat = 16
    
    /// Large spacing - 24pt
    public static let large: CGFloat = 24
    
    /// Extra large spacing - 32pt
    public static let xl: CGFloat = 32
    
    /// Extra extra large spacing - 48pt
    public static let xxl: CGFloat = 48
}

/// Corner radius values
/// 
/// **Learning Note**: Corner radius makes UI elements look modern and friendly.
/// iOS uses rounded corners everywhere - it's part of Apple's design language.
public struct AppCornerRadius {
    /// Small radius - 8pt
    public static let small: CGFloat = 8
    
    /// Medium radius - 16pt (for cards as specified)
    public static let medium: CGFloat = 16
    
    /// Large radius - 24pt
    public static let large: CGFloat = 24
}

/// Shadow styles for neumorphic design
/// 
/// **Learning Note**: Neumorphism creates soft, subtle shadows that make elements
/// appear to emerge from the background. It's popular in modern app design.
public struct AppShadows {
    /// Soft shadow for cards
    public static let card = Shadow(
        color: Color.black.opacity(0.05),
        radius: 10,
        x: 0,
        y: 4
    )
    
    /// Lighter shadow for subtle elevation
    public static let subtle = Shadow(
        color: Color.black.opacity(0.03),
        radius: 5,
        x: 0,
        y: 2
    )
    
    /// Stronger shadow for buttons
    public static let button = Shadow(
        color: Color.black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 4
    )
}

/// Shadow configuration struct
public struct Shadow: Sendable {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

/// View extension to apply shadows easily
extension View {
    /// Apply a shadow style
    public func appShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

