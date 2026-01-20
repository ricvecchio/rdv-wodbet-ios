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

    private var maxWidth: CGFloat? {
        switch widthStyle {
        case .fill:
            return .infinity
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
                .frame(maxWidth: maxWidth)
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
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

