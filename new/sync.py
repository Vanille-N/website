import parse as ps

class Path:
    def __init__(self, lst):
        self.lst = lst


def translate_ast(ast):
    return translate_list([], Path(), Path('home', conf.us, ) ast)

def translate_list(acc, prefix, lst):
    print(lst)


