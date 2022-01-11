#! /usr/bin/python3

import sys
from argparse import ArgumentParser
import parse
import conf
import sync

class Args:
    def parse(args):
        parser = ArgumentParser(description="synchronize shared files")
        parser.add_argument("--sync", action='store_true')
        res = parse.from_file(conf.file_list)
        tr = sync.translate_ast(res)
        print(tr)

if __name__ == '__main__':
    Args.parse(sys.argv[1:])
