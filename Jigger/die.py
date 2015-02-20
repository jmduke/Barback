import yaml
import run
import utils

raw_recipes = run.load_recipes_from_yaml()
for r, recipe in enumerate(raw_recipes):
    for i, ingredient in enumerate(recipe["ingredients"]):
        raw_recipes[r]["ingredients"][i] = utils.convert_ingredient_from_dict(ingredient)
with open("newr.yaml", "w") as outfile:
    outfile.write(yaml.safe_dump(raw_recipes, default_flow_style=False))