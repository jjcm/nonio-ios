import SwiftUI

struct ClearableTextField: View {

    let title: String
    let secureType: Bool
    let keyboardType: UIKeyboardType
    @Binding var text: String

    init(
        _ title: String,
        secureType: Bool,
        keyboardType: UIKeyboardType = .default,
        text: Binding<String>
    ) {
        self.title = title
        self.secureType = secureType
        self.keyboardType = keyboardType
        _text = text
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            if secureType {
                SecureField(title, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(maxHeight: .infinity)
            } else {
                TextField(title, text: $text)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(maxHeight: .infinity)
            }

            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
                .onTapGesture {
                    text = ""
                }
                .showIf(!text.isEmpty)
        }
    }
}
