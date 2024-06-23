import SwiftUI

struct InputForm: View {

    let title: String
    let placeholder: String
    var error: String?
    @Binding var value: String

    var body: some View {
        HStack {
            Text(title)
                .frame(minWidth: 70, alignment: .leading)
            VStack(alignment: .leading) {
                TextField(placeholder, text: $value)
                    .textFieldStyle(.plain)
                if let error {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    InputForm(
        title: "title",
        placeholder: "placeholder",
        error: "error message",
        value: .constant("")
    )
    .padding()
}
