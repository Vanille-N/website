from enum import Enum, unique
import error

def from_file(fname):
    error.Err.in_file(fname)
    with open(fname, 'r') as f:
        text = f.read()
    try:
        toks = Tokens(Chars(text)).read()
        ast = Ast(toks).read()
    except UnknownToken as e:
        error.parsing(text, e.data.start, e.data.end, f"Unknown token '{e.data.payload}'")
        return None
    return ast

class Chars:
    def __init__(self, text):
        self.list = []
        self.idx = Idx(0, 0)
        for c in text:
            self.list.append(Loc(self.idx.clone(), self.idx.clone(), c))
            self.idx.bump()
            if c == '\n':
                self.idx.newline()
        #print(self.list)

    def __getitem__(self, i):
        return self.list.__getitem__(i)

    def __getslice__(self, i, j, step):
        return self.list.__getslice__(i, j, step)

    def __len__(self):
        return self.list.__len__()

class Idx:
    def __init__(self, line, col):
        self.line = line
        self.col = col
    def clone(self):
        return Idx(self.line, self.col)
    def newline(self):
        self.line += 1
        self.col = 0
    def bump(self):
        self.col += 1
    def __str__(self):
        return f"({self.line}:{self.col})"
    def __repr__(self):
        return self.__str__()

class Loc:
    def __init__(self, start, end, payload):
        self.start = start
        self.end = end
        self.payload = payload

    def __str__(self):
        return f"[ '{self.payload}' @ {self.start} - {self.end} ]"
    def __repr__(self):
        return self.__str__()

    def replace(self, new):
        self.payload = new
        return self

class StreamReader:
    def __init__(self, stream):
        self.stream = stream
        self.head = 0
        self.peek = 0
        self.buf = []
        self.stack = []

    def read(self, a, b):
        raise NotImplementedError("read_step should be overriden")

    def matches(self, *items):
        if len(items) == 0:
            return len(self.stream) == self.head
        if self.head + len(items) > len(self.stream):
            return False
        for i,it in enumerate(items):
            if not it(self.stream[self.head + i].payload):
                return False
            #print(f"{it} matches {self.stream[self.head + i]}")
        self.peek = len(items)
        return True

    def take(self, nb=None):
        if nb is None:
            nb = self.peek
        self.peek -= nb
        self.buf.extend(self.stream[self.head:self.head+nb])
        #print(f"Take: nb={nb}, buf={self.buf}")
        self.head += nb

    def drop(self, nb=None):
        if nb is None:
            nb = self.peek
        self.peek -= nb
        #print(f"Drop: nb={nb}")
        self.head += nb

    def flush(self, fn=lambda *x: x):
        if len(self.buf) > 0:
            res = fn(*[c.payload for c in self.buf])
            res = Loc(self.buf[0].start, self.buf[-1].end, res)
            self.buf = []
            return res
        else:
            return None

    def loc_start(self):
        if len(self.buf) > 0:
            return self.buf[0].start
        else:
            return (0,0)

    def loc_end(self):
        if len(self.buf) > 0:
            return self.buf[-1].end
        else:
            return (1000000000,1000000000)

    def sub(self, fn):
        self.save()
        try:
            res = fn()
        except MatchFailure:
            self.rollback()
            return None
        finally:
            self.proceed()
            print(f"res={res}")
            return res

    def save(self):
        self.stack.append(self.head)
    def rollback(self):
        self.head = self.stack.pop()
        self.peek = 0
        self.buf = []
    def proceed(self):
        self.stack.pop()


class Name:
    def __init__(self, name):
        self.name = name

    def is_valid_chr(c):
        return ('a' <= c <= 'z') or ('A' <= c <= 'Z') or ('0' <= c <= '9') or (c == '.') or (c == '-')

    def __str__(self):
        return f"Name({self.name})"
    def __repr__(self):
        return self.__str__()

    def chars(*cs):
        return Name(concat(*cs))

