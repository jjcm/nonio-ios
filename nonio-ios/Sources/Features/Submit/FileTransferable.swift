import CoreTransferable

struct FileTransferable: Transferable {
    let url: URL
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .data) { data in
            return SentTransferredFile(data.url)
        } importing: { received in
            let origin = received.file
            let filename = origin.lastPathComponent
            let copied = URL.documentsDirectory.appendingPathComponent(filename)
            let filePath = copied.path()

            if FileManager.default.fileExists(atPath: filePath) {
              try FileManager.default.removeItem(atPath: filePath)
            }

            try FileManager.default.copyItem(at: origin, to: copied)
            return FileTransferable(url: copied, filename: filename)
        }
    }
}
