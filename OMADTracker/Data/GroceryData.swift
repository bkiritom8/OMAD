import Foundation

struct GroceryItem: Identifiable {
    let id: String  // stable key for UserDefaults
    let name: String
    let quantity: String
}

struct GrocerySection: Identifiable {
    let id: String
    let title: String
    let items: [GroceryItem]
}

enum GroceryData {
    static let sections: [GrocerySection] = [
        GrocerySection(id: "always_in", title: "Every Day — Never Run Out", items: [
            GroceryItem(id: "aldi_medley",    name: "Aldi California Medley", quantity: "7 bags (340g each)"),
            GroceryItem(id: "whey_protein",   name: "Whey Protein Powder",    quantity: "7 scoops"),
            GroceryItem(id: "lactaid_milk",   name: "Lactaid Milk",           quantity: "1.75L (250ml/day for shake)"),
            GroceryItem(id: "bananas",        name: "Bananas",                quantity: "7 (1/day in shake)"),
            GroceryItem(id: "rolled_oats",    name: "Rolled Oats",            quantity: "280g (40g/day)"),
            GroceryItem(id: "chia_seeds",     name: "Chia Seeds",             quantity: "84g (1 tbsp = 12g/day)"),
        ]),
        GrocerySection(id: "protein", title: "Protein", items: [
            GroceryItem(id: "chicken_breast", name: "Chicken Breast",         quantity: "~1.75kg (~270g raw per day)"),
            GroceryItem(id: "eggs",           name: "Eggs",                   quantity: "1 dozen (Tue + Thu + Sat + backup)"),
        ]),
        GrocerySection(id: "dairy", title: "Dairy", items: [
            GroceryItem(id: "greek_yogurt",   name: "Greek Yogurt 0% Fat",    quantity: "~1.1kg (150g/day)"),
            GroceryItem(id: "cottage_cheese", name: "Cottage Cheese",         quantity: "~160g (Sunday backup only)"),
        ]),
        GrocerySection(id: "legumes", title: "Legumes", items: [
            GroceryItem(id: "chole_chickpeas", name: "Chole / Chickpeas",     quantity: "~640g cooked (Mon + Wed + Fri + Sun)"),
            GroceryItem(id: "rajma_kidney",    name: "Rajma / Kidney Beans",  quantity: "~525g cooked (Tue + Thu + Sat)"),
        ]),
        GrocerySection(id: "carbs", title: "Carbs", items: [
            GroceryItem(id: "basmati_rice",   name: "Basmati Rice",           quantity: "~245g dry (cooks to 100g/day)"),
        ]),
        GrocerySection(id: "curry_base", title: "Curry Base", items: [
            GroceryItem(id: "onions",         name: "Onions",                 quantity: "7 medium"),
            GroceryItem(id: "tomatoes",       name: "Tomatoes",               quantity: "7–10"),
            GroceryItem(id: "garlic",         name: "Garlic",                 quantity: "1 head"),
            GroceryItem(id: "ginger",         name: "Ginger",                 quantity: "small knob"),
            GroceryItem(id: "green_chillies", name: "Green Chillies",         quantity: "small pack"),
            GroceryItem(id: "cooking_oil",    name: "Oil (any neutral)",       quantity: "small bottle — 1 tsp/day only"),
        ]),
        GrocerySection(id: "spices", title: "Spices (pantry — top up if low)", items: [
            GroceryItem(id: "cumin",          name: "Cumin Seeds",            quantity: "top up if low"),
            GroceryItem(id: "turmeric",       name: "Turmeric Powder",        quantity: "top up if low"),
            GroceryItem(id: "coriander",      name: "Coriander Powder",       quantity: "top up if low"),
            GroceryItem(id: "garam_masala",   name: "Garam Masala",           quantity: "top up if low"),
            GroceryItem(id: "chilli_powder",  name: "Red Chilli Powder",      quantity: "top up if low"),
            GroceryItem(id: "salt",           name: "Salt",                   quantity: "top up if low"),
        ]),
        GrocerySection(id: "fruit", title: "Fruit", items: [
            GroceryItem(id: "apples",         name: "Apples",                 quantity: "4 (Mon + Wed + Fri + Sun)"),
            GroceryItem(id: "pears",          name: "Pears",                  quantity: "3 (Tue + Thu + Sat)"),
        ]),
    ]

    static var allItemIDs: [String] {
        sections.flatMap { $0.items.map { $0.id } }
    }
}
