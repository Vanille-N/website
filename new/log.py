class Logger:
    indent = 0
    indent_step = 4

    def indent_inc():
        Logger.indent += Logger.indent_step
    def indent_dec():
        Logger.indent -= Logger.indent_step

    def __init__(self):
        self.filename = Trace.logfile

    def __enter__(self):
        if self.filename is not None:
            self.file = open(self.filename)
            self.colors = { k:'' for k in ['RED', 'GRN', 'YLW', 'BLU', 'PPL', 'WHT'] }
        else:
            self.file = None
            self.colors = {
                'RED': '\x1b[31m',
                'GRN': '\x1b[32m',
                'YLW': '\x1b[33m',
                'BLU': '\x1b[34m',
                'PPL': '\x1b[35m',
                'WHT': '\x1b[0m',
            }
        return self

    def __exit__(self, typ, value, traceback):
        if self.file is not None:
            self.file.close()

    def write(self, fstr, *args, **kwargs):
        text = fstr.format(*args, **kwargs, **self.colors)
        for line in text.split('\n'):
            line = ' ' * Logger.indent + line
            if self.file is not None:
                self.file.write(line + '\n')
            else:
                print(line)

def call(fn):
    fn()

class Trace:
    # Verbosities:
    #   d      debug
    #   i      info
    #   p      path
    #   n      none
    verbose = 'd'

    indent = 0
    logfile = None

    def lv(label=None):
        if label is None: label = Trace.verbose
        match label:
            case 'n': return 0
            case 'p': return 1
            case 'i': return 2
            case 'd': return 3
            case _:
                raise ArgumentError(label)

def verb_level(lv):
    def wrapper(fn):
        def inner(msg, *args, **kwargs):
            if Trace.lv() >= Trace.lv(lv):
                with Logger() as f:
                    fmt = fn()
                    for line in msg.split('\n'):
                        f.write(fmt.format(msg=line), *args, **kwargs)
        return inner
    return wrapper

@verb_level('d')
def debug():
    return '? {msg}'

@verb_level('i')
def info():
    return '> {msg}'

def path(comment=None):
    def wrapper(fn):
        def inner(*args, **kwargs):
            aux = (Trace.lv() >= Trace.lv('p'))
            with Logger() as f:
                if aux:
                    f.write("{GRN}{name}{WHT} {{", name=fn.__name__)
                    Logger.indent_inc()
                    if comment is not None:
                        f.write(comment, *args, **kwargs)
                res = fn(*args, **kwargs)
                if aux:
                    Logger.indent_dec()
                    f.write("}}")
                return res
        return inner
    return wrapper

