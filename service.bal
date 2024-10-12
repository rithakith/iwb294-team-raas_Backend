// import ballerina/time;
import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;


final mysql:Client userDbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT,
    database = "UserDB", connectionPool = {maxOpenConnections: 3, minIdleConnections: 1}
);

 service /api on new http:Listener(8083) {
   @http:ResourceConfig {
        cors: {
            allowOrigins: ["http://localhost:8081"], // Change to your frontend URL
            allowMethods: ["GET", "POST", "PUT", "DELETE"],
            allowHeaders: ["Authorization", "Content-Type"],
            exposeHeaders: [],
            allowCredentials: true,
            maxAge: 3600
        }
    }

    isolated resource function get recipes() returns Recipe[]|error? {
        Recipe[] recipes = [];
        stream<Recipe, error?> resultStream = userDbClient->query(`SELECT * FROM Recipes`);
        check from Recipe recipe in resultStream
            do {
                recipes.push(recipe);

            };
        check resultStream.close();
        return recipes;
    }




    isolated resource function get users() returns User[]|error? {
        User[] users = [];
        stream<User, error?> resultStream = userDbClient->query(`SELECT * FROM Users`);
        check from User user in resultStream
            do {
                users.push(user);

            };
        check resultStream.close();
        return users;
    }

    isolated resource function get [int id]() returns User|error? {
        User user = check userDbClient->queryRow(`SELECT * FROM Users WHERE user_id = ${id}`);
        return user;
    }

    isolated resource function post users(@http:Payload User user) returns string|int|error? {
        sql:ExecutionResult result = check userDbClient->execute(`
        INSERT INTO Users
  (user_id, user_name,email, user_allergies, health_goals, favorited_recipes)     
         VALUES
                (${user.user_id}, ${user.user_name},${user.email}, ${user.user_allergies.toJsonString()}, ${user.health_goals.toJsonString()}, ${user.favorited_recipes.toJsonString()})
              
            `);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            return lastInsertId;
        } else {
            return error("Unable to obtain last insert ID");
        }
    }

    isolated resource function put users(@http:Payload User user) returns int|error? {
        sql:ExecutionResult result = check userDbClient->execute(`
            UPDATE Users
            SET user_name = ${user.user_name},email=${user.email}, user_allergies = ${user.user_allergies.toJsonString()},  favorited_recipes=${user.favorited_recipes.toJsonString()}
             , health_goals = ${user.health_goals.toJsonString()}
            WHERE user_id = ${user.user_id}
        `);

        if result.affectedRowCount > 0 {
            return result.affectedRowCount; // Return the number of rows updated
        } else {
            return error("No rows updated");
        }
    }

    isolated resource function delete users/[int id]() returns int|error? {
        sql:ExecutionResult result = check userDbClient->execute(`DELETE FROM Users WHERE user_id = ${id}`);
        return result.affectedRowCount;
    }

    isolated resource function get users/count() returns int|error? {
        int count = check userDbClient->queryRow(`SELECT COUNT(*) FROM Users`);
        return count;
    }
}
    // isolated resource function get subordinates/[int id]() returns Employee[]|error? {
    //     Employee[] employees = [];
    //     stream<Employee, error?> resultStream = dbClient->query(`SELECT * FROM Employees WHERE manager_id = ${id}`);
    //     check from Employee employee in resultStream
    //         do {
    //             employees.push(employee);
    //         };
    //     check resultStream.close();
    //     return employees;
    // }

