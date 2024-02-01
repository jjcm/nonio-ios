import SwiftUI

struct CommentButton: View {
    let action: (() -> Void)
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                Icon(image: R.image.comment.image, size: .medium)
                    .tint(UIColor.secondaryLabel.color)
                
                Text("Add Comment")
                    .font(.callout)
                    .foregroundColor(UIColor.tertiaryLabel.color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 66)
                            .inset(by: 0.5)
                            .stroke(UIColor.separator.color, lineWidth: 1)
                    )
            }
        }
        .padding() 
    }
}

#Preview {
    CommentButton(action: {})
}
