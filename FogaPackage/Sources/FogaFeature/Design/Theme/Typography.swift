import SwiftUI

/// Typography system for Foga app
/// 
/// **Learning Note**: Typography defines text styles throughout the app.
/// Using a centralized system ensures consistency and makes it easy to update fonts globally.
/// 
/// SF Pro Display is Apple's default font, optimized for readability on screens.
public struct AppTypography {
    /// Large title - for hero text and main headings
    /// Size: 34pt, Weight: Bold
    public static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    
    /// Title - for section headings
    /// Size: 28pt, Weight: Bold
    public static let title = Font.system(size: 28, weight: .bold, design: .default)
    
    /// Title 2 - for subsection headings
    /// Size: 22pt, Weight: Semibold
    public static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    
    /// Title 3 - for card titles
    /// Size: 20pt, Weight: Semibold
    public static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    /// Headline - for emphasized text
    /// Size: 17pt, Weight: Semibold
    public static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    
    /// Body - for regular text content
    /// Size: 17pt, Weight: Regular
    public static let body = Font.system(size: 17, weight: .regular, design: .default)
    
    /// Callout - for secondary information
    /// Size: 16pt, Weight: Regular
    public static let callout = Font.system(size: 16, weight: .regular, design: .default)
    
    /// Subheadline - for less important text
    /// Size: 15pt, Weight: Regular
    public static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    
    /// Footnote - for captions and fine print
    /// Size: 13pt, Weight: Regular
    public static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    
    /// Caption - for smallest text
    /// Size: 12pt, Weight: Regular
    public static let caption = Font.system(size: 12, weight: .regular, design: .default)
    
    /// Caption 2 - for even smaller text (secondary captions)
    /// Size: 10pt, Weight: Regular
    public static let caption2 = Font.system(size: 10, weight: .regular, design: .default)
}

/// View modifier for applying typography styles
/// 
/// **Learning Note**: View modifiers let us create reusable styling.
/// Instead of writing `.font(AppTypography.title)` everywhere, we can create custom modifiers.
extension View {
    /// Apply a typography style to text
    public func appTypography(_ style: Font) -> some View {
        self.font(style)
    }
}

