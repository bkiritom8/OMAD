import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0

    var body: some View {
        TabView(selection: $page) {
            screen1.tag(0)
            screen2.tag(1)
            screen3.tag(2)
            screen4.tag(3)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .animation(.easeInOut, value: page)
    }

    // MARK: Screen 1 — Your 4-week OMAD plan

    private var screen1: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.primaryGreen)
            }

            VStack(spacing: 10) {
                Text("Your 4-Week OMAD Plan")
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                Text("One meal a day. One hour window. Consistent every day.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 10) {
                planRow(icon: "scalemass.fill",  label: "Goal",          value: "82 kg → 79 kg in 4 weeks")
                planRow(icon: "fork.knife",       label: "Daily intake",  value: "~1,680 kcal")
                planRow(icon: "flame.fill",       label: "Daily burn",    value: "~2,500 kcal (base + gym + walks)")
                planRow(icon: "arrow.down.circle.fill", label: "Deficit", value: "~820 kcal/day")
            }
            .padding(.horizontal, 32)

            Spacer()
            nextButton("Next")
        }
        .padding(.bottom, 40)
    }

    // MARK: Screen 2 — What you eat every day

    private var screen2: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.primaryGreen)
                Text("What You Eat Every Day")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 10) {
                mealRow(icon: "moon.zzz.fill",       text: "Overnight oats + chia seeds — prep the night before")
                mealRow(icon: "bag.fill",             text: "Aldi California Medley — steam the full 340g bag")
                mealRow(icon: "cup.and.saucer.fill",  text: "Protein shake — whey + Lactaid + banana blended")
                mealRow(icon: "bolt.heart.fill",      text: "Chicken breast 220g + Greek yogurt 150g")
                mealRow(icon: "leaf.fill",            text: "Curry (chole or rajma) + basmati rice + fruit")
            }
            .padding(.horizontal, 32)

            VStack(spacing: 4) {
                Text("Chole days: Mon, Wed, Fri, Sun")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryGreen)
                Text("Rajma days: Tue, Thu, Sat (+ 1 boiled egg)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 32)

            Spacer()
            nextButton("Next")
        }
        .padding(.bottom, 40)
    }

    // MARK: Screen 3 — Your daily schedule

    private var screen3: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.primaryGreen)
                Text("Your Daily Schedule")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 12) {
                scheduleRow(time: "Morning",   icon: "scalemass",        text: "Weigh yourself before eating or drinking")
                scheduleRow(time: "1–2 PM",    icon: "fork.knife",       text: "Eating window — eat everything within this hour")
                scheduleRow(time: "Any time",  icon: "figure.walk",      text: "2 × 15 min dog walks (150 kcal)")
                scheduleRow(time: "Any time",  icon: "dumbbell",         text: "1hr gym — mixed cardio + weights (400 kcal)")
                scheduleRow(time: "Night",     icon: "moon.stars.fill",  text: "Prep overnight oats for tomorrow")
            }
            .padding(.horizontal, 32)

            Spacer()
            nextButton("Next")
        }
        .padding(.bottom, 40)
    }

    // MARK: Screen 4 — Notifications

    private var screen4: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.primaryGreen)
            }

            VStack(spacing: 10) {
                Text("Stay on Track")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                Text("Get reminders for your eating window, weigh-ins, and water goal.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 10) {
                featureRow(icon: "bell.fill",      text: "12:30 PM — Prep your meal")
                featureRow(icon: "fork.knife",     text: "1:00 PM — Eating window opens")
                featureRow(icon: "timer",          text: "2:00 PM — Window closing")
                featureRow(icon: "scalemass",      text: "8:00 PM — Log your weight")
                featureRow(icon: "drop.fill",      text: "9:00 PM — Water goal check")
            }
            .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 12) {
                Button("Allow Notifications") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.primaryGreen)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)

                Button("Skip for Now") {
                    UserDefaults.standard.set(true, forKey: "onboardingComplete")
                    onComplete()
                }
                .foregroundStyle(.secondary)
                .font(.subheadline)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: Helpers

    private func nextButton(_ label: String) -> some View {
        Button(label) {
            withAnimation { page = min(page + 1, 3) }
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.primaryGreen)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }

    private func planRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.primaryGreen)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
            }
            Spacer()
        }
    }

    private func mealRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.primaryGreen)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }

    private func scheduleRow(time: String, icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(time)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primaryGreen)
                .frame(width: 60, alignment: .trailing)
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.primaryGreen)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
