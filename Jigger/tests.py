import time
import unittest
import os
import panther
import run
import utils

class JiggerTest(unittest.TestCase):

    def setUp(self):
        self.startTime = time.time()
        run.load_configurations()

    def tearDown(self):
        t = time.time() - self.startTime
        print "%s: %.3f" % (self.id(), t)

    def validate_recipes(self, recipes):
        self.assertIsNot(recipes, None)
        self.assertIsNot(recipes, [])
        self.assertTrue(len(recipes) > 100)
        for recipe in recipes:
            self.assertIsNot(recipe["name"], None)
            self.assertIsNot(recipe["glassware"], None)
            self.assertIsNot(recipe["directions"], None)
            for ingredient in recipe["ingredients"]:
                self.assertIsNot(ingredient["base"], None)

    def validate_bases(self, bases):
        self.assertIsNot(bases, None)
        self.assertIsNot(bases, [])
        self.assertTrue(len(bases) > 100)
        for base in bases:
            self.assertIsNot(base["name"], None)
            self.assertIsNot(base["information"], None)
            self.assertIsNot(base["type"], None)
            self.assertIsNot(base["abv"], None)
            self.assertIsNot(base["cocktaildb"], None)
            for brand in base["brands"]:
                self.assertIsNot(brand["name"], None)
                self.assertIsNot(brand["price"], None)
                self.assertIsNot(brand["url"], None)

    def test_load_recipes_from_yaml(self):
        recipes = run.load_recipes_from_yaml()
        self.validate_recipes(recipes)

    def test_load_bases_from_yaml(self):
        bases = run.load_bases_from_yaml()
        self.validate_bases(bases)

    def test_get_recipes_from_parse(self):
        recipes = run.get_recipes_from_parse()
        self.validate_recipes(recipes)

    def test_get_bases_from_parse(self):
        bases = run.get_bases_from_parse()
        self.validate_bases(bases)

    def test_compare_yaml_and_parse_recipes(self):
        new_recipes = run.load_recipes_from_yaml()
        old_recipes = run.get_recipes_from_parse()
        self.assertEquals(len(new_recipes), len(old_recipes))

    def test_convert_ing(self):
        ingredient = utils.convert_ingredient_to_dict("3oz Sloe Gin")
        self.assertEquals(ingredient["amount"], 3)
        self.assertEquals(ingredient["base"], "Sloe Gin")

        ingredient = utils.convert_ingredient_to_dict("3oz Applejack (Can substitute Calvados)")
        self.assertEquals(ingredient["amount"], 3)
        self.assertEquals(ingredient["base"], "Applejack")
        self.assertEquals(ingredient["label"], "Can substitute Calvados")

        ingredient = utils.convert_ingredient_to_dict("Egg white (One egg)")
        self.assertEquals(ingredient["base"], "Egg white")
        self.assertEquals(ingredient["label"], "One egg")


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(JiggerTest)
    unittest.TextTestRunner(verbosity=0).run(suite)