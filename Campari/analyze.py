from collections import namedtuple

from tabulate import tabulate

from data import (
    load_bases_from_yaml,
    load_recipes_from_yaml
)

KeyData = namedtuple('KeyData', ['key', 'count_with', 'count_without'])


def get_data_for_key(object_list, key):
    return KeyData(key,
                   len([o for o in object_list if o.get(key, None)]),
                   len([o for o in object_list if not o.get(key, None)]))


if __name__ == "__main__":
    recipes = load_recipes_from_yaml()
    recipe_keys = [
        "emoji",
        "source",
        "information"
    ]
    recipe_data = [get_data_for_key(recipes, key) for key in recipe_keys]

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
    base_data = [get_data_for_key(bases, key) for key in base_keys]

    print "\nbases: "
    print tabulate(base_data,
                   headers=["key", "count_with", "count_without"],
                   tablefmt="psql")

    print "\n"
