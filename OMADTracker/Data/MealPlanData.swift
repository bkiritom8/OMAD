import Foundation

struct MealItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: String
    let calories: Double
    let protein: Double
    let fiber: Double
    let isLocked: Bool
    var note: String = ""
}

struct MealDay: Identifiable {
    let id = UUID()
    let dayNumber: Int
    let dayName: String
    let title: String
    let items: [MealItem]
    var tip: String = ""

    var totalCalories: Double { items.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double  { items.reduce(0) { $0 + $1.protein } }
    var totalFiber: Double    { items.reduce(0) { $0 + $1.fiber } }
}

// MARK: - Calorie Budget Arithmetic
//
// LOCKED items every day (685 kcal | 49g P | 24g F):
//   Overnight oats 40g + chia 1 tbsp : 206 kcal |  7g P |  9g F  [LOCKED]
//   Aldi California Medley 340g      : 120 kcal |  8g P | 12g F  [LOCKED]
//   Whey + Lactaid 250ml + banana    : 359 kcal | 34g P |  3g F  [LOCKED]
//
// DAILY items (toggleable, same every day):
//   Chicken breast 220g cooked       : 363 kcal | 68g P |  0g F
//   Greek yogurt 0% fat 150g         :  90 kcal | 15g P |  0g F
//   Curry base (onion+tomato+1tsp)   :  90 kcal |  2g P |  2g F
//   Basmati rice 100g cooked         : 130 kcal |  3g P |  0g F
//
// Chole days (Mon/Wed/Fri/Sun):
//   Chole 160g cooked : 263 kcal | 12g P | 10g F
//   Apple 1 medium    :  68 kcal |  0g P |  3g F
//   Computed day total: 206+120+359+363+90+90+263+130+68 = 1689 kcal | 149g P | 39g F
//
// Rajma days (Tue/Thu/Sat) + egg:
//   Egg 1 boiled      :  72 kcal |  6g P |  0g F
//   Rajma 175g cooked : 231 kcal | 12g P | 10g F
//   Pear 1 medium     :  74 kcal |  1g P |  4g F
//   Computed day total: 206+120+359+363+72+90+90+231+130+74 = 1735 kcal | 156g P | 40g F

enum MealPlanData {
    static let allDays: [MealDay] = [

        // DAY 1 — Monday (CHOLE)
        // 206+120+359+363+90+90+263+130+68 = 1689 kcal | 149g P | 39g F
        MealDay(dayNumber: 1, dayName: "Monday", title: "Chole Chicken Rice Bowl", items: [
            MealItem(name: "Rolled oats 40g + chia seeds 1 tbsp + water",
                     quantity: "1 bowl",
                     calories: 206, protein: 7,  fiber: 9,  isLocked: true,
                     note: "Prep the night before. Eat within your 1–3 PM meal window."),
            MealItem(name: "Aldi California Medley 340g bag, steamed",
                     quantity: "340g steamed",
                     calories: 120, protein: 8,  fiber: 12, isLocked: true),
            MealItem(name: "Whey protein + Lactaid 250ml + 1 banana blended",
                     quantity: "1 scoop + 250ml + 1 banana",
                     calories: 359, protein: 34, fiber: 3,  isLocked: true,
                     note: "Blend together. Have within meal window or post-gym."),
            MealItem(name: "Chicken breast 220g cooked",
                     quantity: "220g cooked",
                     calories: 363, protein: 68, fiber: 0,  isLocked: false),
            MealItem(name: "Greek yogurt 0% fat 150g",
                     quantity: "150g",
                     calories: 90,  protein: 15, fiber: 0,  isLocked: false),
            MealItem(name: "Curry base",
                     quantity: "onion + tomato + 1 tsp oil + spices",
                     calories: 90,  protein: 2,  fiber: 2,  isLocked: false,
                     note: "1 tsp oil only — measure it, do not eyeball."),
            MealItem(name: "Chole 160g cooked",
                     quantity: "160g cooked",
                     calories: 263, protein: 12, fiber: 10, isLocked: false),
            MealItem(name: "Basmati rice 100g cooked",
                     quantity: "100g cooked",
                     calories: 130, protein: 3,  fiber: 0,  isLocked: false),
            MealItem(name: "Apple 1 medium",
                     quantity: "1 medium",
                     calories: 68,  protein: 0,  fiber: 3,  isLocked: false),
        ], tip: "Grill chicken with cumin + paprika. Cook chole with 1 tsp oil only. Eat oats first within your 1hr window, then the main plate. Batch cook extra chole for Wed + Fri + Sun."),

        // DAY 2 — Tuesday (RAJMA + EGG)
        // 206+120+359+363+72+90+90+231+130+74 = 1735 kcal | 156g P | 40g F
        MealDay(dayNumber: 2, dayName: "Tuesday", title: "Rajma Chicken Bowl", items: [
            MealItem(name: "Rolled oats 40g + chia seeds 1 tbsp + water",
                     quantity: "1 bowl",
                     calories: 206, protein: 7,  fiber: 9,  isLocked: true,
                     note: "Prep the night before. Eat within your 1–3 PM meal window."),
            MealItem(name: "Aldi California Medley 340g bag, steamed",
                     quantity: "340g steamed",
                     calories: 120, protein: 8,  fiber: 12, isLocked: true),
            MealItem(name: "Whey protein + Lactaid 250ml + 1 banana blended",
                     quantity: "1 scoop + 250ml + 1 banana",
                     calories: 359, protein: 34, fiber: 3,  isLocked: true,
                     note: "Blend together. Have within meal window or post-gym."),
            MealItem(name: "Chicken breast 220g cooked",
                     quantity: "220g cooked",
                     calories: 363, protein: 68, fiber: 0,  isLocked: false),
            MealItem(name: "Egg 1 boiled",
                     quantity: "1 boiled",
                     calories: 72,  protein: 6,  fiber: 0,  isLocked: false),
            MealItem(name: "Greek yogurt 0% fat 150g",
                     quantity: "150g",
                     calories: 90,  protein: 15, fiber: 0,  isLocked: false),
            MealItem(name: "Curry base",
                     quantity: "onion + tomato + 1 tsp oil + spices",
                     calories: 90,  protein: 2,  fiber: 2,  isLocked: false,
                     note: "1 tsp oil only — measure it, do not eyeball."),
            MealItem(name: "Rajma 175g cooked",
                     quantity: "175g cooked",
                     calories: 231, protein: 12, fiber: 10, isLocked: false),
            MealItem(name: "Basmati rice 100g cooked",
                     quantity: "100g cooked",
                     calories: 130, protein: 3,  fiber: 0,  isLocked: false),
            MealItem(name: "Pear 1 medium",
                     quantity: "1 medium",
                     calories: 74,  protein: 1,  fiber: 4,  isLocked: false),
        ], tip: "Classic rajma chawal. Batch cook enough rajma for Thu + Sat too. The egg adds easy protein — boil it alongside the rice."),

        // DAY 3 — Wednesday (CHOLE)
        // 206+120+359+363+90+90+263+130+68 = 1689 kcal | 149g P | 39g F
        MealDay(dayNumber: 3, dayName: "Wednesday", title: "Baked Chicken Chole Plate", items: [
            MealItem(name: "Rolled oats 40g + chia seeds 1 tbsp + water",
                     quantity: "1 bowl",
                     calories: 206, protein: 7,  fiber: 9,  isLocked: true,
                     note: "Prep the night before. Eat within your 1–3 PM meal window."),
            MealItem(name: "Aldi California Medley 340g bag, steamed",
                     quantity: "340g steamed",
                     calories: 120, protein: 8,  fiber: 12, isLocked: true),
            MealItem(name: "Whey protein + Lactaid 250ml + 1 banana blended",
                     quantity: "1 scoop + 250ml + 1 banana",
                     calories: 359, protein: 34, fiber: 3,  isLocked: true,
                     note: "Blend together. Have within meal window or post-gym."),
            MealItem(name: "Chicken breast 220g cooked",
                     quantity: "220g cooked (baked)",
                     calories: 363, protein: 68, fiber: 0,  isLocked: false),
            MealItem(name: "Greek yogurt 0% fat 150g",
                     quantity: "150g",
                     calories: 90,  protein: 15, fiber: 0,  isLocked: false),
            MealItem(name: "Curry base",
                     quantity: "onion + tomato + 1 tsp oil + spices",
                     calories: 90,  protein: 2,  fiber: 2,  isLocked: false,
                     note: "1 tsp oil only — measure it, do not eyeball."),
            MealItem(name: "Chole 160g cooked",
                     quantity: "160g cooked",
                     calories: 263, protein: 12, fiber: 10, isLocked: false),
            MealItem(name: "Basmati rice 100g cooked",
                     quantity: "100g cooked",
                     calories: 130, protein: 3,  fiber: 0,  isLocked: false),
            MealItem(name: "Apple 1 medium",
                     quantity: "1 medium",
                     calories: 68,  protein: 0,  fiber: 3,  isLocked: false),
        ], tip: "Bake chicken at 200°C — garlic, paprika, lemon juice, zero oil needed. Reheat Monday's chole batch. Sub yogurt with 2 boiled eggs if you run out."),

        // DAY 4 — Thursday (RAJMA + EGG)
        // 206+120+359+363+72+90+90+231+130+74 = 1735 kcal | 156g P | 40g F
        MealDay(dayNumber: 4, dayName: "Thursday", title: "Chicken Rajma Rice", items: [
            MealItem(name: "Rolled oats 40g + chia seeds 1 tbsp + water",
                     quantity: "1 bowl",
                     calories: 206, protein: 7,  fiber: 9,  isLocked: true,
                     note: "Prep the night before. Eat within your 1–3 PM meal window."),
            MealItem(name: "Aldi California Medley 340g bag, steamed",
                     quantity: "340g steamed",
                     calories: 120, protein: 8,  fiber: 12, isLocked: true),
            MealItem(name: "Whey protein + Lactaid 250ml + 1 banana blended",
                     quantity: "1 scoop + 250ml + 1 banana",
                     calories: 359, protein: 34, fiber: 3,  isLocked: true,
                     note: "Blend together. Have within meal window or post-gym."),
            MealItem(name: "Chicken breast 220g cooked",
                     quantity: "220g cooked",
                     calories: 363, protein: 68, fiber: 0,  isLocked: false),
            MealItem(name: "Egg 1 boiled",
                     quantity: "1 boiled",
                     calories: 72,  protein: 6,  fiber: 0,  isLocked: false),
            MealItem(name: "Greek yogurt 0% fat 150g",
                     quantity: "150g",
                     calories: 90,  protein: 15, fiber: 0,  isLocked: false),
            MealItem(name: "Curry base",
                     quantity: "onion + tomato + 1 tsp oil + spices",
                     calories: 90,  protein: 2,  fiber: 2,  isLocked: false,
                     note: "1 tsp oil only — measure it, do not eyeball."),
            MealItem(name: "Rajma 175g cooked",
                     quantity: "175g cooked",
                     calories: 231, protein: 12, fiber: 10, isLocked: false),
            MealItem(name: "Basmati rice 100g cooked",
                     quantity: "100g cooked",
                     calories: 130, protein: 3,  fiber: 0,  isLocked: false),
            MealItem(name: "Pear 1 medium",
                     quantity: "1 medium",
                     calories: 74,  protein: 1,  fiber: 4,  isLocked: false),
        ], tip: "Reheat Tuesday's rajma batch. Marinate chicken overnight in yogurt + spices for deeper flavour with zero extra calories."),

        // DAY 5 — Friday (CHOLE)
        // 206+120+359+363+90+90+263+130+68 = 1689 kcal | 149g P | 39g F
        MealDay(dayNumber: 5, dayName: "Friday", title: "Chicken Chole One-Pot Curry", items: [
            MealItem(name: "Rolled oats 40g + chia seeds 1 tbsp + water",
                     quantity: "1 bowl",
                     calories: 206, protein: 7,  fiber: 9,  isLocked: true,
                     note: "Prep the night before. Eat within your 1–3 PM meal window."),
            MealItem(name: "Aldi California Medley 340g bag, steamed",
                     quantity: "340g steamed",
                     calories: 120, protein: 8,  fiber: 12, isLocked: true),
            MealItem(name: "Whey protein + Lactaid 250ml + 1 banana blended",
                     quantity: "1 scoop + 250ml + 1 banana",
                     calories: 359, protein: 34, fiber: 3,  isLocked: true,
                     note: "Blend together. Have within meal window or post-gym."),
            MealItem(name: "Chicken breast 220g cooked",
                     quantity: "220g cooked, cubed into chole",
                     calories: 363, protein: 68, fiber: 0,  isLocked: false),
            MealItem(name: "Greek yogurt 0% fat 150g",
                     quantity: "150g",
                     calories: 90,  protein: 15, fiber: 0,  isLocked: false),
            MealItem(name: "Curry base",
                     quantity: "onion + tomato + 1 tsp oil + spices",
                     calories: 90,  protein: 2,  fiber: 2,  isLocked: false,
                     note: "1 tsp oil only — measure it, do not eyeball."),
            MealItem(name: "Chole 160g cooked",
                     quantity: "160g cooked",
                     calories: 263, protein: 12, fiber: 10, isLocked: false),
            MealItem(name: "Basmati rice 100g cooked",
                     quantity: "100g cooked",
                     calories: 130, protein: 3,  fiber: 0,  isLocked: false),
            MealItem(name: "Apple 1 medium",
                     quantity: "1 medium",
                     calories: 68,  protein: 0,  fiber: 3,  isLocked: false),
        ], tip: "Cube chicken directly into the chole — one pot, saves dishes, chicken absorbs the masala. Last of the chole batch. Soak fresh chole tonight for Sunday."),

        // DAY 6 — Saturday (RAJMA + EGG)
        // 206+120+359+363+72+90+90+231+130+74 = 1735 kcal | 156g P | 40g F
        MealDay(dayNumber: 6, dayName: "Saturday", title: "Chicken Rajma Chawal", items: [
            MealItem(name: "Rolled oats 40g + chia seeds 1 tbsp + water",
                     quantity: "1 bowl",
                     calories: 206, protein: 7,  fiber: 9,  isLocked: true,
                     note: "Prep the night before. Eat within your 1–3 PM meal window."),
            MealItem(name: "Aldi California Medley 340g bag, steamed",
                     quantity: "340g steamed",
                     calories: 120, protein: 8,  fiber: 12, isLocked: true),
            MealItem(name: "Whey protein + Lactaid 250ml + 1 banana blended",
                     quantity: "1 scoop + 250ml + 1 banana",
                     calories: 359, protein: 34, fiber: 3,  isLocked: true,
                     note: "Blend together. Have within meal window or post-gym."),
            MealItem(name: "Chicken breast 220g cooked",
                     quantity: "220g cooked",
                     calories: 363, protein: 68, fiber: 0,  isLocked: false),
            MealItem(name: "Egg 1 boiled",
                     quantity: "1 boiled",
                     calories: 72,  protein: 6,  fiber: 0,  isLocked: false),
            MealItem(name: "Greek yogurt 0% fat 150g",
                     quantity: "150g",
                     calories: 90,  protein: 15, fiber: 0,  isLocked: false),
            MealItem(name: "Curry base",
                     quantity: "onion + tomato + 1 tsp oil + spices",
                     calories: 90,  protein: 2,  fiber: 2,  isLocked: false,
                     note: "1 tsp oil only — measure it, do not eyeball."),
            MealItem(name: "Rajma 175g cooked",
                     quantity: "175g cooked",
                     calories: 231, protein: 12, fiber: 10, isLocked: false),
            MealItem(name: "Basmati rice 100g cooked",
                     quantity: "100g cooked",
                     calories: 130, protein: 3,  fiber: 0,  isLocked: false),
            MealItem(name: "Pear 1 medium",
                     quantity: "1 medium",
                     calories: 74,  protein: 1,  fiber: 4,  isLocked: false),
        ], tip: "Batch cook day — pressure cook fresh rajma for next week's Tue + Thu + Sat. Also cook the soaked chole for Sun + next Mon."),

        // DAY 7 — Sunday (CHOLE)
        // 206+120+359+363+90+90+263+130+68 = 1689 kcal | 149g P | 39g F
        MealDay(dayNumber: 7, dayName: "Sunday", title: "Chole Chicken Plate", items: [
            MealItem(name: "Rolled oats 40g + chia seeds 1 tbsp + water",
                     quantity: "1 bowl",
                     calories: 206, protein: 7,  fiber: 9,  isLocked: true,
                     note: "Prep the night before. Eat within your 1–3 PM meal window."),
            MealItem(name: "Aldi California Medley 340g bag, steamed",
                     quantity: "340g steamed",
                     calories: 120, protein: 8,  fiber: 12, isLocked: true),
            MealItem(name: "Whey protein + Lactaid 250ml + 1 banana blended",
                     quantity: "1 scoop + 250ml + 1 banana",
                     calories: 359, protein: 34, fiber: 3,  isLocked: true,
                     note: "Blend together. Have within meal window or post-gym."),
            MealItem(name: "Chicken breast 220g cooked",
                     quantity: "220g cooked",
                     calories: 363, protein: 68, fiber: 0,  isLocked: false),
            MealItem(name: "Greek yogurt 0% fat 150g",
                     quantity: "150g (or cottage cheese 80g)",
                     calories: 90,  protein: 15, fiber: 0,  isLocked: false),
            MealItem(name: "Curry base",
                     quantity: "onion + tomato + 1 tsp oil + spices",
                     calories: 90,  protein: 2,  fiber: 2,  isLocked: false,
                     note: "1 tsp oil only — measure it, do not eyeball."),
            MealItem(name: "Chole 160g cooked",
                     quantity: "160g cooked",
                     calories: 263, protein: 12, fiber: 10, isLocked: false),
            MealItem(name: "Basmati rice 100g cooked",
                     quantity: "100g cooked",
                     calories: 130, protein: 3,  fiber: 0,  isLocked: false),
            MealItem(name: "Apple 1 medium",
                     quantity: "1 medium",
                     calories: 68,  protein: 0,  fiber: 3,  isLocked: false),
        ], tip: "No chicken? Use 5–6 eggs as bhurji (1 tsp oil + onion + tomato + spices). Tonight: prep oats for Monday and soak chole for next week."),
    ]

    /// Returns MealDay for today's weekday (0=Mon, 6=Sun)
    static func todaysMealDay() -> MealDay {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let dayIndex = (weekday + 5) % 7
        return allDays[dayIndex]
    }

    /// Returns MealDay for a given 0-based weekday index (0=Mon, 6=Sun)
    static func mealDay(for weekdayIndex: Int) -> MealDay {
        return allDays[weekdayIndex % 7]
    }
}
