import SwiftUI

extension View {
    func plainListItem(rowInset: EdgeInsets = EdgeInsets()) -> some View {
        self
            .listRowBackground(Color.clear)
            .listRowInsets(rowInset)
            .listRowSeparator(.hidden)        
    }
}
