# This Python file uses the following encoding: utf-8
import json
import yaml

from slugify import slugify

from utils import convert_ingredient_to_dict


def load_recipes_from_yaml(recipes_filename):
    # CLoader needed or else it flips out when it encounters emoji.
    raw_recipes = yaml.load(open(recipes_filename).read(), Loader=yaml.CLoader)
    for r, recipe in enumerate(raw_recipes):
        for i, ingredient in enumerate(recipe["ingredients"]):
            ingredient_dict = convert_ingredient_to_dict(ingredient)
            raw_recipes[r]["ingredients"][i] = ingredient_dict
    return raw_recipes


def load_bases_from_yaml(bases_filename):
    raw_bases = yaml.load(open(bases_filename).read())
    return raw_bases


def write_to_json(objects, filename):
    json_objects = json.dumps(objects)
    with open(filename, 'w') as outfile:
        outfile.write(json_objects)


def write_to_markdown(recipes, bases, foldername):
    for recipe in recipes:
        for (i, ingredient) in enumerate(recipe["ingredients"]):
            base_name = recipe["ingredients"][i]["baseName"]
            base = next((base for base in bases if base['name'] == base_name), None)
            if base:
                recipe["ingredients"][i]["baseName"] = base
        json_recipe = json.dumps(recipe, sort_keys=True, indent=4, separators=(',', ': '))
        recipe_filename = foldername + "recipe/" + recipe['slug'] + ".md"
        with open(recipe_filename, "w") as outfile:
            outfile.write(json_recipe)
    for base in bases:
        json_base = json.dumps(base, sort_keys=True, indent=4, separators=(',', ': '))
        base_filename = foldername + "base/" + base['slug'] + ".md"
        with open(base_filename, "w") as outfile:
            outfile.write(json_base)


if __name__ == "__main__":
    recipes = load_recipes_from_yaml("data/recipes.yaml")
    bases = load_bases_from_yaml("data/bases.yaml")

    for recipe in recipes:
        recipe['slug'] = slugify(unicode(recipe['name']))
        if not recipe.get('garnish', None):
            recipe['garnish'] = ''
        if not recipe.get('source', None):
            recipe['source'] = ''
    for base in bases:
        base['slug'] = slugify(unicode(base['name']))

    write_to_json(recipes, "output/json/recipes.json")
    write_to_json(bases, "output/json/bases.json")

    write_to_markdown(recipes, bases, "output/md/")
