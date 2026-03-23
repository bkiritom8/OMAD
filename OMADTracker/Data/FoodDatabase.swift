import Foundation

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let fiberPer100g: Double
    let category: String
    /// Unit shown by default when this food is selected (g / ml / pieces / cups)
    var defaultUnit: String = "g"
    /// Grams per piece — only used when unit is "pieces". Defaults to 100g.
    var gramsPerPiece: Double = 100.0
}

enum FoodDatabase {
    static let allFoods: [FoodItem] = [
        // Indian Grains & Breads
        FoodItem(name: "Basmati Rice (cooked)", caloriesPer100g: 130, proteinPer100g: 2.7, fiberPer100g: 0.4, category: "Grains"),
        FoodItem(name: "Brown Rice (cooked)", caloriesPer100g: 111, proteinPer100g: 2.6, fiberPer100g: 1.8, category: "Grains"),
        FoodItem(name: "Roti / Chapati", caloriesPer100g: 70, proteinPer100g: 2.0, fiberPer100g: 2.0, category: "Grains", defaultUnit: "pieces"),
        FoodItem(name: "Naan", caloriesPer100g: 310, proteinPer100g: 9.5, fiberPer100g: 1.9, category: "Grains"),
        FoodItem(name: "Paratha", caloriesPer100g: 326, proteinPer100g: 8.2, fiberPer100g: 2.4, category: "Grains"),

        // Dal & Legumes
        FoodItem(name: "Moong Dal (cooked)", caloriesPer100g: 105, proteinPer100g: 7.0, fiberPer100g: 1.9, category: "Legumes"),
        FoodItem(name: "Masoor Dal (cooked)", caloriesPer100g: 116, proteinPer100g: 9.0, fiberPer100g: 1.9, category: "Legumes"),
        FoodItem(name: "Chana Dal (cooked)", caloriesPer100g: 164, proteinPer100g: 9.0, fiberPer100g: 5.6, category: "Legumes"),
        FoodItem(name: "Rajma / Kidney Beans (cooked)", caloriesPer100g: 127, proteinPer100g: 8.7, fiberPer100g: 6.4, category: "Legumes"),
        FoodItem(name: "Chole / Chickpeas (cooked)", caloriesPer100g: 164, proteinPer100g: 8.9, fiberPer100g: 7.6, category: "Legumes"),
        FoodItem(name: "Lentils (cooked)", caloriesPer100g: 116, proteinPer100g: 9.0, fiberPer100g: 7.9, category: "Legumes"),
        FoodItem(name: "Black Beans (cooked)", caloriesPer100g: 132, proteinPer100g: 8.9, fiberPer100g: 8.7, category: "Legumes"),

        // Indian Dairy & Protein
        FoodItem(name: "Paneer", caloriesPer100g: 265, proteinPer100g: 18.3, fiberPer100g: 0.0, category: "Dairy"),
        FoodItem(name: "Curd / Dahi", caloriesPer100g: 98, proteinPer100g: 11.0, fiberPer100g: 0.0, category: "Dairy"),
        FoodItem(name: "Greek Yogurt 0% Fat", caloriesPer100g: 59, proteinPer100g: 10.0, fiberPer100g: 0.0, category: "Dairy"),
        FoodItem(name: "Whole Milk", caloriesPer100g: 61, proteinPer100g: 3.2, fiberPer100g: 0.0, category: "Dairy"),
        FoodItem(name: "Lactaid Milk", caloriesPer100g: 42, proteinPer100g: 3.3, fiberPer100g: 0.0, category: "Dairy"),
        FoodItem(name: "Cottage Cheese", caloriesPer100g: 98, proteinPer100g: 11.1, fiberPer100g: 0.0, category: "Dairy"),
        FoodItem(name: "Ghee", caloriesPer100g: 900, proteinPer100g: 0.0, fiberPer100g: 0.0, category: "Fats"),
        FoodItem(name: "Butter", caloriesPer100g: 717, proteinPer100g: 0.9, fiberPer100g: 0.0, category: "Fats"),

        // Meat & Eggs
        FoodItem(name: "Chicken Breast (cooked)", caloriesPer100g: 165, proteinPer100g: 31.0, fiberPer100g: 0.0, category: "Protein"),
        FoodItem(name: "Chicken Thigh (cooked)", caloriesPer100g: 209, proteinPer100g: 26.0, fiberPer100g: 0.0, category: "Protein"),
        FoodItem(name: "Egg (whole)", caloriesPer100g: 72,  proteinPer100g: 6.0,  fiberPer100g: 0.0, category: "Protein",      defaultUnit: "pieces"),
        FoodItem(name: "Egg White",   caloriesPer100g: 17,  proteinPer100g: 4.0,  fiberPer100g: 0.0, category: "Protein",      defaultUnit: "pieces"),
        FoodItem(name: "Tuna (canned, in water)", caloriesPer100g: 116, proteinPer100g: 26.0, fiberPer100g: 0.0, category: "Protein"),
        FoodItem(name: "Salmon (cooked)", caloriesPer100g: 208, proteinPer100g: 20.0, fiberPer100g: 0.0, category: "Protein"),

        // Indian Snacks & Street Food
        FoodItem(name: "Samosa", caloriesPer100g: 252, proteinPer100g: 4.0, fiberPer100g: 2.0, category: "Snacks",       defaultUnit: "pieces"),
        FoodItem(name: "Idli",   caloriesPer100g: 39,  proteinPer100g: 2.0, fiberPer100g: 0.0, category: "Indian Foods", defaultUnit: "pieces"),
        FoodItem(name: "Dosa (plain)", caloriesPer100g: 133, proteinPer100g: 4.0, fiberPer100g: 1.0, category: "Indian Foods"),
        FoodItem(name: "Upma", caloriesPer100g: 155, proteinPer100g: 3.0, fiberPer100g: 2.0, category: "Indian Foods"),
        FoodItem(name: "Poha", caloriesPer100g: 110, proteinPer100g: 2.5, fiberPer100g: 1.5, category: "Indian Foods"),
        FoodItem(name: "Khichdi", caloriesPer100g: 124, proteinPer100g: 4.8, fiberPer100g: 2.1, category: "Indian Foods"),
        FoodItem(name: "Biryani (chicken)", caloriesPer100g: 175, proteinPer100g: 9.0, fiberPer100g: 1.2, category: "Indian Foods"),

        // Fruits
        FoodItem(name: "Banana", caloriesPer100g: 89, proteinPer100g: 1.0, fiberPer100g: 3.0, category: "Fruits", defaultUnit: "pieces"),
        FoodItem(name: "Apple",  caloriesPer100g: 68, proteinPer100g: 0.0, fiberPer100g: 3.0, category: "Fruits", defaultUnit: "pieces"),
        FoodItem(name: "Mango",  caloriesPer100g: 60, proteinPer100g: 0.8, fiberPer100g: 1.6, category: "Fruits"),
        FoodItem(name: "Orange", caloriesPer100g: 72, proteinPer100g: 1.0, fiberPer100g: 4.0, category: "Fruits", defaultUnit: "pieces"),
        FoodItem(name: "Pear",   caloriesPer100g: 74, proteinPer100g: 1.0, fiberPer100g: 4.0, category: "Fruits", defaultUnit: "pieces"),
        FoodItem(name: "Grapes", caloriesPer100g: 69, proteinPer100g: 0.7, fiberPer100g: 0.9, category: "Fruits"),
        FoodItem(name: "Watermelon", caloriesPer100g: 30, proteinPer100g: 0.6, fiberPer100g: 0.4, category: "Fruits"),
        FoodItem(name: "Papaya", caloriesPer100g: 43, proteinPer100g: 0.5, fiberPer100g: 1.7, category: "Fruits"),
        FoodItem(name: "Strawberries", caloriesPer100g: 32, proteinPer100g: 0.7, fiberPer100g: 2.0, category: "Fruits"),
        FoodItem(name: "Blueberries", caloriesPer100g: 57, proteinPer100g: 0.7, fiberPer100g: 2.4, category: "Fruits"),

        // Everyday Foods
        FoodItem(name: "Oats (dry)", caloriesPer100g: 379, proteinPer100g: 13.2, fiberPer100g: 10.6, category: "Grains"),
        FoodItem(name: "Bread Slice (white)",       caloriesPer100g: 79,  proteinPer100g: 3.0,  fiberPer100g: 1.0, category: "Grains", defaultUnit: "pieces"),
        FoodItem(name: "Bread Slice (whole wheat)", caloriesPer100g: 81,  proteinPer100g: 4.0,  fiberPer100g: 2.0, category: "Grains", defaultUnit: "pieces"),
        FoodItem(name: "White Bread",               caloriesPer100g: 265, proteinPer100g: 9.0,  fiberPer100g: 2.7, category: "Grains"),
        FoodItem(name: "Whole Wheat Bread",         caloriesPer100g: 247, proteinPer100g: 13.0, fiberPer100g: 6.4, category: "Grains"),
        FoodItem(name: "Pasta (cooked)", caloriesPer100g: 131, proteinPer100g: 5.0, fiberPer100g: 1.8, category: "Grains"),
        FoodItem(name: "Quinoa (cooked)", caloriesPer100g: 120, proteinPer100g: 4.4, fiberPer100g: 2.8, category: "Grains"),

        // Protein Supplements
        FoodItem(name: "Whey Protein Powder", caloriesPer100g: 370, proteinPer100g: 80.0, fiberPer100g: 0.0, category: "Supplements"),
        FoodItem(name: "Protein Bar (avg)", caloriesPer100g: 400, proteinPer100g: 20.0, fiberPer100g: 5.0, category: "Supplements"),

        // Nuts & Seeds
        FoodItem(name: "Almonds", caloriesPer100g: 579, proteinPer100g: 21.2, fiberPer100g: 12.5, category: "Nuts"),
        FoodItem(name: "Peanuts", caloriesPer100g: 567, proteinPer100g: 25.8, fiberPer100g: 8.5, category: "Nuts"),
        FoodItem(name: "Peanut Butter", caloriesPer100g: 588, proteinPer100g: 25.0, fiberPer100g: 6.0, category: "Nuts"),
        FoodItem(name: "Cashews", caloriesPer100g: 553, proteinPer100g: 18.2, fiberPer100g: 3.3, category: "Nuts"),
        FoodItem(name: "Walnuts", caloriesPer100g: 654, proteinPer100g: 15.2, fiberPer100g: 6.7, category: "Nuts"),
        FoodItem(name: "Chia Seeds", caloriesPer100g: 486, proteinPer100g: 16.5, fiberPer100g: 34.4, category: "Seeds"),
        FoodItem(name: "Flaxseeds", caloriesPer100g: 534, proteinPer100g: 18.3, fiberPer100g: 27.3, category: "Seeds"),

        // Vegetables
        FoodItem(name: "Broccoli (raw)", caloriesPer100g: 34, proteinPer100g: 2.8, fiberPer100g: 2.6, category: "Vegetables"),
        FoodItem(name: "Spinach (raw)", caloriesPer100g: 23, proteinPer100g: 2.9, fiberPer100g: 2.2, category: "Vegetables"),
        FoodItem(name: "Potato (boiled)", caloriesPer100g: 86, proteinPer100g: 1.7, fiberPer100g: 1.8, category: "Vegetables"),
        FoodItem(name: "Sweet Potato (cooked)", caloriesPer100g: 90, proteinPer100g: 2.0, fiberPer100g: 3.3, category: "Vegetables"),
        FoodItem(name: "Carrot (raw)", caloriesPer100g: 41, proteinPer100g: 0.9, fiberPer100g: 2.8, category: "Vegetables"),
        FoodItem(name: "Tomato (raw)", caloriesPer100g: 18, proteinPer100g: 0.9, fiberPer100g: 1.2, category: "Vegetables"),
        FoodItem(name: "Onion (raw)", caloriesPer100g: 40, proteinPer100g: 1.1, fiberPer100g: 1.7, category: "Vegetables"),
        FoodItem(name: "Cucumber (raw)", caloriesPer100g: 15, proteinPer100g: 0.7, fiberPer100g: 0.5, category: "Vegetables"),

        // Oils & Condiments
        FoodItem(name: "Olive Oil", caloriesPer100g: 884, proteinPer100g: 0.0, fiberPer100g: 0.0, category: "Fats"),
        FoodItem(name: "Coconut Oil", caloriesPer100g: 862, proteinPer100g: 0.0, fiberPer100g: 0.0, category: "Fats"),
        FoodItem(name: "Vegetable Oil", caloriesPer100g: 884, proteinPer100g: 0.0, fiberPer100g: 0.0, category: "Fats"),
    ]

    static func search(_ query: String) -> [FoodItem] {
        guard !query.isEmpty else { return allFoods }
        return allFoods.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
