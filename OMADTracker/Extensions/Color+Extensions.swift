import SwiftUI

extension Color {
    /// Primary brand green #1D9E75
    static let primaryGreen = Color(red: 0.114, green: 0.620, blue: 0.459)

    /// Locked items purple #534AB7
    static let lockedPurple = Color(red: 0.325, green: 0.290, blue: 0.718)

    /// Returns green if under/at target, red if over
    static func macroColor(logged: Double, target: Double) -> Color {
        logged > target ? .red : .primaryGreen
    }

    /// Fasting color based on elapsed hours
    /// 0–15h: gray | 15–18h: yellow | 18–21h: green | 21–23h: teal | 23h+: red
    static func fastingColor(hours: Double) -> Color {
        switch hours {
        case ..<15:    return .gray
        case 15..<18:  return .yellow
        case 18..<21:  return .primaryGreen
        case 21..<23:  return .teal
        default:       return .red
        }
    }
}
