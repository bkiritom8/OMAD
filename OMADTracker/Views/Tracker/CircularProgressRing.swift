import SwiftUI

struct CircularProgressRing<Center: View>: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 18
    var size: CGFloat = 200
    @ViewBuilder let centerContent: () -> Center

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    Color.secondary.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8),
                    value: animatedProgress
                )

            // Center content
            centerContent()
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = min(max(progress, 0), 1)
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = min(max(newValue, 0), 1)
        }
    }
}

#Preview {
    CircularProgressRing(progress: 0.65, color: .primaryGreen) {
        VStack(spacing: 4) {
            Text("65%")
                .font(.title.weight(.bold))
            Text("complete")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
