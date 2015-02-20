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

    splits = ingredient.split("oz")
    if len(splits) > 1:
        parsed_ingredient["amount"] = float(splits[0])
        splits = splits[1:]

    splits = splits[0].split("(")
    if len(splits) > 1:
        parsed_ingredient["label"] = splits[-1][:-1]

    parsed_ingredient["base"] = splits[0].lstrip().strip()
    return parsed_ingredient 

def convert_ingredient_from_dict(ingredient):
    if not isinstance(ingredient, dict):
        return ingredient

    stra = ""
    if "amount" in ingredient:
        stra += "{}oz ".format(ingredient["amount"])
    stra += ingredient["base"]

    if "label" in ingredient:
        try:
            stra += " ({})".format(ingredient["label"])
        except:
            return ingredient


    return stra