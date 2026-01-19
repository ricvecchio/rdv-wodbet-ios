import SwiftUI

struct PrimaryButton: View {

    enum WidthStyle {
        case fill
        case card
        case custom(CGFloat)
    }

    let title: String
    let isDisabled: Bool
    let widthStyle: WidthStyle
    let action: () -> Void

    init(
        title: String,
        isDisabled: Bool,
        widthStyle: WidthStyle = .fill,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isDisabled = isDisabled
        self.widthStyle = widthStyle
        self.action = action
    }

    private var targetWidth: CGFloat? {
        switch widthStyle {
        case .fill:
            return nil
        case .card:
            return Theme.Layout.cardMaxWidth
        case .custom(let w):
            return w
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.Colors.buttonText)
                .padding(.vertical, Theme.Effects.buttonVerticalPadding)
                .frame(width: targetWidth) // ✅ largura fixa quando card/custom
                .frame(maxWidth: targetWidth == nil ? .infinity : nil) // ✅ fill quando nil
                .background(
                    LinearGradient(
                        colors: [
                            Theme.Colors.buttonBackgroundTop,
                            Theme.Colors.buttonBackgroundBottom
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(Theme.Effects.buttonCornerRadius)
                .shadow(
                    color: Theme.Colors.buttonShadow,
                    radius: Theme.Effects.buttonShadowRadius,
                    x: 0,
                    y: Theme.Effects.buttonShadowY
                )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
        .frame(maxWidth: .infinity, alignment: .center) // ✅ centraliza
    }
}

