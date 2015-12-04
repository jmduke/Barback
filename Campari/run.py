# This Python file uses the following encoding: utf-8
import json
import subprocess
import sys
import time

import requests
from slugify import slugify

from data import (
    load_bases_from_yaml,
    load_recipes_from_yaml
)
from utils import (
    get_similar_recipes
)


def write_to_json(objects, filename):
    json_objects = json.dumps(objects)
    with open(filename, 'w') as outfile:
        outfile.write(json_objects)


def write_to_markdown(recipes, bases, foldername):

    uses_for_bases = {}

    for base in bases:

        # Add uses for Angostura.
        base["uses"] = []
        for recipe in recipes:
            for ingredient in recipe["ingredients"]:
                if base["name"] == ingredient["baseName"]:
                    base["uses"].append({
                        'recipe': recipe['name'],
                        'slug': recipe['slug'],
                        'ingredient': ingredient
                    })


        # 'type' is loaded in Hugo.
        base['ingredient_type'] = base['type']
        del base['type']

        json_base = json.dumps(base, sort_keys=True, indent=4, separators=(',', ': '))
        base_filename = foldername + "base/" + base['slug'] + ".md"
        with open(base_filename, "w") as outfile:
            outfile.write(json_base)

        # Delete this to avoid circular references.
        uses_for_bases[base['name']] = base['uses']
        del base["uses"]

        base['type'] = base['ingredient_type']


    for recipe in recipes:

        recipe_bases = []
        for (i, ingredient) in enumerate(recipe["ingredients"]):
            base_name = recipe["ingredients"][i]["baseName"]
            base = next((base for base in bases if base['name'] == base_name), None)
            if base and 'Rye' not in sys.argv:
                recipe["ingredients"][i]["baseName"] = base
                recipe_bases.append(base['name'])


        # Generate similar recipes.
        recipe['similar_recipes'] = get_similar_recipes(recipe, recipe_bases, recipes, uses_for_bases)

        # Actually write to file.
        json_recipe = json.dumps(recipe, sort_keys=True, indent=4, separators=(',', ': '))
        recipe_filename = foldername + "recipe/" + recipe['slug'] + ".md"
        with open(recipe_filename, "w") as outfile:
            outfile.write(json_recipe)


if __name__ == "__main__":
    recipes = load_recipes_from_yaml()
    bases = load_bases_from_yaml()

    for recipe in recipes:
        recipe['slug'] = slugify(unicode(recipe['name']))
        if not recipe.get('garnish', None):
            recipe['garnish'] = ''
        if not recipe.get('source', None):
            recipe['source'] = ''
    for base in bases:
        base['slug'] = slugify(unicode(base['name']))

    write_to_markdown(recipes, bases, "output/md/")
    write_to_json(recipes, "output/json/recipes.json")
    write_to_json(bases, "output/json/bases.json")

    pipe = subprocess.Popen(["phantomjs", "server.js"])
    time.sleep(1)
    for recipe in recipes:
        recipe_json = json.dumps(recipe)
        svg = requests.post("http://localhost:9494", data=recipe_json).content
        outfilename = "output/svg/{}.svg".format(recipe['slug'])
        with open(outfilename, 'w') as outfile:
            outfile.write(svg)
    pipe.kill()
    pipe.terminate()
