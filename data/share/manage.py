#! /usr/bin/env python3

from util import *

structure = \
    Both("/home/nash", [
        Out("School/website/data/share/.target", [
            In("School", [
                # Internships
                Out("satge", [
                    # Dynamic Unit Disk Graphs (LaBRI)
                    #Split("l3", "L3/dynamic-udg/redac", [
                    #    In("beamer", [
                    #        Make("main.pdf"),
                    #        Move("beamer.pdf", "main.pdf"),
                    #    ]),
                    #    In("report", [
                    #        Make("all"),
                    #        Move("report.pdf", "main.pdf"),
                    #    ]),
                    #]),
                    # Mending Volume (Aalto)
                    #Split("m1", "M1/mending_volume", [
                    #    In("3-BEAMER", [
                    #        Make("all"),
                    #        Move("beamer.pdf", "main.pdf"),
                    #    ]),
                    #    In("1-arxiv", [
                    #        Make("all"),
                    #        Move("paper.pdf", "main.pdf"),
                    #    ]),
                    #]),
                    # Tree Borrows (Saarbrücken)
                    Split("arpe", "ARPE", [
                        In("beamer", [
                            Move("rfmig.pdf", "rfmig.pdf"),
                            Move("lmf.pdf", "lmf.pdf"),
                        ])
                    ])
                ]),
                # Introduction to compiler verification
                #Split("compverif", "M1/Compiling", [
                #    In("report", [
                #        Make("all"),
                #        Move("report.pdf", "main.pdf"),
                #    ]),
                #    In("presentation", [
                #        Make("all"),
                #        Move("beamer.pdf", "main.pdf"),
                #    ]),
                #]),
                # Lambda-calculus and categories
                #Split("categories", "M1/rustbelt", [
                #    Make("all"),
                #    Move("beamer.pdf", "main.pdf"),
                #]),
                # Crans work
                #Split("crans", "Crans/bilantech-23", [
                #    Make("all"),
                #    Move("bilantech-23.pdf", "bilan.pdf"),
                #]),
            ]),
        ]),
    ])

# FIXME: since the NixOS rebuild, the sources are incomplete.
traverse(structure)
