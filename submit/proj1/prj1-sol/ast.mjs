#!/usr/bin/env node

import fs from 'fs';
import Path from 'path';


/* 
program
  : expr program
  | #empty
  ;
con
	:
	|rel ? rel : rel
	;
rel
	:
	|expr ( ( '<>!=' = ) expr )*
	;
expr
  : term ( ( '+' | '-' ) term )*
  ;
term
  : '-' term
  | factor '**' term
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
    const values = [];
    while (!check('EOF')) {
      values.push(con());
    }
    return values;
  }
	
	function con(){
		let r = rel();
		if(check('?')){
			match('?');
			let r1 = rel();
			match(':');
			let r2 = rel();
			r1 = new Ast(':', r1, r2);
			r = new Ast('?', r, r1);
		}
		return r;
	}
	
	function rel(){
		let e = expr();
    while (check('<=') || check('>=') || check('==') || check('!=') || check('>') || check('<')) {
      const kind = lookahead.kind;
      match(kind);   
      const e1 = expr();
      e = new Ast(kind, e, e1);
    }
    return e;
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
      let f = factor();
      if (check('*')) {
				match('*');
				f = new Ast('*', f, term());
      }
      else if (check('/')){
      	match ('/');
      	f = new AST('/', f, term());
      }
      return f;
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
      const value = con();
      match(')');
      return value;
    }
  }
}


function scan(text) {
  const tokens = [];
  while (text.length > 0) {
    let m;
    if ((m = text.match(/^(\s)+|^(#.*)/))) {
    }
    else if ((m = text.match(/"def"/))) {
      tokens.push(new Token('DEF', m[0]));
    }
    else if((m = text.match(/^(\?)+(:)/))){
			tokens.push(new Token(m[0], m[0]));
		}
		else if((m = text.match(/^((<)+(=))|((>)+(=))|((!)+(=))|((=)+(=))/))){
    	tokens.push(new Token(m[0], m[0]));
    }
    else if ((m = text.match(/^\d+/))) {
      tokens.push(new Token('INT', m[0]));
    }
    else if((m = text.match(/^\w+/))){
			tokens.push(new Token('ID', m[0]));
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
  const text = fs.readFileSync(0, CHAR_SET);
  const value = parse(text);
  fs.writeFileSync("ParseOutput.json", JSON.stringify(value));
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
