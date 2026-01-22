import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case recipes = 0
    case menu = 1
    case list = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .recipes: return "Recipes"
        case .menu: return "Menu"
        case .list: return "List"
        }
    }

    var icon: String {
        switch self {
        case .recipes: return "book"
        case .menu: return "fork.knife"
        case .list: return "checklist"
        }
    }
}
