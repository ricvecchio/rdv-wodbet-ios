import SwiftUI

/// Estilo padrão do cabeçalho (NavigationBar) com fundo preto translúcido.
/// Centraliza o visual e evita duplicação de código nas telas.
struct AppNavigationBarStyle: ViewModifier {

    func body(content: Content) -> some View {
        content
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.Colors.navBarBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tint(Theme.Colors.textPrimary)
    }
}

extension View {
    func appNavigationBarStyle() -> some View {
        modifier(AppNavigationBarStyle())
    }
}

