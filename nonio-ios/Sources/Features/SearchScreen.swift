import SwiftUI

struct SearchScreen: View {
    @ObservedObject private var viewModel = SearchViewModel()
    @FocusState private var isInputActive: Bool

    let onSelect: ((Tag?) -> Void)
    let onCancel: (() -> Void)
    init(onSelect: @escaping (Tag?) -> Void, onCancel: @escaping () -> Void) {
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

                List(viewModel.tags, id: \.tag) { tag in
                    Button {
                        viewModel.selectedTag = tag
                        Task {
                            try await Task.sleep(seconds: 0.5)
                            onSelect(tag)
                        }
                    } label: {
                        SearchResultRow(text: tag.tag, searchText: viewModel.searchText, selected: viewModel.selectedTag == tag)
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
            }
            .background(UIColor.secondarySystemBackground.color)
            .navigationTitle("Search Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
