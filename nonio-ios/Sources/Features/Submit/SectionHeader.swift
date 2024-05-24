import SwiftUI

struct SectionHeader: View {

    let title: String
    let subtitle: String?
    init(_ title: String, _ subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(UIColor.secondaryLabel.color)
                .padding(.bottom, subtitle == nil ? 8 : 0)

            if let subtitle {
                Text(subtitle)
                    .plainListItem()
                    .font(.subheadline)
                    .foregroundStyle(UIColor.secondaryLabel.color)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
        }
        .plainListItem()
        .textCase(nil)
    }
}
