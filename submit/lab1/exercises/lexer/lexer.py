#!/usr/bin/env python3

import re
import sys
from collections import namedtuple

#Using the next_match() function provides a workaround for the fact
#that Python 3.7 does not support assignment expressions.  In fact,
#the clumsy nested if-then-else handling in exactly this situation of
#regex matching is cited as part of the rationale for the recent
#addition of assignment expressions using the `:=` walrus operator to
#Python 3.8.
#<https://www.python.org/dev/peps/pep-0572/#the-importance-of-real-code>


#returns pair containing regex match-object and token kind.  If token
#should be ignored, kind should be returned as None.
#note that m.group() gives lexeme after a successful match
def next_match(text):
    m = re.compile(r'\s+').match(text)
    if (m): return (m, None)  #None kind means ignore

    m = re.compile(r'\d+').match(text)
    if (m): return (m, 'INT')

    m = re.compile(r'.').match(text)  #must be last: match any char
    if (m): return (m, m.group())


def scan(text):
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
    tokens = scan(contents)
    for t in tokens: print(t)

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
