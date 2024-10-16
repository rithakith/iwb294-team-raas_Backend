import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;

type Health_goals record {
    int weight_goal;
    int calorie_limit;
    string diet_type;
};

type User record {|
    int? user_id = ();
    string user_name;
    string email;
    string sub;
    json? user_allergies = ();
    json? dietary_preferences = ();
    json? health_goals = ();
    json? current_ingredients = ();
    json? favorited_recipes = ();
|};

public function main() returns error? {
    check createUserDatabase();
    check createAndPopulateUsersTable();
    check recipes();
}

function createUserDatabase() returns error?{
    mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT);
    _ = check dbClient->execute(`DROP DATABASE IF EXISTS UserDB`);
    _ = check dbClient->execute(`CREATE DATABASE UserDB`);
}

function createAndPopulateUsersTable() returns error? {
    mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = "UserDB");
    _ = check dbClient->execute(`DROP TABLE IF EXISTS Users`);

    _ = check dbClient->execute(`
      CREATE TABLE Users (
        user_id INT PRIMARY KEY AUTO_INCREMENT,
        user_name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        sub VARCHAR(255) NOT NULL,
        user_allergies JSON,
        health_goals JSON,
        dietary_preferences JSON,
        current_ingredients JSON,
        favorited_recipes JSON
      );
    `);

    User[] users = [
        {
            "user_name": "Rithara Kithmanthie",
            "email": "ritharaedirisinghe@gmail.com",
            "sub": "140ff87f-d905-475a-a932-fa9b28bf9341",
            "user_allergies": ["Peanuts", "Dairy"],
            "dietary_preferences": ["Vegetarian", "Low Sugar"],
            "health_goals": {
                "weight_goal": 60,
                "calorie_limit": 2000,
                "diet_type": "Vegetarian"
            },
            "current_ingredients": ["Broccoli", "Carrots", "Tofu"],
            "favorited_recipes": [101, 102, 103]
        },
        {
            "user_name": "Aiden Smith",
            "email": "fdkjfkd@gmail.com",
            "sub": "240ff87f-d905-475a-a932-fa9b28bf9342",
            "user_allergies": ["Shellfish", "Gluten"],
            "dietary_preferences": ["Low Carb", "High Protein"],
            "health_goals": {
                "weight_goal": 75,
                "calorie_limit": 2500,
                "diet_type": "Low Carb"
            },
            "current_ingredients": ["Chicken", "Spinach", "Quinoa"],
            "favorited_recipes": [201, 202, 203]
        },
        {
            "user_name": "Sophie Lee",
            "email": "sophie@gmail.com",
            "sub": "340ff87f-d905-475a-a932-fa9b28bf9343",
            "user_allergies": ["Soy"],
            "dietary_preferences": ["Gluten Free", "Vegan"],
            "health_goals": {
                "weight_goal": 55,
                "calorie_limit": 1800,
                "diet_type": "Keto"
            },
            "current_ingredients": ["Zucchini", "Bell Peppers", "Tempeh"],
            "favorited_recipes": [301, 302, 303]
        },
        {
            "user_name": "Liam Chen",
            "email": "liam@gmail.com",
            "sub": "440ff87f-d905-475a-a932-fa9b28bf9344",
            "user_allergies": ["Nuts", "Eggs"],
            "dietary_preferences": ["Dairy Free", "Paleo"],
            "health_goals": {
                "weight_goal": 68,
                "calorie_limit": 2200,
                "diet_type": "Paleo"
            },
            "current_ingredients": ["Beef", "Sweet Potatoes", "Kale"],
            "favorited_recipes": [401, 402, 403]
        }
    ];

sql:ParameterizedQuery[] insertQueries =
    from var user in users
    select `
        INSERT INTO Users
            (user_name, email, sub, user_allergies, dietary_preferences, health_goals, current_ingredients, favorited_recipes)
        VALUES
            (${user.user_name}, 
             ${user.email}, 
             ${user.sub},
             ${user.user_allergies.toJsonString()}, 
             ${user.dietary_preferences.toJsonString()},
             ${user.health_goals.toJsonString()}, 
             ${user.current_ingredients.toJsonString()},
             ${user.favorited_recipes.toJsonString()})
    `;





    _ = check dbClient->batchExecute(insertQueries);
}
