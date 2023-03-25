from dataclasses import dataclass
import sys
import os
import subprocess as sp
import shutil

# Path navigation
@dataclass
class Both:
    app: str
    sub: list

@dataclass
class Out:
    app: str
    sub: list

@dataclass
class In:
    app: str
    sub: list

@dataclass
class Split:
    lapp: str
    rapp: str
    sub: list


# Commands
@dataclass
class Make:
    target: str

@dataclass
class Move:
    target: str
    source: str


# Traversal
def traverse(structure, lpath="/", rpath="/"):
    verify(rpath)
    match structure:
        # List of structures: recurse into each
        case [*its]:
            for it in its:
                traverse(it, lpath, rpath)
        # Both adds the same suffix to both paths
        case Both(app, sub):
            traverse(sub, lpath+"/"+app, rpath+"/"+app)
        # Out only modifies the target path
        case Out(app, sub):
            traverse(sub, lpath+"/"+app, rpath)
        # In only modifies the source path
        case In(app, sub):
            traverse(sub, lpath, rpath+"/"+app)
        # Split modifies both paths differently
        case Split(lapp, rapp, sub):
            traverse(sub, lpath+"/"+lapp, rpath+"/"+rapp)
        # Invokes a make command in a remote folder
        # to ensure that the source is up to date
        case Make(target):
            changedir(rpath)
            execute_make(target)
        # Copies the source to the target
        case Move(target, source):
            createdir(lpath)
            execute_move(lpath+"/"+target, rpath+"/"+source)
        case _:
            print(f"The head of '{type(structure)}' is not a valid construct")
            sys.exit(1)

def verify(path):
    """Check that a path exists"""
    if path[0] != "/":
        print(f"Only absolute paths should be given, '{path}' is not.")
        sys.exit(1)
    if not os.path.exists(path):
        print(f"The path '{path}' does not exist.")
        sys.exit(1)

def changedir(path):
    """Change the current working directory"""
    verify(path)
    os.chdir(path)

def execute_make(target):
    """Run a Make command locally"""
    if not type(target) == str:
        print(f"Argument given to Make is not a string: '{target}'")
        sys.exit(1)
    # Temporarily deactivated
    return
    proc = sp.run(["make", target])
    if proc.returncode != 0:
        print(f"Command Make failed to execute")
        sys.exit(1)

def createdir(path):
    """Create directory"""
    # TODO: guard against ancestor climbing
    if not os.path.exists(path):
        print(f"Building {path}")
        os.makedirs(path, exist_ok=True)

def execute_move(target, source):
    """Copy a file"""
    verify(source)
    source_t = os.path.getmtime(source)
    target_t = os.path.getmtime(target)
    if source_t > target_t:
        print(f"Copying {source} to {target}")
        shutil.copy(source, target)
