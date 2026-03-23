import Foundation

class GroceryViewModel: ObservableObject {
    @Published var checkedItems: [String: Bool] = [:]

    private let defaultsKey = "groceryCheckedItems"

    init() {
        load()
    }

    // MARK: - Persistence

    private func load() {
        guard let data   = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return
        }
        checkedItems = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(checkedItems) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    // MARK: - Actions

    func toggle(itemID: String) {
        checkedItems[itemID] = !(checkedItems[itemID] ?? false)
        save()
    }

    func isChecked(_ id: String) -> Bool {
        checkedItems[id] ?? false
    }

    func resetAll() {
        checkedItems = [:]
        save()
    }

    // MARK: - Share

    func shareText() -> String {
        var lines: [String] = ["🛒 OMAD WEEKLY GROCERY LIST\n"]

        for section in GroceryData.sections {
            lines.append(section.title.uppercased())

            let unchecked = section.items.filter { !isChecked($0.id) }
            let checked   = section.items.filter {  isChecked($0.id) }

            for item in unchecked {
                lines.append("☐ \(item.name) — \(item.quantity)")
            }
            for item in checked {
                lines.append("✓ \(item.name) — \(item.quantity)")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
