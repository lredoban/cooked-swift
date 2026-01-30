import SwiftUI

/// A menu picker for selecting recipe sort order
struct SortPicker: View {
    @Binding var selection: RecipeSortOption

    var body: some View {
        SwiftUI.Menu {
            Picker("Sort by", selection: $selection) {
                ForEach(RecipeSortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .foregroundStyle(Color.dopamineYellow)
        }
    }
}

#Preview {
    NavigationStack {
        Text("Content")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SortPicker(selection: .constant(.recent))
                }
            }
    }
}
