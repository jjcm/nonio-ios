import SwiftUI

struct VideoEncodingView: View {
    let progresses: [EncodingProgress]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(progresses) { progress in
                ResolutionRow(progress: progress)
            }
        }
    }
}

struct ResolutionRow: View {
    let progress: EncodingProgress

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 2) {
                    Text(progress.resolution.rawValue)
                        .font(.callout)
                        .foregroundColor(UIColor.secondaryLabel.color)

                    Text("source")
                        .font(.caption)
                        .foregroundColor(UIColor.blue.color)
                        .showIf(progress.isSource)
                        .offset(y: -4)
                }

                Spacer()

                if progress.finished {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }

            ProgressView(value: progress.progress / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(maxWidth: .infinity)
                .showIf(!progress.finished)
        }
    }
}
