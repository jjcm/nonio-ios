import SwiftUI

struct TagsScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: TagsViewModel
    var didSelect: (Tag) -> Void
    var didSelectAll: () -> Void
    init(
        viewModel: TagsViewModel,
        didSelect: @escaping (Tag) -> Void,
        didSelectAll: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.didSelect = didSelect
        self.didSelectAll = didSelectAll
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.loading {
                ProgressView()
            } else {
                allPostsRow()               
                
                List(viewModel.tags, id: \.self) { tag in
                    tagRow(tag: tag)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .listStyle(.plain)
                .navigationTitle("Tags")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            viewModel.fetch()
        }
    }
    
    @ViewBuilder
    func tagRow(tag: Tag) -> some View {
        Button {
            self.presentationMode.wrappedValue.dismiss()
            didSelect(tag)
        } label: {
            HStack(alignment: .center, spacing: 8) {
                R.image.hash.image
                    .resizable()
                    .frame(width: 16, height: 16)

                Text(tag.tag)
                    .lineLimit(1)
                    .font(.title3)
                
                Spacer()
                
                if viewModel.isTagSelected(tag: tag) {
                    Image(systemName: "checkmark")
                        .renderingMode(.template)
                        .foregroundStyle(.green)
                }
            }
        }
        .frame(minHeight: 44)
    }
    
    @ViewBuilder
    func allPostsRow() -> some View {
        Button {
            self.presentationMode.wrappedValue.dismiss()
            didSelectAll()
        } label: {
            HStack(spacing: 8) {
                Icon(image: R.image.allPost.image, size: .small)
                    .foregroundStyle(.blue)

                Text("All Posts")
                    .lineLimit(1)
                    .font(.title3)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .frame(minHeight: 44)
    }
}

#Preview {
    TagsScreen(viewModel: .init()) { _ in
        
    } didSelectAll: {
        
    }
}
