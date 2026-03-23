import SwiftUI

struct MealPlanView: View {
    @State private var selectedDayIndex: Int = Date().weekdayIndex

    private var selectedDay: MealDay { MealPlanData.mealDay(for: selectedDayIndex) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DaySelector(selectedDayIndex: $selectedDayIndex)
                    .padding(.vertical, 12)
                    .background(Color(.systemGroupedBackground))

                ScrollView {
                    LazyVStack(spacing: 8) {
                        // Day title
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedDay.dayName)
                                    .font(.headline)
                                Text(selectedDay.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Plan calorie banner
                        if selectedDay.totalCalories > 1680 {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.white)
                                Text("Plan exceeds target — \(Int(selectedDay.totalCalories)) kcal")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.white)
                                Text("Plan total: \(Int(selectedDay.totalCalories)) kcal — \(Int(1680 - selectedDay.totalCalories)) under cap")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.primaryGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        }

                        // Day tip
                        if !selectedDay.tip.isEmpty {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundStyle(.yellow)
                                Text(selectedDay.tip)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.yellow.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        }

                        // Food cards
                        ForEach(selectedDay.items) { item in
                            MealFoodCard(item: item)
                                .padding(.horizontal)
                        }

                        // Totals footer
                        totalsFooter
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Meal Plan")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var totalsFooter: some View {
        VStack(spacing: 8) {
            Divider()
            HStack {
                Text("Day Total")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }
            HStack(spacing: 20) {
                totalChip(value: Int(selectedDay.totalCalories), label: "kcal", color: Color.primaryGreen)
                totalChip(value: Int(selectedDay.totalProtein), label: "g protein", color: .blue)
                totalChip(value: Int(selectedDay.totalFiber), label: "g fiber", color: .orange)
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 4)
    }

    private func totalChip(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MealPlanView()
}
