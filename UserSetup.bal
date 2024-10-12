
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

type User record {
    int user_id;
    string user_name;
    string email;
    json user_allergies;
    json health_goals;
    json favorited_recipes;
};






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
    user_allergies JSON,
    health_goals JSON,
    favorited_recipes JSON
);

    `);

    User[] users = [
    {
        "user_id": 1,
        "user_name": "Rithara Kithmanthie",
        "email":"ritharaedirisinghe@gmail.com",
        "user_allergies": ["Peanuts", "Dairy"],
        "health_goals": {
            "weight_goal": 60,
            "calorie_limit": 2000,
            "diet_type": "Vegetarian"
        },
        "favorited_recipes": [101, 102, 103]
    },
    {
        "user_id": 2,
        "user_name": "Aiden Smith",
        "email":"fdkjfkd@gmail.com",
        "user_allergies": ["Shellfish", "Gluten"],
        "health_goals": {
            "weight_goal": 75,
            "calorie_limit": 2500,
            "diet_type": "Low Carb"
        },
        "favorited_recipes": [201, 202, 203]
    },
    {
        "user_id": 3,
        "user_name": "Sophie Lee",
        "email":"sophie@gmail.com",
        "user_allergies": ["Soy"],
        "health_goals": {
            "weight_goal": 55,
            "calorie_limit": 1800,
            "diet_type": "Keto"
        },
        "favorited_recipes": [301, 302, 303]
    },
    {
        "user_id": 4,
        "user_name": "Liam Chen",
        "email":"liam@gmail.com",
        "user_allergies": ["Nuts", "Eggs"],
        "health_goals": {
            "weight_goal": 68,
            "calorie_limit": 2200,
            "diet_type": "Paleo"
        },
        "favorited_recipes": [401, 402, 403]
    }
];


    sql:ParameterizedQuery[] insertQueries =
        from var user in users
        select `
            INSERT INTO Users
                (user_id, user_name, email,user_allergies, health_goals, favorited_recipes)
            VALUES
                (${user.user_id}, ${user.user_name},${user.email}, ${user.user_allergies.toJsonString()}, ${user.health_goals.toJsonString()}, ${user.favorited_recipes.toJsonString()})
              
            `;

    _ = check dbClient->batchExecute(insertQueries);
}