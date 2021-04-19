#!/usr/bin/env python3

import re
import sys
from collections import namedtuple
import json

from tl_lexer import scan_stdin

"""
program                      # [ (def|expr)* ]
  : def program
  | expr program
  | // empty
  ;

def
  : 'def' id '(' formals ')' expr   # ast: DEF(id, formals, expr)
  ;

formals
  : id ? ( ',' id )*   # ast: FORMALS(id*)
  ;

expr
  : condExpr
  ;
condExpr
  : relExpr ( '?' relExpr ':' condExpr ) ?
  ;
relExpr
  : addExpr ( ( '<' | '<=' | '>' | '>=' | '==' | '!=' ) addExpr ) ?
  ;
addExpr
  : multExpr ( ( '+' | '-' ) multExpr ) *
  ;
multExpr
  : primaryExpr ( ( '*' | '/' ) primaryExpr ) *
  ;
primaryExpr
  : '-' primaryExpr
  | '(' expr ')'
  | INT
  | ID
  | ID '(' actuals ')'
  ;

actuals
  : expr ? ( ',' expr )*     # ast ACTUALS(expr*)
  ;
"""

def parse():

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
        tok = tokens[index]
        index += 1
        return tok

    def program():
        asts = []
        while (not check('<EOF>')):
            ast = defn() if (check('DEF')) else expr()
            asts.append(ast)
        return asts

    def defn():
        match('DEF')
        id = lookahead.lexeme
        match('ID')
        match('(')
        f = formals()
        match(')')
        e = expr()
        idAst = Ast('ID')
        idAst['id'] = id
        return Ast('DEF', idAst, f, e)

    def formals():
        list = []
        if check('ID'):
            idAst = Ast('ID')
            idAst['id'] = lookahead.lexeme
            list.append(idAst)
            match('ID')
            while check(','):
                match(',')
                idAst = Ast('ID')
                idAst['id'] = lookahead.lexeme
                list.append(idAst)
                match('ID')
        return Ast('FORMALS', *list)

    def expr():
        return condExpr()

    def condExpr():
        e = relExpr()
        if (check('?')):
            match('?')
            e1 = relExpr()
            match(':')
            e2 = condExpr()
            e = Ast('?:', e, e1, e2)
        return e

    def relExpr():
        e = addExpr()
        while (check('<') or check('<=') or check('>') or check('>=') or
               check('==') or check('!=')):
            relOp = lookahead.kind
            match(relOp)
            e1 = addExpr()
            e = Ast(relOp, e, e1)
        return e

    def addExpr():
        e = multExpr()
        while (check('+') or check('-')):
            op = lookahead.kind
            match(op)
            e1 = multExpr()
            e = Ast(op, e, e1)
        return e

    def multExpr():
        e = primaryExpr()
        while (check('*') or check('/')):
            op = lookahead.kind
            match(op)
            e1 = primaryExpr()
            e = Ast(op, e, e1)
        return e

    def primaryExpr():
        if check('-'):
            match('-')
            return Ast('-', primaryExpr())
        if check('('):
            match('(')
            e = expr()
            match(')')
            return e
        if check('INT'):
            value = int(lookahead.lexeme)
            match('INT')
            ast = Ast('INT')
            ast['value'] = value
            return ast
        id = lookahead.lexeme
        match('ID')
        ast = Ast('ID')
        ast['id'] = id
        if not check('('):
            return ast
        match('(')
        exprs = actuals()
        match(')')
        return Ast('APP', ast, exprs)

    def actuals():
        list = []
        if not check(')'):
            e = expr()
            list.append(e)
            while check(','):
                match(',')
                e = expr()
                list.append(e)
        return Ast('ACTUALS', *list)

    #begin parse()
    tokens = scan_stdin()
    index = 0
    lookahead = nextToken()
    value = program()
    if (not check('<EOF>')):
        print(f'expecting <EOF>, got {lookahead.lexeme}', file=sys.stderr)
        sys.exit(1)
    return value

def main():
    asts = parse()
    print(json.dumps(asts, separators=(',', ':'))) #no whitespace

#use a dict so that we can add attributes dynamically
def Ast(tag, *kids):
    return { 'tag': tag, 'kids': kids }

if __name__ == "__main__":
    main()