@unique
class Symbols(Enum):
    DDOT = '::'
    OPEN = '{'
    CLOSE = '}'
    COMMA = ','
    ARROW = '<-'
    SLASH = '/'
    ABOVE = '^'
    HOME = '~'

    def eql(self, x):
        return type(x) == Symbols and x.value == self.value

def concat(*cs):
    return ''.join(cs)

def extract(it):
    return it

class Tokens(StreamReader):
    # input: chars
    # output: tokens
    def eql(self, a):
        return (lambda b: a == b)

    def __init__(self, stream):
        super().__init__(stream)
        self.out = []
        self.start = [0,0]
        self.end = [0,0]

    def read(self):
        while True:
            if self.matches(self.eql(' ')) or self.matches(self.eql('\n')):
                self.end[0] += 1
                self.drop()
                continue
            if self.matches(Name.is_valid_chr):
                while self.matches(Name.is_valid_chr):
                    self.take()
                self.out.append(self.flush(Name.chars))
                continue
            found = False
            for sym in list(Symbols):
                if self.matches(*list(self.eql(s) for s in sym.value)):
                    self.take()
                    self.out.append(self.flush().replace(sym))
                    found = True
                    break
            if found:
                continue
            if self.matches():
                break
            raise UnknownToken(self.stream[self.head])
        return self

    def __str__(self):
        return f"{self.out}"
    def __repr__(self):
        return self.__str__()

    def __getitem__(self, i):
        return self.out.__getitem__(i)
    def __getslice__(self, i, j, step):
        return self.out.__getslice__(i, j, step)
    def __len__(self):
        return self.out.__len__()

class MatchFailure(Exception):
    pass

class UnknownToken(Exception):
    def __init__(self, data):
        self.data = data

class Ast(StreamReader):
    def isname(self, b):
        return type(b) == Name

    def read(self):
        #print("%" * 50)
        lst = self.read_list()
        if self.matches():
            return lst
        else:
            error.parsing(self.loc_start(), self.loc_end(), "Expected EOF")
            return None

    def read_list(self):
        lst = []
        while True:
            item = self.sub(self.read_item)
            if item is None:
                break
            else:
                lst.append(item)
            if self.matches(Symbols.COMMA.eql):
                self.drop()
            else:
                break
        if lst == []:
            return None
        else:
            return Loc(lst[0].start, lst[-1].end, List(lst))

    def read_path(self):
        while self.matches(Symbols.SLASH.eql) \
                or self.matches(Symbols.HOME.eql) \
                or self.matches(Symbols.ABOVE.eql) \
                or self.matches(self.isname):
                    self.take()
        path = self.flush()
        if path is not None:
            return Loc(path.start, path.end, Path(path))
        else:
            return None

    def read_file(self):
        path = self.read_path()
        if path is None:
            return None
        if self.matches(Symbols.ARROW.eql):
            self.drop()
            source = self.read_path()
        else:
            source = None
        return Loc(path.start, source.end if source else path.end, File(path, source))

    def read_item(self):
        file = self.read_file()
        if file is None:
            return None
        if self.matches(Symbols.DDOT.eql):
            self.drop()
            if self.matches(Symbols.OPEN.eql):
                self.drop()
                inner = self.read_list()
                if self.matches(Symbols.CLOSE.eql):
                    self.drop()
                else:
                    raise NotImplementedError()
            else:
                inner = self.read_item()
        else:
            inner = None
        return Loc(file.start, inner.end if inner else file.end, Item(file, inner))

class Path:
    def __init__(self, path):
        self.path = path

    def __str__(self, indent=0):
        return ' '.join(i.__str__() for i in self.path.payload)

class Item:
    def __init__(self, file, inner):
        self.file = file
        self.inner = inner

    def __str__(self):
        s = [f"{self.file} ::"]
        for line in self.inner.__str__().split('\n'):
            s.append('    ' + line)
        return '\n'.join(s)

class File:
    def __init__(self, path, source):
        self.path = path
        self.source = source

    def __str__(self):
        return f"File({self.path} <- {self.source})"


class List:
    def __init__(self, lst):
        self.lst = lst

    def __str__(self):
        return ",\n".join('{' + i.__str__() + '}' for i in self.lst)

