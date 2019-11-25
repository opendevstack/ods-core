from functools import wraps


def to_camel_case(snake_str):
    components = snake_str.split('_')
    # We capitalize the first letter of each component except the first one
    # with the 'title' method and join them together.
    return components[0] + ''.join(x.title() for x in components[1:])


def convert_dict_key_case(dic):
    """

    Parameters
    ----------
    dic: dict
        Dictionary

    Returns
    -------
    dict
        Same dictionaru with keys converted to pascal case

    """

    if not isinstance(dic, (dict, list)):
        return dic
    if isinstance(dic, list):
        return [v for v in (convert_dict_key_case(v) for v in dic) if v]

    return {to_camel_case(k): v for k, v in ((k, convert_dict_key_case(v)) for k, v in dic.items()) if v}

