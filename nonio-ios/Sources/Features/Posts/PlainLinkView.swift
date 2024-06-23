import SwiftUI

struct PlainLinkView: View {
    let urlString: String
    
    var body: some View {
        HStack {
            Icon(image: R.image.link.image, size: .big)

            Text(urlString)
                .font(.callout)
                .foregroundColor(.secondary)
                .lineLimit(1)

            Spacer()

            Icon(image: R.image.chevronRight.image, size: .big)
        }
        .padding(8)
        .background(UIColor.systemGray6.color)
        .cornerRadius(10)
        .frame(height: 32)
    }
}

#Preview {
    PlainLinkView(urlString: "https://www.google.com")
        .padding()
}
