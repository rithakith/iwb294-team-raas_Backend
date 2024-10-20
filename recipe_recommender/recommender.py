import pandas as pd
import google.generativeai as genai
from dotenv import load_dotenv
import os

# Load the CSV file into a DataFrame
load_dotenv()

genai.configure(api_key=os.environ["API_KEY"])

model = genai.GenerativeModel("gemini-1.5-flash")

# Set your Google Drive file ID
file_id = '1LF1wBc2rgyx-z3F0GuEiiI0Jguf9M9qO'  # Replace with your actual FILE_ID
drive_link = f'https://drive.google.com/uc?id={file_id}'
df = pd.read_csv(drive_link, on_bad_lines='warn')  # Handle bad lines


def filter_recipes_by_ingredients(df, ingredients):
    df['ingredients'] = df['ingredients'].apply(lambda x: eval(x) if isinstance(x, str) else x)
    filtered_recipes = df[df['ingredients'].apply(lambda x: all(ingredient in x for ingredient in ingredients))]
    return filtered_recipes

def remove_allergy_ingredients(recipes_df, allergies):
    filtered_recipes = recipes_df[recipes_df['ingredients'].apply(lambda x: not any(allergy in x for allergy in allergies))]
    return filtered_recipes

def filter_recipes_by_cook_time(recipes_df, max_minutes):
    filtered_recipes = recipes_df[recipes_df['minutes'] <= max_minutes]
    return filtered_recipes

# Get user input for ingredients
user_input = input("Enter ingredients separated by commas: ")
ingredients_list = [ingredient.strip() for ingredient in user_input.split(',')]

# Get filtered recipes based on user input ingredients
filtered_recipes = filter_recipes_by_ingredients(df, ingredients_list)

# Display the results
if not filtered_recipes.empty:
    print("\nRecipes containing the specified ingredients:")
    print(filtered_recipes[['name', 'description', 'ingredients']])
else:
    print("No recipes found containing the specified ingredients.")

# Get user input for allergies
allergy_input = input("\nEnter any allergies separated by commas (or press Enter if none): ")
if allergy_input.strip():
    allergies_list = [allergy.strip() for allergy in allergy_input.split(',')]
    filtered_recipes = remove_allergy_ingredients(filtered_recipes, allergies_list)

    if not filtered_recipes.empty:
        print("\nRecipes after removing those containing allergens:")
        print(filtered_recipes[['name', 'description', 'ingredients']])
    else:
        print("No recipes found after filtering out allergens.")
else:
    print("No allergies entered. Displaying original results.")

# Get user input for maximum cooking time
max_time_input = input("\nEnter maximum cooking time in minutes (or press Enter for no limit): ")
if max_time_input.strip().isdigit():
    max_minutes = int(max_time_input)
    filtered_recipes = filter_recipes_by_cook_time(filtered_recipes, max_minutes)

    filtered_recipes = filtered_recipes.sort_values(by='minutes')

    if not filtered_recipes.empty:
        print("\nRecipes within the specified cooking time:")
        print(filtered_recipes[['name', 'description', 'ingredients', 'minutes']])
    else:
        print("No recipes found within the specified cooking time.")
else:
    print("No valid cooking time entered. Displaying recipes without this filter.")

# Get user suggestions for recipe preferences
suggestions_input = input("\nEnter your suggestions or preferences for recipes: ")

# Combine suggestions with filtered recipes for the Gemini model
recipes_info = filtered_recipes[['id', 'name', 'description']].to_dict(orient='records')
# print(recipes_info)
suggestions_prompt = f"Based on these recipes: {recipes_info}, and the user's suggestions: '{suggestions_input}', recommend the top 10 recipe IDs.Only give me the recipe ids"

# Generate recommendations using the Gemini model
response = model.generate_content(suggestions_prompt)
recommended_recipe_ids = response.text

# Print the recommended recipe IDs
print("\nRecommended recipe IDs based on your suggestions:")
print(recommended_recipe_ids)
