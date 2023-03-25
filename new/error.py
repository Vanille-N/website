#! /bin/env python3

RED = "\x1b[31;1m"
YLW = "\x1b[33;1m"
WHT = "\x1b[0m"

# Error reporting with uniform formatting and colored output
class Err:
    fname = ""
    line = 0

    ALWAYS = 0
    WARNING = 1
    ERROR = 2
    NEVER = 3
    fatality = ALWAYS

    def in_file(fname):
        Err.fname = fname
        Err.line = 0

    def count_line(text):
        Err.line += 1
        Err.text = text

    def report(*,
        kind,
        msg,
        fatal=True,
    ):
        Err.fatality = max(Err.fatality, Err.ERROR if fatal else Err.WARNING)
        print("fatality: {}".format(Err.fatality))
        print("In \x1b[36m{}:{}\x1b[0m'".format(Err.fname, Err.line))
        print("{}: {}\x1b[0m".format(
            "\x1b[1;31mError" if fatal else "\x1b[1;33mWarning", kind
        ))
        for line in msg.split('\n'):
            print("    {}".format(line))
        print()

def parsing(text, st, end, message):
    lines = text.split('\n')
    st.line = min(st.line, len(lines) - 1)
    end.line = min(end.line, len(lines) - 1)
    st.col = min(st.col, len(lines[st.line]) - 1)
    end.col = min(end.col, len(lines[end.line]) - 1)
    assert st.line <= end.line
    if st.line == end.line:
        assert st.col <= end.col
    if st.line == end.line:
        sp = ' ' * st.col
        ul = '^' * (end.col - st.col + 1)
        Err.report(
            kind="Parsing error",
            msg=f"""\
| {lines[st.line]}
  {YLW}{sp}{ul}{WHT}
  {YLW}{sp}| {message}{WHT}\
"""
        )
    else:
        Err.report(
            kind="Parsing error",
            msg=f"""\
| {lines[st.line]}
|
|     ...
|
| {lines[end.line]}
"""
        )

