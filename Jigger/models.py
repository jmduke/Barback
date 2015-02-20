from parse_rest.datatypes import Object

class ParseObject(Object):
    required_attributes = []
    optional_attributes = ["isDead"]

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