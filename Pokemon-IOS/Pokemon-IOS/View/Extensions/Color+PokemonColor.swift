import SwiftUI

extension Color {
    static func color(from string: String) -> Color {
        switch string.lowercased() {
        case "red":
            return .red
        case "pink":
            return .pink
        case "black":
            return .black
        case "brown":
            return .brown
        case "purple":
            return .purple
        case "yellow":
            return .red
        case "blue":
            return .blue
        case "green":
            return .green
        default:
            return .gray
        }
    }
}
