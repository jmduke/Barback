# This Python file uses the following encoding: utf-8
from collections import namedtuple
import argparse

from tabulate import tabulate

from data import (
    load_bases_from_yaml,
    load_recipes_from_yaml
)

KeyData = namedtuple('KeyData', ['key', 'count_with', 'count_without'])


def get_data_for_key(object_list, key, verbose=False):

    objects_with_key = [o for o in object_list if o.get(key, None)]
    objects_without_key = [o for o in object_list if not o.get(key, None)]

    if verbose:
        for obj in sorted([obj["name"] for obj in objects_without_key]):
            print " - {}".format(obj.encode('utf-8'))

    return KeyData(key,
                   len(objects_with_key),
                   len(objects_without_key))


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Analyze data within Campari.')
    parser.add_argument("--details", help="Low level data about a key.")
    args = parser.parse_args()

    data = {
        'recipes': load_recipes_from_yaml(),
        'bases': load_bases_from_yaml()
    }
    if args.details:
        (obj, key) = args.details.split(".")
        get_data_for_key(data[obj], key, verbose=True)
    else:
        recipes = data['recipes']
        recipe_keys = [
            "emoji",
            "information",
            "ncotw",
            "source",
        ]
        recipe_data = [get_data_for_key(recipes, key, verbose=False) for key in recipe_keys]

        print "recipes: "
        print tabulate(recipe_data,
                       headers=["key", "count_with", "count_without"],
                       tablefmt="psql")

        bases = data['bases']
        base_keys = [
            "name",
            "abv",
            "cocktaildb",
            "color",
            "emoji",
            "information"
        ]
        base_data = [get_data_for_key(bases, key, verbose=False) for key in base_keys]

        print "\nbases: "
        print tabulate(base_data,
                       headers=["key", "count_with", "count_without"],
                       tablefmt="psql")

        ingredients = [recipe["ingredients"] for recipe in recipes]
        ingredients = [item for sublist in ingredients for item in sublist]
        ingredient_names = [ingredient.get("baseName", "") for ingredient in ingredients]
        base_names = [base["name"] for base in bases]
        ingredients_without_bases = [i for i in ingredient_names if i not in base_names]
        unique_ingredients_without_bases = list(set(ingredients_without_bases))
        print "\nThere are {} ingredients without bases: ".format(len(unique_ingredients_without_bases)),
        if False:
            print "\n - ".join([""] + unique_ingredients_without_bases)

