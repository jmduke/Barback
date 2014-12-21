from parse_rest.connection import register, ParseBatcher
from parse_rest.datatypes import Object
from parse_config import application_id, client_key
import yaml
import json

recipes_filename = "recipes.yaml"
bases_filename = "bases.yaml"

force_override = True
add_cocktaildb_url = False

def chunks(l, n):
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i:i+n]

class ParseObject(Object):
    required_attributes = []
    optional_attributes = ["isDead", "objectId"]

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
    required_attributes = ParseObject.required_attributes + ["name", "glassware", "directions"]
    optional_attributes = ParseObject.optional_attributes + ["information", "garnish"]

class Ingredient(ParseObject):
    required_attributes = ParseObject.required_attributes + ["base"]
    optional_attributes = ParseObject.optional_attributes + ["amount", "label", "recipe"]

class IngredientBase(ParseObject):
    required_attributes = ParseObject.required_attributes + ["name", "information", "type"]
    optional_attributes = ParseObject.optional_attributes + ["abv", "cocktaildb"]
    
class Brand(ParseObject):
    required_attributes = ParseObject.required_attributes + ["name", "price", "url"]
    optional_attributes = ParseObject.optional_attributes + ["base"]

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
        for ingredient in parsed_recipe['ingredients']:
            ingredient.pop("recipe")

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
        for brand in parsed_base['brands']:
            brand.pop("base")


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
    old_recipes = get_recipes() if not force_override else []
    raw_recipes = yaml.safe_load(open(recipes_filename).read())
    recipes = []
    ingredients = []
    for recipe in raw_recipes:
        if recipe not in old_recipes:
            recipes.append(Recipe(dictionary=recipe))
            for ingredient in recipe["ingredients"]:
                ingredient.update({"recipe": recipe['name']})
                ingredients.append(Ingredient(dictionary=ingredient))

    print "Found {} new recipes.".format(len(recipes))
    print "Found {} new ingredients.".format(len(ingredients))

    if add_cocktaildb_url:
        filename = "cocktaildb.csv"
        cocktaildb_data = open(filename).readlines()
        cocktaildb_data = [line.split(",") for line in cocktaildb_data]
        cocktaildb_data = {line[0].lower(): line[1].strip() for line in cocktaildb_data}

    old_bases = get_bases() if not force_override else []
    raw_bases = yaml.load(open(bases_filename).read())
    bases = []
    brands = []
    for base in raw_bases:
        if base not in old_bases:
            base_object = IngredientBase(dictionary=base)
            bases.append(base_object)
            for brand in base["brands"]:
                brand.update({"base": base["name"]})
                brands.append(Brand(dictionary=brand))
            if add_cocktaildb_url:
                base_object.cocktaildb = cocktaildb_data.get(base_object.name.lower(), "")


    print "Found {} new bases.".format(len(bases))  
    print "Found {} new brands.".format(len(brands))

    print "Pushing data."

    max_batch_size = 50
    for chunk in chunks(recipes + bases + ingredients + brands, max_batch_size):
        ParseBatcher().batch_save(chunk)
        print "Pushed {} objects.".format(len(chunk))

if __name__ == "__main__":
    setup()
    # push()
    pull()
