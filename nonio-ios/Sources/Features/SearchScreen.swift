import SwiftUI

struct SearchScreen: View {
    @ObservedObject private var viewModel = SearchViewModel()

    let onSelect: ((Tag?) -> Void)
    init(onSelect: @escaping (Tag?) -> Void) {
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search...", text: $viewModel.searchText)
                .padding(8)
                .padding(.horizontal, 25)
                .background(UIColor.tertiarySystemBackground.color)
                .cornerRadius(8)
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
                .padding(.horizontal, 16)

                List(viewModel.tags, id: \.tag) { tag in
                    Button {
                        viewModel.selectedTag = tag
                    } label: {
                        SearchResultRow(text: tag.tag, searchText: viewModel.searchText, selected: viewModel.selectedTag == tag)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSelect(viewModel.selectedTag)
                    } label: {
                        Text("OK")
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
