import SafariServices
import SwiftUI

public struct SafariView: View {
    var url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        SafariViewRepresentable(url: url)
            .ignoresSafeArea()
    }
}

private struct SafariViewRepresentable: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<SafariViewRepresentable>
    ) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ safariViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariViewRepresentable>
    ) {
    }
}
