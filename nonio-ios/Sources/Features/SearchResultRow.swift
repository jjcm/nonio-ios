import SwiftUI

struct SearchResultRow: View {
    var text: String
    var searchText: String
    var count: Int

    private var highlightedParts: [(String, Bool)] { // (Text Part, IsHighlighted)
        guard !searchText.isEmpty else {
            return [(text, false)]
        }
        let lowercasedText = text.lowercased()
        let lowercasedSearchText = searchText.lowercased()
        var parts: [(String, Bool)] = []
        var currentRange = lowercasedText.startIndex..<lowercasedText.endIndex

        while let foundRange = lowercasedText.range(of: lowercasedSearchText, options: .caseInsensitive, range: currentRange) {
            let before = String(lowercasedText[currentRange.lowerBound..<foundRange.lowerBound])
            if !before.isEmpty {
                parts.append((before, false))
            }
            let match = String(lowercasedText[foundRange.lowerBound..<foundRange.upperBound])
            parts.append((match, true))
            currentRange = foundRange.upperBound..<currentRange.upperBound
        }

        let remaining = String(lowercasedText[currentRange.lowerBound..<currentRange.upperBound])
        if !remaining.isEmpty {
            parts.append((remaining, false))
        }

        return parts
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0..<highlightedParts.count, id: \.self) { index in
                Text(highlightedParts[index].0)
                    .foregroundStyle(highlightedParts[index].1 ? UIColor.label.color : UIColor.secondaryLabel.color)
                    .fontWeight(highlightedParts[index].1 ? .semibold : .regular)
            }
            
            Spacer()
            
            Text(count.description)
                .foregroundStyle(UIColor.label.color)
        }
    }
}

#Preview {
    SearchResultRow(
        text: "result text",
        searchText: "tex",
        count: 1
    )
    .padding()
}
