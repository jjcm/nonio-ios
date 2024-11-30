import SwiftUI

struct TagsScreen: View {
    @ObservedObject var viewModel: TagsViewModel
    var didSelect: (Tag) -> Void
    var didSelectAll: () -> Void
    var didCancel: () -> Void

    init(
        viewModel: TagsViewModel,
        didSelect: @escaping (Tag) -> Void,
        didSelectAll: @escaping () -> Void,
        didCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.didSelect = didSelect
        self.didSelectAll = didSelectAll
        self.didCancel = didCancel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        didCancel()
                    } label: {
                        HStack {
                            Text("Posts")
                            Image(systemName: "chevron.right")
                                .frame(width: 17, height: 22)
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .transition(.move(edge: .leading))
        .onAppear {
            viewModel.fetch()
        }
    }
    
    @ViewBuilder
    func tagRow(tag: Tag) -> some View {
        Button {
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
        
    } didCancel: {

    }
}
