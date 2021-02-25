#!/usr/bin/env python3

import re
import sys
from collections import namedtuple


"""
program
  : expr ';' program
  | #empty
  ;
expr
  : term ( ( '+' | '-' ) term )*
  ;
term
  : '-' term
  | factor
  ;
factor
  : INT
  | '(' expr ')'
  ;
"""

#use nested function for encapsulation.
def parse(text):

    def check(kind): return lookahead.kind == kind
    def match(kind):
        nonlocal lookahead
        if (lookahead.kind == kind):
            lookahead = nextToken()
        else:
            print(f'expecting {kind} at {lookahead.lexeme}',
                  file=sys.stderr)
            sys.exit(1)
    def nextToken():
        nonlocal index
        if (index >= len(tokens)):
            return Token('EOF', '<EOF>')
        else:
            tok = tokens[index]
            index += 1
            return tok

    def program():
        values = []
        while (not check('EOF')):
            values.append(expr())
            match(';')
        return values

    def expr():
        t = term()
        while (check('+') or (check('-'))):
            kind = lookahead.kind
            match(kind)
            t1 = term()
            t += (t1 if (kind == '+') else -t1)
        return t

    def term():
        if (check('-')):
            match('-')
            return - term()
        else:
            return factor()

    def factor():
        if (check('INT')):
            value = int(lookahead.lexeme)
            match('INT')
            return value
        else:
            match('(')
            value = expr()
            match(')')
            return value

    #begin parse()
    tokens = scan(text)
    index = 0
    lookahead = nextToken()
    value = program()
    if (not check('EOF')):
        print(f'expecting <EOF>, got {lookahead.lexeme}', file=sys.stderr)
        sys.exit(1)
    return value

def scan(text):
    def next_match(text):
        m = re.compile(r'\s+').match(text)
        if (m): return (m, None)
        m = re.compile(r'\d+').match(text)
        if (m): return (m, 'INT')
        m = re.compile(r'.').match(text)  #must be last: match any char
        if (m): return (m, m.group())

    tokens = []
    while (len(text) > 0):
        (match, kind) = next_match(text)
        lexeme = match.group()
        if (kind): tokens.append(Token(kind, lexeme))
        text = text[len(lexeme):]
    return tokens

def main():
    if (len(sys.argv) != 2): usage();
    contents = readFile(sys.argv[1]);
    print(parse(contents))

def readFile(path):
    with open(path, 'r') as file:
        content = file.read()
    return content

Token = namedtuple('Token', ['kind', 'lexeme'])

def usage():
    print(f'usage: {sys.argv[0]} DATA_FILE')
    sys.exit(1)

if __name__ == "__main__":
    main()
