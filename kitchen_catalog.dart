import '../models/pantry_item.dart';
import '../models/recipe.dart';

class KitchenCatalog {
  static List<PantryItem> starterPantry() => const [
        PantryItem(id: 'p1', name: 'Onion', emoji: '🧅', quantity: 4),
        PantryItem(id: 'p2', name: 'Tomato', emoji: '🍅', quantity: 6),
        PantryItem(id: 'p3', name: 'Potato', emoji: '🥔', quantity: 5),
        PantryItem(id: 'p4', name: 'Rice', emoji: '🍚', quantity: 1, unit: 'kg'),
        PantryItem(id: 'p5', name: 'Toor dal', emoji: '🫘', quantity: 1, unit: 'kg'),
        PantryItem(id: 'p6', name: 'Turmeric', emoji: '🌼', quantity: 1, unit: 'pack'),
        PantryItem(id: 'p7', name: 'Garlic', emoji: '🧄', quantity: 1, unit: 'bulb'),
        PantryItem(id: 'p8', name: 'Ginger', emoji: '🫚', quantity: 1, unit: 'knob'),
        PantryItem(id: 'p9', name: 'Green chilli', emoji: '🌶️', quantity: 8),
        PantryItem(id: 'p10', name: 'Oil', emoji: '🫙', quantity: 1, unit: 'L'),
        PantryItem(id: 'p11', name: 'Salt', emoji: '🧂', quantity: 1, unit: 'pack'),
      ];

  static List<PantryItem> scanFinds() => const [
        PantryItem(id: 'scan-paneer', name: 'Paneer', emoji: '🧀', quantity: 200, unit: 'g'),
        PantryItem(id: 'scan-capsicum', name: 'Capsicum', emoji: '🫑', quantity: 2),
        PantryItem(id: 'scan-curd', name: 'Curd', emoji: '🥛', quantity: 1, unit: 'cup'),
        PantryItem(id: 'scan-coriander', name: 'Coriander', emoji: '🌿', quantity: 1, unit: 'bunch'),
      ];

  static const recipes = <Recipe>[
    Recipe(
      id: 'r1',
      name: 'Aloo Tamatar Sabzi',
      tagline: 'Comforting dry sabzi for roti nights',
      emoji: '🥔',
      minutes: 25,
      ingredients: [
        RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '3'),
        RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '2'),
        RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
        RecipeIngredient(name: 'Turmeric', emoji: '🌼', amount: '1 tsp'),
        RecipeIngredient(name: 'Green chilli', emoji: '🌶️', amount: '2'),
        RecipeIngredient(name: 'Oil', emoji: '🫙', amount: '2 tbsp'),
      ],
    ),
    Recipe(
      id: 'r2',
      name: 'Dal Tadka',
      tagline: 'Smoky toor dal with garlic tadka',
      emoji: '🍲',
      minutes: 35,
      ingredients: [
        RecipeIngredient(name: 'Toor dal', emoji: '🫘', amount: '1 cup'),
        RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
        RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1'),
        RecipeIngredient(name: 'Garlic', emoji: '🧄', amount: '4 cloves'),
        RecipeIngredient(name: 'Turmeric', emoji: '🌼', amount: '1/2 tsp'),
        RecipeIngredient(name: 'Coriander', emoji: '🌿', amount: 'garnish'),
      ],
    ),
    Recipe(
      id: 'r3',
      name: 'Jeera Rice',
      tagline: 'Fluffy cumin rice for dal & sabzi',
      emoji: '🍚',
      minutes: 20,
      ingredients: [
        RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1 cup'),
        RecipeIngredient(name: 'Oil', emoji: '🫙', amount: '1 tbsp'),
        RecipeIngredient(name: 'Salt', emoji: '🧂', amount: 'to taste'),
      ],
    ),
    Recipe(
      id: 'r4',
      name: 'Paneer Butter Masala',
      tagline: 'Restaurant-style gravy for special evenings',
      emoji: '🍛',
      minutes: 40,
      spice: 'Mild',
      ingredients: [
        RecipeIngredient(name: 'Paneer', emoji: '🧀', amount: '200 g'),
        RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '4'),
        RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
        RecipeIngredient(name: 'Butter', emoji: '🧈', amount: '2 tbsp'),
        RecipeIngredient(name: 'Cream', emoji: '🥛', amount: '1/4 cup'),
        RecipeIngredient(name: 'Garlic', emoji: '🧄', amount: '4 cloves'),
        RecipeIngredient(name: 'Ginger', emoji: '🫚', amount: '1 inch'),
      ],
    ),
    Recipe(
      id: 'r5',
      name: 'Palak Paneer',
      tagline: 'Creamy spinach gravy with cubes of paneer',
      emoji: '🥬',
      minutes: 35,
      ingredients: [
        RecipeIngredient(name: 'Palak', emoji: '🥬', amount: '1 bunch'),
        RecipeIngredient(name: 'Paneer', emoji: '🧀', amount: '150 g'),
        RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
        RecipeIngredient(name: 'Garlic', emoji: '🧄', amount: '4 cloves'),
        RecipeIngredient(name: 'Ginger', emoji: '🫚', amount: '1 inch'),
        RecipeIngredient(name: 'Green chilli', emoji: '🌶️', amount: '2'),
      ],
    ),
    Recipe(
      id: 'r6',
      name: 'Veg Pulao',
      tagline: 'One-pot rice with pantry veg',
      emoji: '🥘',
      minutes: 30,
      ingredients: [
        RecipeIngredient(name: 'Rice', emoji: '🍚', amount: '1.5 cups'),
        RecipeIngredient(name: 'Potato', emoji: '🥔', amount: '1'),
        RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
        RecipeIngredient(name: 'Capsicum', emoji: '🫑', amount: '1'),
        RecipeIngredient(name: 'Green chilli', emoji: '🌶️', amount: '2'),
        RecipeIngredient(name: 'Oil', emoji: '🫙', amount: '2 tbsp'),
      ],
    ),
    Recipe(
      id: 'r7',
      name: 'Egg Bhurji',
      tagline: 'Spiced scrambled eggs in 10 minutes',
      emoji: '🍳',
      minutes: 12,
      spice: 'Hot',
      ingredients: [
        RecipeIngredient(name: 'Eggs', emoji: '🥚', amount: '3'),
        RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
        RecipeIngredient(name: 'Tomato', emoji: '🍅', amount: '1'),
        RecipeIngredient(name: 'Green chilli', emoji: '🌶️', amount: '2'),
        RecipeIngredient(name: 'Oil', emoji: '🫙', amount: '1 tbsp'),
      ],
    ),
    Recipe(
      id: 'r8',
      name: 'Kadhi Pakora',
      tagline: 'Tangy curd kadhi for a homely dinner',
      emoji: '🫕',
      minutes: 45,
      ingredients: [
        RecipeIngredient(name: 'Curd', emoji: '🥛', amount: '2 cups'),
        RecipeIngredient(name: 'Besan', emoji: '🌾', amount: '4 tbsp'),
        RecipeIngredient(name: 'Onion', emoji: '🧅', amount: '1'),
        RecipeIngredient(name: 'Turmeric', emoji: '🌼', amount: '1/2 tsp'),
        RecipeIngredient(name: 'Ginger', emoji: '🫚', amount: '1 inch'),
        RecipeIngredient(name: 'Green chilli', emoji: '🌶️', amount: '2'),
      ],
    ),
  ];
}
