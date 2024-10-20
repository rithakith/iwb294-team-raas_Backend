import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type Recipe record {
    int recipe_id;
    string title;
    string description;

    int cook_time;

    string author;
    json ingredients;
    json steps;
    json nutrition;
    json tags;
    json allergies;
    json images;
    json ratings;
    string date_added;
};

public function recipes() returns error? {

    // check createUserDatabase();
    // check createAndPopulateUsersTable();
    check createAndPopulateRecipesTable();
}

function createAndPopulateRecipesTable() returns error? {
    mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = "UserDB");

    _ = check dbClient->execute(`DROP TABLE IF EXISTS Recipes`);

    _ = check dbClient->execute(`
        CREATE TABLE Recipes (
            recipe_id INT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            cook_time INT,
            author VARCHAR(255),
            ingredients JSON,
            steps JSON,
            nutrition JSON,
            tags JSON,
            allergies JSON,
            images JSON,
            ratings JSON,
            date_added DATE
        )
    `);
    io:println("Recipes table created successfully.");

    Recipe[] recipes = [
        {
            recipe_id: 1,
            title: "Vegetarian Pasta",
            description: "A delicious and easy-to-make vegetarian pasta.",
            cook_time: 20,
            author: "Chef Alex",
            ingredients: [
                {name: "Pasta", quantity: 200, unit: "g"},
                {name: "Olive oil", quantity: 2, unit: "tbsp"},
                {name: "Garlic", quantity: 2, unit: "cloves", preparation: "minced"},
                {name: "Tomato sauce", quantity: 400, unit: "ml"},
                {name: "Zucchini", quantity: 1, unit: "medium", preparation: "chopped"},
                {name: "Bell pepper", quantity: 1, unit: "medium", preparation: "chopped"}
            ],
            steps: [
                "Cook the pasta according to package instructions.",
                "Heat olive oil and sauté garlic until fragrant.",
                "Add zucchini and bell pepper, cook until tender.",
                "Stir in tomato sauce, season, and simmer.",
                "Add pasta, toss to coat, and serve."
            ],
            nutrition: {calories: 350, protein: 10, carbohydrates: 60, fat: 8, fiber: 4, sugar: 7},
            tags: ["Vegetarian", "Pasta", "Dinner"],
            allergies: ["Gluten"],
            images: [{url: "https://images.immediate.co.uk/production/volatile/sites/2/2018/01/OLI0118-BumperHealthy-MushroomBolognese_020264-18d9123.jpg?quality=90&webp=true&resize=750,681", description: "Vegetarian pasta"}],
            ratings: {average_rating: 4.5, rating_count: 128},
            date_added: "2024-10-12"
        },
        {
            "recipe_id": 2,
            "title": "Chicken Stir-Fry",
            "description": "A quick and healthy chicken stir-fry with vegetables.",
            "cook_time": 30,
            "author": "Chef Jamie",
            "ingredients": [
                {"name": "Chicken breast", "quantity": 300, "unit": "g"},
                {"name": "Soy sauce", "quantity": 3, "unit": "tbsp"},
                {"name": "Broccoli", "quantity": 200, "unit": "g"},
                {"name": "Bell pepper", "quantity": 1, "unit": "medium", "preparation": "sliced"},
                {"name": "Carrot", "quantity": 1, "unit": "medium", "preparation": "sliced"},
                {"name": "Ginger", "quantity": 1, "unit": "inch", "preparation": "grated"}
            ],
            "steps": [
                "Cut chicken into bite-sized pieces.",
                "In a pan, heat oil and stir-fry chicken until cooked through.",
                "Add broccoli, bell pepper, and carrot, and stir-fry until tender.",
                "Stir in soy sauce and ginger, and cook for an additional 2 minutes.",
                "Serve with rice."
            ],
            "nutrition": {"calories": 450, "protein": 40, "carbohydrates": 50, "fat": 10, "fiber": 5, "sugar": 6},
            "tags": ["Chicken", "Stir-Fry", "Dinner"],
            "allergies": ["Soy"],
            "images": [{"url": "data:image/jpeg;base64,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", "description": "Chicken stir-fry"}],
            "ratings": {"average_rating": 4.7, "rating_count": 150},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 3,
            "title": "Beef Tacos",
            "description": "Flavorful beef tacos with fresh toppings.",
            "cook_time": 25,
            "author": "Chef Marco",
            "ingredients": [
                {"name": "Ground beef", "quantity": 400, "unit": "g"},
                {"name": "Taco shells", "quantity": 8, "unit": "pieces"},
                {"name": "Lettuce", "quantity": 100, "unit": "g", "preparation": "shredded"},
                {"name": "Tomato", "quantity": 2, "unit": "medium", "preparation": "diced"},
                {"name": "Cheddar cheese", "quantity": 100, "unit": "g", "preparation": "grated"},
                {"name": "Taco seasoning", "quantity": 1, "unit": "tbsp"}
            ],
            "steps": [
                "Brown the ground beef in a skillet.",
                "Add taco seasoning and a bit of water; simmer for 5 minutes.",
                "Fill taco shells with beef and top with lettuce, tomato, and cheese.",
                "Serve with salsa and sour cream."
            ],
            "nutrition": {"calories": 500, "protein": 30, "carbohydrates": 40, "fat": 25, "fiber": 4, "sugar": 3},
            "tags": ["Beef", "Tacos", "Dinner"],
            "allergies": ["Dairy", "Gluten"],
            "images": [{"url": "https://www.isabeleats.com/wp-content/uploads/2023/03/ground-beef-tacos-9.jpg", "description": "Beef tacos"}],
            "ratings": {"average_rating": 4.6, "rating_count": 200},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 4,
            "title": "Mushroom Risotto",
            "description": "Creamy risotto with mushrooms and parmesan.",
            "cook_time": 40,
            "author": "Chef Sophie",
            "ingredients": [
                {"name": "Arborio rice", "quantity": 300, "unit": "g"},
                {"name": "Mushrooms", "quantity": 200, "unit": "g", "preparation": "sliced"},
                {"name": "Onion", "quantity": 1, "unit": "medium", "preparation": "chopped"},
                {"name": "Garlic", "quantity": 2, "unit": "cloves", "preparation": "minced"},
                {"name": "Vegetable broth", "quantity": 1, "unit": "liter"},
                {"name": "Parmesan cheese", "quantity": 50, "unit": "g", "preparation": "grated"}
            ],
            "steps": [
                "Sauté onion and garlic in a pan until translucent.",
                "Add mushrooms and cook until soft.",
                "Stir in Arborio rice and cook for 1 minute.",
                "Gradually add broth, stirring constantly until absorbed.",
                "Finish with parmesan cheese and serve."
            ],
            "nutrition": {"calories": 400, "protein": 12, "carbohydrates": 60, "fat": 15, "fiber": 3, "sugar": 1},
            "tags": ["Vegetarian", "Risotto", "Dinner"],
            "allergies": ["Dairy"],
            "images": [{"url": "https://cocoandcamellia.com/wp-content/uploads/2021/05/Mushroom-Risotto-Recipe-4.jpg", "description": "Mushroom risotto"}],
            "ratings": {"average_rating": 4.8, "rating_count": 95},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 5,
            "title": "Shrimp Fried Rice",
            "description": "A tasty fried rice dish with shrimp and vegetables.",
            "cook_time": 25,
            "author": "Chef Lucy",
            "ingredients": [
                {"name": "Shrimp", "quantity": 300, "unit": "g", "preparation": "peeled and deveined"},
                {"name": "Rice", "quantity": 400, "unit": "g", "preparation": "cooked"},
                {"name": "Green peas", "quantity": 100, "unit": "g"},
                {"name": "Carrot", "quantity": 1, "unit": "medium", "preparation": "diced"},
                {"name": "Egg", "quantity": 2, "unit": "pieces"},
                {"name": "Soy sauce", "quantity": 2, "unit": "tbsp"}
            ],
            "steps": [
                "In a pan, scramble eggs and set aside.",
                "Sauté shrimp until pink, then add carrots and peas.",
                "Stir in cooked rice and soy sauce.",
                "Add scrambled eggs and mix well before serving."
            ],
            "nutrition": {"calories": 500, "protein": 30, "carbohydrates": 60, "fat": 15, "fiber": 5, "sugar": 3},
            "tags": ["Shrimp", "Fried Rice", "Dinner"],
            "allergies": ["Shellfish", "Soy"],
            "images": [{"url": "https://30minutesmeals.com/wp-content/uploads/2019/12/Shrimp-Fried-Rice-Recipe-3-640x949.jpg", "description": "Shrimp fried rice"}],
            "ratings": {"average_rating": 4.5, "rating_count": 120},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 6,
            "title": "Quinoa Salad",
            "description": "A refreshing quinoa salad with vegetables.",
            "cook_time": 15,
            "author": "Chef Mia",
            "ingredients": [
                {"name": "Quinoa", "quantity": 200, "unit": "g"},
                {"name": "Cucumber", "quantity": 1, "unit": "medium", "preparation": "diced"},
                {"name": "Cherry tomatoes", "quantity": 150, "unit": "g", "preparation": "halved"},
                {"name": "Feta cheese", "quantity": 100, "unit": "g", "preparation": "crumbled"},
                {"name": "Olive oil", "quantity": 3, "unit": "tbsp"},
                {"name": "Lemon juice", "quantity": 2, "unit": "tbsp"}
            ],
            "steps": [
                "Cook quinoa according to package instructions and let it cool.",
                "In a bowl, combine quinoa, cucumber, tomatoes, and feta.",
                "Drizzle with olive oil and lemon juice, and toss to combine.",
                "Serve chilled or at room temperature."
            ],
            "nutrition": {"calories": 300, "protein": 10, "carbohydrates": 40, "fat": 12, "fiber": 5, "sugar": 4},
            "tags": ["Vegetarian", "Salad", "Lunch"],
            "allergies": ["Dairy"],
            "images": [{"url": "https://www.chelseasmessyapron.com/wp-content/uploads/2017/05/Quinoa-Avocado-Power-Salad2.jpg", "description": "Quinoa salad"}],
            "ratings": {"average_rating": 4.9, "rating_count": 70},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 7,
            "title": "Pumpkin Soup",
            "description": "A creamy and comforting pumpkin soup.",
            "cook_time": 35,
            "author": "Chef Nora",
            "ingredients": [
                {"name": "Pumpkin", "quantity": 500, "unit": "g", "preparation": "peeled and cubed"},
                {"name": "Onion", "quantity": 1, "unit": "medium", "preparation": "chopped"},
                {"name": "Garlic", "quantity": 2, "unit": "cloves", "preparation": "minced"},
                {"name": "Vegetable broth", "quantity": 1, "unit": "liter"},
                {"name": "Cream", "quantity": 100, "unit": "ml"},
                {"name": "Nutmeg", "quantity": 1, "unit": "tsp"}
            ],
            "steps": [
                "Sauté onion and garlic until soft.",
                "Add pumpkin and vegetable broth; simmer until pumpkin is tender.",
                "Blend the mixture until smooth, then stir in cream and nutmeg.",
                "Serve hot."
            ],
            "nutrition": {"calories": 250, "protein": 4, "carbohydrates": 30, "fat": 12, "fiber": 5, "sugar": 6},
            "tags": ["Vegetarian", "Soup", "Appetizer"],
            "allergies": ["Dairy"],
            "images": [{"url": "https://simple-veganista.com/wp-content/uploads/2019/10/healthy-vegan-pumpkin-soup-recipe-2.jpg", "description": "Pumpkin soup"}],
            "ratings": {"average_rating": 4.4, "rating_count": 60},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 8,
            "title": "Chocolate Chip Cookies",
            "description": "Classic chocolate chip cookies for dessert.",
            "cook_time": 20,
            "author": "Chef Emily",
            "ingredients": [
                {"name": "All-purpose flour", "quantity": 250, "unit": "g"},
                {"name": "Butter", "quantity": 125, "unit": "g", "preparation": "softened"},
                {"name": "Brown sugar", "quantity": 100, "unit": "g"},
                {"name": "Granulated sugar", "quantity": 50, "unit": "g"},
                {"name": "Egg", "quantity": 1, "unit": "pieces"},
                {"name": "Chocolate chips", "quantity": 150, "unit": "g"},
                {"name": "Vanilla extract", "quantity": 1, "unit": "tsp"},
                {"name": "Baking soda", "quantity": 1, "unit": "tsp"}
            ],
            "steps": [
                "Preheat oven to 180°C (350°F).",
                "In a bowl, cream together butter and sugars.",
                "Add egg and vanilla; mix well.",
                "Stir in flour and baking soda, then fold in chocolate chips.",
                "Drop spoonfuls onto a baking sheet and bake for 10-12 minutes."
            ],
            "nutrition": {"calories": 200, "protein": 2, "carbohydrates": 30, "fat": 10, "fiber": 1, "sugar": 15},
            "tags": ["Dessert", "Cookies"],
            "allergies": ["Gluten", "Dairy"],
            "images": [{"url": "https://www.recipetineats.com/tachyon/2017/06/Soft-Chocolate-Chip-Cookies-3.jpg", "description": "Chocolate chip cookies"}],
            "ratings": {"average_rating": 4.8, "rating_count": 300},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 9,
            "title": "Lentil Soup",
            "description": "A hearty and nutritious lentil soup.",
            "cook_time": 40,
            "author": "Chef Clara",
            "ingredients": [
                {"name": "Lentils", "quantity": 200, "unit": "g"},
                {"name": "Carrot", "quantity": 2, "unit": "medium", "preparation": "diced"},
                {"name": "Celery", "quantity": 2, "unit": "stalks", "preparation": "diced"},
                {"name": "Onion", "quantity": 1, "unit": "medium", "preparation": "chopped"},
                {"name": "Vegetable broth", "quantity": 1, "unit": "liter"},
                {"name": "Thyme", "quantity": 1, "unit": "tsp"}
            ],
            "steps": [
                "Sauté onion, carrot, and celery until soft.",
                "Add lentils, broth, and thyme; bring to a boil.",
                "Reduce heat and simmer until lentils are tender.",
                "Blend if desired, then serve hot."
            ],
            "nutrition": {"calories": 300, "protein": 15, "carbohydrates": 45, "fat": 3, "fiber": 12, "sugar": 5},
            "tags": ["Vegetarian", "Soup", "Lunch"],
            "allergies": [],
            "images": [{"url": "https://www.unicornsinthekitchen.com/wp-content/uploads/2021/09/Mediterranean-Lentil-Soup-5.1200px.jpg", "description": "Lentil soup"}],
            "ratings": {"average_rating": 4.5, "rating_count": 85},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 10,
            "title": "Grilled Salmon",
            "description": "Perfectly grilled salmon with lemon and herbs.",
            "cook_time": 20,
            "author": "Chef Paul",
            "ingredients": [
                {"name": "Salmon fillet", "quantity": 300, "unit": "g"},
                {"name": "Lemon", "quantity": 1, "unit": "pieces", "preparation": "juiced"},
                {"name": "Olive oil", "quantity": 2, "unit": "tbsp"},
                {"name": "Garlic", "quantity": 2, "unit": "cloves", "preparation": "minced"},
                {"name": "Dill", "quantity": 1, "unit": "tbsp", "preparation": "chopped"},
                {"name": "Salt", "quantity": 1, "unit": "tsp"}
            ],
            "steps": [
                "Marinate salmon with lemon juice, olive oil, garlic, dill, and salt for 15 minutes.",
                "Preheat grill and cook salmon for 5-7 minutes on each side.",
                "Serve with a side of vegetables or salad."
            ],
            "nutrition": {"calories": 350, "protein": 40, "carbohydrates": 0, "fat": 20, "fiber": 0, "sugar": 0},
            "tags": ["Fish", "Grilled", "Dinner"],
            "allergies": ["Fish"],
            "images": [{"url": "https://www.thecookierookie.com/wp-content/uploads/2023/05/grilled-salmon-recipe-2.jpg", "description": "Grilled salmon"}],
            "ratings": {"average_rating": 4.7, "rating_count": 75},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 11,
            "title": "Caesar Salad",
            "description": "A classic Caesar salad with homemade dressing.",
            "cook_time": 15,
            "author": "Chef Lisa",
            "ingredients": [
                {"name": "Romaine lettuce", "quantity": 200, "unit": "g", "preparation": "chopped"},
                {"name": "Croutons", "quantity": 100, "unit": "g"},
                {"name": "Parmesan cheese", "quantity": 50, "unit": "g", "preparation": "shaved"},
                {"name": "Caesar dressing", "quantity": 50, "unit": "ml"},
                {"name": "Lemon juice", "quantity": 1, "unit": "tbsp"},
                {"name": "Black pepper", "quantity": 1, "unit": "tsp"}
            ],
            "steps": [
                "In a large bowl, combine lettuce, croutons, and Parmesan.",
                "Drizzle with Caesar dressing and lemon juice.",
                "Toss well to coat and sprinkle with black pepper before serving."
            ],
            "nutrition": {"calories": 200, "protein": 5, "carbohydrates": 15, "fat": 15, "fiber": 3, "sugar": 2},
            "tags": ["Salad", "Appetizer"],
            "allergies": ["Dairy", "Gluten"],
            "images": [{"url": "https://www.joyfulhealthyeats.com/wp-content/uploads/2022/04/Classic-Caesar-Salad-with-Homemade-Croutons-web-4.jpg", "description": "Caesar salad"}],
            "ratings": {"average_rating": 4.6, "rating_count": 90},
            "date_added": "2024-10-12"
        },
        {
            "recipe_id": 12,
            "title": "Stuffed Bell Peppers",
            "description": "Bell peppers stuffed with a savory rice and veggie filling.",
            "cook_time": 45,
            "author": "Chef Emma",
            "ingredients": [
                {"name": "Bell peppers", "quantity": 4, "unit": "pieces", "preparation": "halved and seeds removed"},
                {"name": "Rice", "quantity": 200, "unit": "g", "preparation": "cooked"},
                {"name": "Black beans", "quantity": 200, "unit": "g", "preparation": "cooked"},
                {"name": "Corn", "quantity": 100, "unit": "g"},
                {"name": "Cumin", "quantity": 1, "unit": "tsp"},
                {"name": "Cheddar cheese", "quantity": 100, "unit": "g", "preparation": "grated"}
            ],
            "steps": [
                "Preheat oven to 190°C (375°F).",
                "In a bowl, mix rice, black beans, corn, cumin, and half the cheese.",
                "Stuff the bell peppers with the mixture and place them in a baking dish.",
                "Sprinkle the remaining cheese on top and bake for 30 minutes."
            ],
            "nutrition": {"calories": 350, "protein": 12, "carbohydrates": 50, "fat": 10, "fiber": 7, "sugar": 5},
            "tags": ["Vegetarian", "Dinner"],
            "allergies": ["Dairy"],
            "images": [{"url": "https://saltedmint.com/wp-content/uploads/2024/01/Easy-Stuffed-bell-peppers-with-rice-2.jpg", "description": "Stuffed bell peppers"}],
            "ratings": {"average_rating": 4.8, "rating_count": 110},
            "date_added": "2024-10-12"
        }
        // Add more recipes as needed...
    ];

    sql:ParameterizedQuery[] insertQueries =
        from var recipe in recipes
    select `
            INSERT INTO Recipes
                (recipe_id, title, description, cook_time,author, ingredients, steps, nutrition, tags, allergies, images, ratings, date_added)
            VALUES
                (${recipe.recipe_id}, ${recipe.title}, ${recipe.description},  ${recipe.cook_time}, ${recipe.author}, ${recipe.ingredients.toJsonString()}, ${recipe.steps.toJsonString()}, ${recipe.nutrition.toJsonString()}, ${recipe.tags.toJsonString()}, ${recipe.allergies.toJsonString()}, ${recipe.images.toJsonString()}, ${recipe.ratings.toJsonString()}, ${recipe.date_added})
        `;

    _ = check dbClient->batchExecute(insertQueries);
    io:println("Recipe data inserted successfully.");
}
