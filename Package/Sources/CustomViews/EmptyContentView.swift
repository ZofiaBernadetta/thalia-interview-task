import SwiftUI

public struct EmptyContentView<Content: View>: View {
    var content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 8) {
            content()
        }
        .multilineTextAlignment(.center)
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
        .imageScale(.large)
    }
}
