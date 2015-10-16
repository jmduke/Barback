from collections import namedtuple
import argparse

from tabulate import tabulate

from data import (
    load_bases_from_yaml,
    load_recipes_from_yaml
)

KeyData = namedtuple('KeyData', ['key', 'count_with', 'count_without'])


def get_data_for_key(object_list, key, verbose=False):

    objects_with_key = [o for o in object_list if not o.get(key, None)]
    objects_without_key = [o for o in object_list if not o.get(key, None)]

    if verbose:
        print "{}:".format(key)
        print "\n - ".join([""] + [i['name'] for i in objects_without_key])

    return KeyData(key,
                   len(objects_with_key),
                   len(objects_without_key))


def overview():
    recipes = load_recipes_from_yaml()
    recipe_keys = [
        "emoji",
        "source",
        "information"
    ]
    recipe_data = [get_data_for_key(recipes, key, verbose=False) for key in recipe_keys]

    print "\nrecipes: "
    print tabulate(recipe_data,
                   headers=["key", "count_with", "count_without"],
                   tablefmt="psql")

    bases = load_bases_from_yaml()
    base_keys = [
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
    print "\nThere are {} ingredients without bases.".format(len(unique_ingredients_without_bases))


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Analyze data within Campari.')
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--overview", help="High level data about keys.", action="store_true")
    group.add_argument("--details", help="Low level data about a key.")
    args = parser.parse_args()

    data = {
        'recipes': load_recipes_from_yaml(),
        'bases': load_bases_from_yaml()
    }
    if args.overview:
        overview()
    else:
        (obj, key) = args.details.split(".")
        get_data_for_key(data[obj], key, verbose=True)
