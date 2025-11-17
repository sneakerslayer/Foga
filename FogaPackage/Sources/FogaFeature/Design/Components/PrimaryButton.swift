import SwiftUI

/// Primary button component used throughout the app
/// 
/// **Learning Note**: Creating reusable components saves time and ensures consistency.
/// This button follows the app's design system with gradients and animations.
/// 
/// **Swift Concepts Used**:
/// - `@ViewBuilder`: Lets us create flexible views that can contain different content
/// - `ButtonStyle`: Custom button styling protocol
/// - `Animation`: SwiftUI's animation system for smooth interactions
@available(iOS 15.0, *)
public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    
    /// Button style variants
    public enum ButtonStyle {
        case primary    // Coral gradient
        case secondary  // Teal gradient
        case outline    // Outlined style
    }
    
    public init(title: String, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.style = style
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 56)
            .background(backgroundForStyle)
            .cornerRadius(AppCornerRadius.medium)
            .appShadow(AppShadows.button)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    
    @ViewBuilder
    private var backgroundForStyle: some View {
        switch style {
        case .primary:
            AppColors.primaryGradient
        case .secondary:
            AppColors.secondaryGradient
        case .outline:
            Color.clear
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .stroke(AppColors.primary, lineWidth: 2)
                )
        }
    }
}

/// Custom button style for press animations
/// 
/// **Learning Note**: ButtonStyle protocol lets us customize button behavior.
/// This adds a "scale down" effect when pressed, making buttons feel responsive.
@available(iOS 15.0, *)
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

