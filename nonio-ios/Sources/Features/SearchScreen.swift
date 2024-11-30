import SwiftUI

struct SearchScreen: View {
    @ObservedObject private var viewModel: SearchViewModel
    @FocusState private var isInputActive: Bool

    let onSelect: ((Tag?) -> Void)
    let onCancel: (() -> Void)
    init(
        showCreateNewTag: Bool = false,
        onSelect: @escaping (Tag?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = SearchViewModel(showCreateNewTag: showCreateNewTag)
        self.onSelect = onSelect
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search...", text: $viewModel.searchText)
                .padding(8)
                .padding(.horizontal, 25)
                .background(UIColor.tertiarySystemBackground.color)
                .cornerRadius(8)
                .focused($isInputActive)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isInputActive = true
                    }
                }
                .padding(.horizontal, 16)

                List {
                    ForEach(Array(viewModel.tags.enumerated()), id: \.offset) { (index, tag) in
                        if viewModel.isCreateNewTag(index: index) {
                            HStack {
                                Text(viewModel.searchText)
                                    .foregroundStyle(UIColor.label.color)
                                    .fontWeight(.semibold)

                                Spacer()

                                Button {
                                    onSelect(.init(tag: viewModel.searchText, count: 0))
                                } label: {
                                    Text("create new tag")
                                        .foregroundStyle(.tint)
                                }
                            }
                        } else {
                            Button {
                                onSelect(tag)
                            } label: {
                                SearchResultRow(text: tag.tag, searchText: viewModel.searchText, count: tag.count)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    ProgressView()
                        .showIf(viewModel.loading)
                }
            }
            .background(UIColor.secondarySystemBackground.color)
            .navigationTitle("Search Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchScreen(
        showCreateNewTag: false) { tag in

        } onCancel: {
            print(">>onCancel")
        }
}
