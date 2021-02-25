#!/usr/bin/env node

import fs from 'fs';
import Path from 'path';


/* 
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
*/

function parse(text) {
  const tokens = scan(text);
  let index = 0;
  let lookahead = nextToken();
  const value = program();
  return value;
  
  function check(kind) { return lookahead.kind === kind; }
  function match(kind) {
    if (check(kind)) {
      lookahead = nextToken();
    }
    else {
      console.error(`expecting ${kind} at ${lookahead.kind}`);
      process.exit();
    }
  }
  function nextToken() {
    return (
      (index >=  tokens.length) ? new Token('EOF', '<EOF>') : tokens[index++]
    );
  }

  function program() {
    const asts = [];
    while (!check('EOF')) {
      asts.push(expr());
      match(';');
    }
    return asts;
  }

  function expr() {
    let t = term();
    while (check('+') || check('-')) {
      const kind = lookahead.kind;
      match(kind);   
      const t1 = term();
      t = new Ast(kind, t, t1);
    }
    return t;
  }

  function term() {
    if (check('-')) {
      match('-');
      return new Ast('-', term());
    }
    else {
      return factor();
    }
  }

  function factor() {
    if (check('INT')) {
      const value = parseInt(lookahead.lexeme);
      match('INT');
      const ast = new Ast('INT');
      ast.value = value;
      return ast;
    }
    else {
      match('(');
      const value = expr();
      match(')');
      return value;
    }
  }
}


function scan(text) {
  const tokens = [];
  while (text.length > 0) {
    let m;
    if ((m = text.match(/^\s+/))) {
    }
    else if ((m = text.match(/^\d+/))) {
      tokens.push(new Token('INT', m[0]));
    }
    else {
      m = text.match(/^./);
      tokens.push(new Token(m[0], m[0]));
    }
    text = text.substring(m[0].length);
  }
  return tokens;
}


const CHAR_SET = 'utf8';
function main() {
  if (process.argv.length !== 3) usage();
  const file = process.argv[2];
  const text = fs.readFileSync(file, CHAR_SET);
  const value = parse(text);
  console.log(JSON.stringify(value));
}

function usage() {
  const prog = Path.basename(process.argv[1])
  console.error(`usage: ${prog} INPUT_FILE`);
  process.exit(1);
}

class Token {
  constructor(kind, lexeme) {
    Object.assign(this, {kind, lexeme});
  }
}

class Ast {
  constructor(tag, ...kids) {
    Object.assign(this, {tag, kids});
  }
}
main();

