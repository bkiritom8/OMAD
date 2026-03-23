import SwiftUI
import SwiftData

struct AddCustomFoodSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var fiber: String = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Food Name") {
                    TextField("e.g. My Homemade Dal", text: $name)
                }
                Section("Macros per 100g") {
                    HStack {
                        Text("Calories (kcal)")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Fiber (g)")
                        Spacer()
                        TextField("0", text: $fiber)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                if showError {
                    Section {
                        Text("Please fill in all fields correctly.")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Save Custom Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func save() {
        guard !name.isEmpty,
              let cal  = Double(calories),
              let prot = Double(protein),
              let fib  = Double(fiber) else {
            showError = true
            return
        }
        let food = CustomFood(
            name: name,
            caloriesPer100g: cal,
            proteinPer100g: prot,
            fiberPer100g: fib
        )
        modelContext.insert(food)
        try? modelContext.save()
        dismiss()
    }
}
