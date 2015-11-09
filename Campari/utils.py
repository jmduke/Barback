import math

def chunks(l, n):
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i:i+n]

# <amount>oz <base> (<label>)
def convert_ingredient_to_dict(ingredient):
    if isinstance(ingredient, dict):
        return ingredient

    parsed_ingredient = {}

    splits = ingredient.split("cl")
    if len(splits) > 1:
        parsed_ingredient["amount"] = float(splits[0])
        splits = splits[1:]

    splits = splits[0].split("(")
    if len(splits) > 1:
        parsed_ingredient["label"] = splits[-1][:-1]

    parsed_ingredient["baseName"] = splits[0].lstrip().strip()
    return parsed_ingredient


def get_similar_recipes(recipe, recipe_bases, recipes, uses_for_bases):

    number_of_similar_ingredients = math.ceil(len(recipe_bases) / 2.0)
    possible_similar_recipes = []
    for base_name in recipe_bases:
        recipe_names_for_base = [use['recipe'] for use in uses_for_bases[base_name]]
        possible_similar_recipes.append(recipe_names_for_base)

    similar_recipes = []
    for comparator_recipe in recipes:
        occurences = [recipe_group for recipe_group in possible_similar_recipes if comparator_recipe['name'] in recipe_group]
        if len(occurences) >= number_of_similar_ingredients and comparator_recipe['name'] != recipe['name']:
            similar_recipes.append(comparator_recipe['name'])
    return similar_recipes
