import SwiftUI

enum Theme {

    enum Layout {
        static let screenHorizontalPadding: CGFloat = 8

        static let cardMaxWidth: CGFloat = 300
        static let cardHorizontalMargin: CGFloat = 24
        static let cardPadding: CGFloat = 16
        static let cardCornerRadius: CGFloat = 20

        static let logoWidth: CGFloat = 300
        static let logoBottomPadding: CGFloat = 12

        static let authTopOffset: CGFloat = -100
        static let authTopSpacerMin: CGFloat = 20
        static let authInnerSpacing: CGFloat = 14
    }

    enum Colors {
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.85)

        // ✅ Vermelho mais forte e legível no fundo escuro/glass
        static let error = Color(red: 1.0, green: 0.28, blue: 0.28)

        // opcional: se quiser colocar “pill” atrás da mensagem
        static let errorBackground = Color.black.opacity(0.35)

        static let border = Color.white.opacity(0.20)

        // Glass overlay (seu padrão final)
        static let glassOverlay = Color.black.opacity(0.45)

        static let cardShadow = Color.black.opacity(0.30)
        static let logoShadow = Color.black.opacity(0.25)

        static let buttonText = Color.white
        static let buttonBackgroundTop = Color.black
        static let buttonBackgroundBottom = Color.black.opacity(0.85)
        static let buttonShadow = Color.black.opacity(0.35)
    }

    enum Typography {
        static let title = Font.title.bold()
        static let footnote = Font.footnote
    }

    enum Effects {
        static let cardShadowRadius: CGFloat = 16
        static let cardShadowY: CGFloat = 10

        static let logoShadowRadius: CGFloat = 8
        static let logoShadowY: CGFloat = 4

        static let borderLineWidth: CGFloat = 1

        static let buttonCornerRadius: CGFloat = 14
        static let buttonVerticalPadding: CGFloat = 14
        static let buttonShadowRadius: CGFloat = 8
        static let buttonShadowY: CGFloat = 4
    }
}

