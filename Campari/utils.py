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