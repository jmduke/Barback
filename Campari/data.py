import yaml


from utils import convert_ingredient_to_dict

bases_filename = "data/bases.yaml"
recipes_filename = "data/recipes.yaml"


def load_recipes_from_yaml():
    # CLoader needed or else it flips out when it encounters emoji.
    raw_recipes = yaml.load(open(recipes_filename).read(), Loader=yaml.CLoader)
    for r, recipe in enumerate(raw_recipes):
        for i, ingredient in enumerate(recipe["ingredients"]):
            ingredient_dict = convert_ingredient_to_dict(ingredient)
            raw_recipes[r]["ingredients"][i] = ingredient_dict
    return raw_recipes


def load_bases_from_yaml():
    raw_bases = yaml.load(open(bases_filename).read(), Loader=yaml.CLoader)
    return raw_bases
