from parse_rest.connection import register, ParseBatcher
from models import Recipe, Ingredient, IngredientBase, Brand
from config import application_id, client_key
from utils import chunks, convert_ingredient_to_dict
import yaml
import json

def load_configurations():
    register(application_id, client_key)

def load_recipes_from_yaml():
    recipes_filename = "data/recipes.yaml"
    raw_recipes = yaml.safe_load(open(recipes_filename).read())
    for r, recipe in enumerate(raw_recipes):
        for i, ingredient in enumerate(recipe["ingredients"]):
            raw_recipes[r]["ingredients"][i] = convert_ingredient_to_dict(ingredient)
    return raw_recipes

def load_bases_from_yaml():
    bases_filename = "data/bases.yaml"
    raw_bases = yaml.safe_load(open(bases_filename).read())
    return raw_bases

def dump_data_to_json(new_recipes, new_bases):
    recipe_json_filename = "output/recipes.json"
    base_json_filename = "output/bases.json"

    with open(recipe_json_filename, "w") as outfile:
        json.dump(new_recipes, outfile)  

    with open(base_json_filename, "w") as outfile:
        json.dump(new_bases, outfile)

def get_bases_from_parse():
    bases = IngredientBase.Query.all().limit(1000)
    brands = list(Brand.Query.all().limit(1000))

    parsed_bases = []
    for b in bases:
        parsed_base = b.to_dictionary()

        relevant_brands = [br for br in brands if br.base == b.name]
        for brand in relevant_brands:
            brands.remove(brand)

        parsed_base['brands'] = [br.to_dictionary() for br in relevant_brands]
        for brand in parsed_base['brands']:
            brand.pop("base")


        parsed_bases.append(parsed_base)

    return parsed_bases

def get_recipes_from_parse():
    recipes = Recipe.Query.all().limit(1000)
    ingredients = list(Ingredient.Query.all().limit(1000))

    parsed_recipes = []
    for r in recipes:
        parsed_recipe = r.to_dictionary()

        relevant_ingredients = [i for i in ingredients if i.recipe == r.name]
        for ingredient in relevant_ingredients:
            ingredients.remove(ingredient)

        parsed_recipe['ingredients'] = [i.to_dictionary() for i in relevant_ingredients]
        for ingredient in parsed_recipe['ingredients']:
            ingredient.pop("recipe")

        parsed_recipes.append(parsed_recipe)

    return parsed_recipes

def sync_data_with_parse(new_recipes, new_bases):
    old_recipes = get_recipes_from_parse()
    old_bases = get_bases_from_parse()

    recipes = []
    ingredients = []
    for recipe in new_recipes:
        recipes.append(Recipe(dictionary=recipe))
        for ingredient in recipe["ingredients"]:
            ingredient.update({"recipe": recipe['name']})
            ingredients.append(Ingredient(dictionary=ingredient))

    if recipes:
        print "Found {} new recipes.".format(len(recipes))
    if ingredients:
        print "Found {} new ingredients.".format(len(ingredients))

    bases = []
    brands = []
    for base in new_bases:
        base_object = IngredientBase(dictionary=base)
        bases.append(base_object)
        for brand in base["brands"]:
            brand.update({"base": base["name"]})
            brands.append(Brand(dictionary=brand))

    if bases:
        print "Found {} new bases.".format(len(bases))  
    if brands:
        print "Found {} new brands.".format(len(brands))

    if len(recipes + bases + ingredients + brands):
        print "Pushing data."
    else:
        print "No data to push."
        return

    max_batch_size = 50
    print "Deleting all jank first."
    for chunk in chunks(list(Recipe.Query.all().limit(1000)) + 
                        list(Ingredient.Query.all().limit(1000)) + 
                        list(IngredientBase.Query.all().limit(1000)) + 
                        list(Brand.Query.all().limit(1000)), max_batch_size):
        ParseBatcher().batch_delete(chunk)


    for chunk in chunks(recipes + bases + ingredients + brands, max_batch_size):
        ParseBatcher().batch_save(chunk)
        print "Pushed {} objects.".format(len(chunk))

if __name__ == "__main__":
    load_configurations()

    new_recipes = load_recipes_from_yaml()
    new_bases = load_bases_from_yaml()

    dump_data_to_json(new_recipes, new_bases)
    sync_data_with_parse(new_recipes, new_bases)