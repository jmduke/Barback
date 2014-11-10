import json
import wikipedia

filename = 'recipes.json'
recipeJson = open(filename).read()
allRecipes = json.loads(recipeJson)
ingredientDicts = [recipe['ingredients'] for recipe in allRecipes]

ingredientSet = []

for ingredientDict in ingredientDicts:
  for ingredient in ingredientDict:
    ingredientSet.append(ingredient.get("ingredient", ingredient.get("special")))

ingredientSet = list(set(ingredientSet))
newIngredients = []
for ingredientName in ingredientSet:
  try:  
    newIngredients.append({'name': ingredientName, 'description': wikipedia.summary(ingredientName), 'brands': []})
  except:
    pass

with open('ing.json', 'w') as outfile:
  outfile.write(json.dumps(newIngredients))