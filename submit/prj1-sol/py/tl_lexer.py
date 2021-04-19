#!/usr/bin/env python3

import re
import sys
from collections import namedtuple
import json

def scan_text(text):
    def next_match(text):
        m = re.compile(r'\s+').match(text)
        if (m): return (m, None)
        m = re.compile(r'#.*').match(text)
        if (m): return (m, None)
        m = re.compile(r'\d+').match(text)
        if (m): return (m, 'INT')
        m = re.compile(r'<=|>=|==|!=').match(text)
        if (m): return (m, m.group())
        m = re.compile(r'[a-zA-Z_]\w*').match(text)
        if (m): return (m, 'DEF' if m.group() == 'def' else 'ID')
        m = re.compile(r'.').match(text)  #must be last: match any char
        if (m): return (m, m.group())

    tokens = []
    while (len(text) > 0):
        (match, kind) = next_match(text)
        lexeme = match.group()
        if (kind): tokens.append(Token(kind, lexeme))
        text = text[len(lexeme):]
    tokens.append(Token('<EOF>', '<EOF>'));
    return tokens

def scan_stdin():
    return scan_text(sys.stdin.read())

def main():
    tokens = scan_stdin()
    #convert to dict to facilitate json in desired format
    jsonTokens = [{ "kind": t.kind, "lexeme": t.lexeme } for t in tokens];
    print(json.dumps(jsonTokens, separators=(',', ':'))) #no whitespace

Token = namedtuple('Token', ['kind', 'lexeme'])

if __name__ == "__main__":
    main()
