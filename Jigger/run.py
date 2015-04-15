from parse_rest.connection import register, ParseBatcher
from models import Recipe, Ingredient, IngredientBase, Brand
from config import application_id, client_key
from utils import chunks, convert_ingredient_to_dict
from slugify import slugify
import yaml

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


def sync_data_with_parse(new_recipes, new_bases):
    max_batch_size = 50
    print "Deleting all jank first."
    for chunk in chunks(list(Recipe.Query.all().limit(1000)) + 
                        list(Ingredient.Query.all().limit(1000)) + 
                        list(IngredientBase.Query.all().limit(1000)) + 
                        list(Brand.Query.all().limit(1000)), max_batch_size):
        ParseBatcher().batch_delete(chunk)

    # Push recipes.
    recipes = []
    for recipe in new_recipes:
        recipe_object = Recipe(dictionary=recipe)
        recipes.append(recipe_object)
    if recipes:
        print "Found {} new recipes.".format(len(recipes))
        for chunk in chunks(recipes, max_batch_size):
            ParseBatcher().batch_save(chunk)
            print "Pushed {} recipes.".format(len(chunk))

    # Push bases.
    bases = []
    for base in new_bases:
        base_object = IngredientBase(dictionary=base)
        bases.append(base_object)
    if bases:
        print "Found {} new bases.".format(len(bases))
        for chunk in chunks(bases, max_batch_size):
            ParseBatcher().batch_save(chunk)
            print "Pushed {} bases.".format(len(chunk))

    # Reshape bases as dictionary so stuff can be found quickly.
    namesForBases = {base.name: base for base in bases}

    # Push ingredients.
    ingredients = []
    for i, recipe in enumerate(new_recipes):
        for ingredient in recipe["ingredients"]:
            ingredient.update({"recipe": recipes[i]})

            # Some bases might not actually exist.
            if ingredient["base"] not in namesForBases:
                base = IngredientBase(dictionary={
                    "name": ingredient["base"],
                    "information": "",
                    "type": "other",
                    "abv": 0
                    })
                print("Adding unknown IngredientBase: {}".format(ingredient["base"].encode('utf-8')))
                base.save()
                namesForBases[ingredient["base"]] = base
                ingredient.update({"base": base})
            else:
                ingredient.update({"base": namesForBases[ingredient["base"]]})
            ingredients.append(Ingredient(dictionary=ingredient))
    if ingredients:
        print "Found {} new ingredients.".format(len(ingredients))
        for chunk in chunks(ingredients, max_batch_size):
            ParseBatcher().batch_save(chunk)
            print "Pushed {} ingredients.".format(len(chunk))

    # Push brands.
    brands = []
    for base in new_bases:
        for brand in base.get("brands", []):
            brand.update({"base": namesForBases[base["name"]]})
            brands.append(Brand(dictionary=brand))
    if brands:
        print "Found {} new brands.".format(len(brands))
        for chunk in chunks(brands, max_batch_size):
            ParseBatcher().batch_save(chunk)
            print "Pushed {} brands.".format(len(chunk))


if __name__ == "__main__":
    load_configurations()

    new_recipes = load_recipes_from_yaml()
    new_bases = load_bases_from_yaml()

    for recipe in new_recipes:
        recipe['slug'] = slugify(recipe['name'])
    for base in new_bases:
        base['slug'] = slugify(base['name'])

    sync_data_with_parse(new_recipes, new_bases)
