import SwiftUI

struct DaySelector: View {
    @Binding var selectedDayIndex: Int  // 0 = Monday, 6 = Sunday

    private let days = ["M", "T", "W", "T", "F", "S", "S"]
    private var todayIndex: Int { Date().weekdayIndex }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDayIndex = i
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(days[i])
                                .font(.subheadline.weight(.semibold))
                                .frame(width: 38, height: 38)
                                .background(selectedDayIndex == i
                                    ? Color.primaryGreen
                                    : Color(.secondarySystemGroupedBackground))
                                .foregroundStyle(selectedDayIndex == i ? .white : .primary)
                                .clipShape(Circle())

                            Circle()
                                .fill(i == todayIndex ? Color.primaryGreen : .clear)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
