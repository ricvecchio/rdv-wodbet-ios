import SwiftUI

/// Aplica um espaçamento padrão no topo do conteúdo para evitar que
/// os cards fiquem "colados" ou "embaixo" do cabeçalho.
struct ContentLayoutUnderNavBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, Theme.Layout.screenContentTopPadding)
    }
}

extension View {
    func contentUnderNavBarPadding() -> some View {
        modifier(ContentLayoutUnderNavBar())
    }
}

