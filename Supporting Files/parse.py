from parse_rest.connection import register, ParseBatcher
from parse_rest.datatypes import Object
from parse_config import application_id, client_key
import yaml
import json

recipes_filename = "recipes.yaml"
bases_filename = "bases.yaml"

class ParseObject(Object):
    required_attributes = []
    optional_attributes = ["isDeleted", "objectId"]

    def __init__(self, **kwargs):
        dictionary = kwargs.pop("dictionary", None)
        Object.__init__(self, **kwargs)

        if dictionary:
            for attribute in self.required_attributes:
                setattr(self, attribute, dictionary[attribute])
            for attribute in self.optional_attributes:
                if attribute in dictionary:
                    setattr(self, attribute, dictionary[attribute])

    def to_dictionary(self):
        dictionary = {}
        for attribute in self.required_attributes:
            dictionary.update({attribute: getattr(self, attribute)})

        for attribute in self.optional_attributes:
            if hasattr(self, attribute):
                dictionary.update({attribute: getattr(self, attribute)})

        return dictionary

class Recipe(ParseObject):
    required_attributes = ParseObject.required_attributes + ["name", "glass", "preparation"]
    optional_attributes = ParseObject.optional_attributes + ["description", "garnish"]

class Ingredient(ParseObject):
    required_attributes = ParseObject.required_attributes + ["base"]
    optional_attributes = ParseObject.optional_attributes + ["cl", "label"]

class IngredientBase(ParseObject):
    required_attributes = ParseObject.required_attributes + ["name", "description", "type"]
    optional_attributes = ParseObject.optional_attributes + ["ABV"]
    
class Brand(ParseObject):
    required_attributes = ParseObject.required_attributes + ["name", "price", "image"]

def setup():
    register(application_id, client_key)

def get_recipes():
    recipes = Recipe.Query.all().limit(1000)
    ingredients = Ingredient.Query.all().limit(1000)

    parsed_recipes = []
    for r in recipes:
        parsed_recipe = r.to_dictionary()
        relevant_ingredients = [i for i in ingredients if i.recipe == r.name]
        parsed_recipe['ingredients'] = [i.to_dictionary() for i in relevant_ingredients]

        parsed_recipes.append(parsed_recipe)

    return parsed_recipes

def get_bases():
    bases = IngredientBase.Query.all().limit(1000)
    brands = Brand.Query.all().limit(1000)

    parsed_bases = []
    for b in bases:
        parsed_base = b.to_dictionary()
        relevant_brands = [br for br in brands if br.base == b.name]
        parsed_base['brands'] = [br.to_dictionary() for br in relevant_brands]

        parsed_bases.append(parsed_base)

    return parsed_bases

def pull():
    recipes = get_recipes()
    with open(recipes_filename, "w") as outfile:
        outfile.write(yaml.safe_dump(recipes, default_flow_style=False))
    with open(recipes_filename.replace("yaml", "json"), "w") as outfile:
        json.dump(recipes, outfile)
        
    bases = get_bases()
    with open(bases_filename, "w") as outfile:
        outfile.write(yaml.safe_dump(bases, default_flow_style=False))
    with open(bases_filename.replace("yaml", "json"), "w") as outfile:
        json.dump(bases, outfile)
        
    print "Pulled data."

def push():
    old_recipes = get_recipes()
    raw_recipes = yaml.safe_load(open(recipes_filename).read())
    recipes = []
    ingredients = []
    for recipe in raw_recipes:
        if recipe not in old_recipes:
            recipes.append(Recipe(dictionary=recipe))
            for ingredient in recipe["ingredients"]:
                ingredient.update({"recipe": recipe})
                ingredients.append(Ingredient(dictionary=ingredient))

    print "Found {} new recipes.".format(len(recipes))

    old_bases = get_bases()
    raw_bases = yaml.load(open(bases_filename).read())
    bases = []
    brands = []
    for base in raw_bases:
        if base not in old_bases:
            bases.append(IngredientBase(dictionary=base))
            for brand in base["brands"]:
                brand.update({"base": base})
                brands.append(Brand(dictionary=brand))

    print "Found {} new bases.".format(len(bases))  

    print "Pushing data."
    ParseBatcher().batch_save(recipes)
    ParseBatcher().batch_save(bases)

if __name__ == "__main__":
    setup()
    push()
    pull()
