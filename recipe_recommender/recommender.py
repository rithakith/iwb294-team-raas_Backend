import pandas as pd
import google.generativeai as genai
from dotenv import load_dotenv
import os
from flask import Flask, request, jsonify
import re

# Initialize Flask app
app = Flask(__name__)

# Load environment variables
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

@app.route('/recommend', methods=['POST'])
def recommend_recipes():
    data = request.get_json()

    ingredients_list = data.get("ingredients", [])
    allergies_list = data.get("allergies", [])
    max_minutes = data.get("max_minutes", None)
    suggestions_input = data.get("suggestions", "")

    # Get filtered recipes based on user input ingredients
    filtered_recipes = filter_recipes_by_ingredients(df, ingredients_list)

    # Remove allergy ingredients
    filtered_recipes = remove_allergy_ingredients(filtered_recipes, allergies_list)

    # Filter by maximum cooking time if provided
    if max_minutes is not None:
        filtered_recipes = filter_recipes_by_cook_time(filtered_recipes, max_minutes)

    # Generate suggestions based on filtered recipes
    recipes_info = filtered_recipes[['id', 'name', 'description']].to_dict(orient='records')
    suggestions_prompt = f"Based on these recipes: {recipes_info}, and the user's suggestions: '{suggestions_input}', recommend the top 10 recipe IDs. Only give me the recipe ids"

    # Generate recommendations using the Gemini model
    response = model.generate_content(suggestions_prompt)
    print("Raw response from Gemini model:", response.text)

    # Clean up the response text using regex to remove unwanted characters
    clean_response = re.sub(r"[^\d,]", "", response.text)  # Keep only digits and commas
    print("Cleaned response:", clean_response)

    # Split by comma and convert to a list of integers
    recommended_recipe_ids = [int(id.strip()) for id in clean_response.split(",") if id.strip()]
    print("Final Recommended Recipe IDs:", recommended_recipe_ids)

    # Filter the DataFrame to get the recommended recipes
    recommended_recipes = df[df['id'].isin(recommended_recipe_ids)].to_dict(orient='records')

    return jsonify({"recommended_recipes": recommended_recipes})

if __name__ == '__main__':
    app.run(debug=True)
