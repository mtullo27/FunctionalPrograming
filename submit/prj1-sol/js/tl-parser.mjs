#!/usr/bin/env node

import scan from './tl-lexer.mjs';

import fs from 'fs';
import Path from 'path';

/**
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
 */

class TlParser {
  constructor(tokens) {
    this._tokens = tokens;
    this._index = -1;
    this.lookahead = undefined;
    this._nextToken();
  }

  //wrapper used for crude  error recovery
  parse() {
    try {
      let result = this.program();
      if (!this.check('<EOF>')) {
	const msg = `expecting end-of-file at "${this.lookahead.lexeme}"`;
	throw new SyntaxError(msg);
      }
      return result;
    }
    catch (err) {
      return err;
    }
  }

  check(kind) {
    return this.lookahead.kind === kind;
  }
  
  match(kind) {
    if (this.check(kind)) {
      this._nextToken();
    }
    else {
      const msg = `expecting ${kind} at "${this.lookahead.lexeme}"`;
      throw new SyntaxError(msg);
    }
  }

  _nextToken() {
    if (this._index < this._tokens.length - 1) {
      this._index++;
      this.lookahead  = this._tokens[this._index];
    }
    else {
      this.lookahead = null;
    }
  }
  

  program() {
    const asts = [];
    while (!this.check('<EOF>')) {
      const ast = (this.check('DEF')) ? this.def() : this.expr();
      asts.push(ast);
    }
    return asts;
  }

  def() {
    this.match('DEF');
    const tok = this.lookahead;
    this.match('ID');
    const idAst = new Ast('ID');
    idAst.id = tok.lexeme;
    this.match('(');
    const formalsAst = this.formals();
    this.match(')');
    const exprAst = this.expr();
    return new Ast('DEF', idAst, formalsAst, exprAst);
  }

  formals() {
    const idAsts = [];
    if (this.check('ID')) {
      const id = this.lookahead.lexeme;
      this.match('ID');
      const idAst = new Ast('ID');
      idAst.id = id;
      idAsts.push(idAst);
      while (this.check(',')) {
	this.match(',');
	const id = this.lookahead.lexeme;
	this.match('ID');
	const idAst = new Ast('ID');
	idAst.id = id;
	idAsts.push(idAst);
      }
    }
    return new Ast('FORMALS', ...idAsts);
  }

  expr() {
    return this.condExpr();
  }

  condExpr() {
    let expr = this.relExpr();
    if (this.check('?')) {
      this.match('?');
      const thenExpr = this.relExpr();
      this.match(':');
      const elseExpr = this.condExpr();
      expr = new Ast('?:', expr, thenExpr, elseExpr);
    }
    return expr;
  }

  relExpr() {
    let exprAst = this.addExpr();
    if (this.check('<') || this.check('<=') ||
	this.check('>') || this.check('>=') ||
	this.check('==') || this.check('!=')) {
      const relOp = this.lookahead.kind;
      this.match(relOp);
      const addExprAst = this.addExpr();
      exprAst = new Ast(relOp, exprAst, addExprAst);
    }
    return exprAst;
  }

  addExpr() {
    let exprAst = this.multExpr();
    while (this.check('+') || this.check('-')) {
      const addOp = this.lookahead.kind;
      this.match(addOp);
      const multExprAst = this.multExpr();
      exprAst = new Ast(addOp, exprAst, multExprAst);
    }
    return exprAst
  }

  multExpr() {
    let exprAst = this.primaryExpr();
    while (this.check('*') || this.check('/')) {
      const multOp = this.lookahead.kind;
      this.match(multOp);
      const primaryExprAst = this.primaryExpr();
      exprAst = new Ast(multOp, exprAst, primaryExprAst);
    }
    return exprAst
  }


  primaryExpr() {
    if (this.check('-')) {
      this.match('-');
      const p = this.primaryExpr();
      return new Ast('-', p);
    }
    else if (this.lookahead.kind == 'INT') {
      const lexeme = this.lookahead.lexeme;
      this.match('INT');
      const ast = new Ast('INT');
      ast.value = Number.parseInt(lexeme);
      return ast;
    }
    else if (this.check('(')) {
      this.match('(');
      const e = this.expr();
      this.match(')');
      return e;
    }
    else {
      const id = this.lookahead.lexeme;
      this.match('ID');
      const idAst = new Ast('ID');
      idAst.id = id;
      if (this.check('(')) {
	this.match('(');
	const actuals = this.actuals();
	this.match(')');
	return new Ast('APP', idAst, actuals);
      }
      else {
	return idAst;
      }
    }
  }

  actuals() {
    const exprAsts = [];
    if (!this.check(')')) {
      exprAsts.push(this.expr());
      while (this.check(',')) {
	this.match(',');
	exprAsts.push(this.expr());
      }
    }
    return new Ast('ACTUALS', ...exprAsts);
  }



} //AstParser

class Ast {
  constructor(tag, ...kids) {
    this.tag = tag;
    this.kids = kids;
  }
}

const CHAR_SET = 'utf8'
function main() {
  const text = fs.readFileSync(0, CHAR_SET);
  const tokens = scan(text);
  const parser = new TlParser(tokens);
  const result = parser.parse();
  if (result instanceof Error) {
    console.error(result.message);
  }
  else {
    console.log(JSON.stringify(result));
  }
}

main();

