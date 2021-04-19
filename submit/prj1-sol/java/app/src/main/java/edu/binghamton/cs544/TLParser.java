package edu.binghamton.cs544;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

import edu.binghamton.cs544.TLLexer.Token;

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
class TLParser {
  private final List<Token> _tokens;
  Token _lookahead;
  private int _nextIndex;

  TLParser(List<Token> tokens) {
    _tokens = tokens;
    _nextIndex = 0;
    _lookahead = nextToken();
  }

  //Java parser derived by a cut-and-paste from the JS parser and a
  //few global replacements followed by some manual tweaking.

  //wrapper used for crude  error recovery
  List<Ast> parse() {
    var result = this.program();
    if (!check("<EOF>")) {
      die("expecting end-of-file at '" + _lookahead.lexeme + "`");
    }
    return result;
  }

  List<Ast> program() {
    List<Ast> asts = new ArrayList<>();
    while (!check("<EOF>")) {
      final var ast = (check("DEF")) ? def() : expr();
      asts.add(ast);
    }
    return asts;
  }

  Ast def() {
    match("DEF");
    final var tok = _lookahead;
    match("ID");
    var idAst = new Ast("ID");
    idAst.setId(tok.lexeme);
    match("(");
    final var formalsAst = formals();
    match(")");
    final var exprAst = expr();
    return new Ast("DEF", idAst, formalsAst, exprAst);
  }

  Ast formals() {
    final var idAsts = new ArrayList<Ast>();
    if (check("ID")) {
      final var id = _lookahead.lexeme;
      match("ID");
      final var idAst = new Ast("ID");
      idAst.setId(id);
      idAsts.add(idAst);
      while (check(",")) {
        match(",");
        final var id1 = _lookahead.lexeme;
        match("ID");
        final var id1Ast = new Ast("ID");
        id1Ast.setId(id1);
        idAsts.add(id1Ast);
      }
    }
    return new Ast("FORMALS", idAsts);
  }

  Ast expr() {
    return condExpr();
  }

  Ast condExpr() {
    var expr = relExpr();
    if (check("?")) {
      match("?");
      final var thenExpr = relExpr();
      match(":");
      final var elseExpr = condExpr();
      expr = new Ast("?:", expr, thenExpr, elseExpr);
    }
    return expr;
  }

  Ast relExpr() {
    var exprAst = addExpr();
    if (check("<") || check("<=") ||
        check(">") || check(">=") ||
        check("==") || check("!=")) {
      final var relOp = _lookahead.kind;
      match(relOp);
      final var addExprAst = addExpr();
      exprAst = new Ast(relOp, exprAst, addExprAst);
    }
    return exprAst;
  }

  Ast addExpr() {
    var exprAst = multExpr();
    while (check("+") || check("-")) {
      final var addOp = _lookahead.kind;
      match(addOp);
      final var multExprAst = multExpr();
      exprAst = new Ast(addOp, exprAst, multExprAst);
    }
    return exprAst;
  }

  Ast multExpr() {
    var exprAst = primaryExpr();
    while (check("*") || check("/")) {
      final var multOp = _lookahead.kind;
      match(multOp);
      final var primaryExprAst = primaryExpr();
      exprAst = new Ast(multOp, exprAst, primaryExprAst);
    }
    return exprAst;
  }


  Ast primaryExpr() {
    if (check("-")) {
      match("-");
      final var p = primaryExpr();
      return new Ast("-", p);
    }
    else if (_lookahead.kind == "INT") {
      final var lexeme = _lookahead.lexeme;
      match("INT");
      final var ast = new Ast("INT");
      ast.setValue(lexeme);
      return ast;
    }
    else if (check("(")) {
      match("(");
      final var e = expr();
      match(")");
      return e;
    }
    else {
      final var id = _lookahead.lexeme;
      match("ID");
      final var idAst = new Ast("ID");
      idAst.setId(id);
      if (check("(")) {
        match("(");
        final var actuals = actuals();
        match(")");
        return new Ast("APP", idAst, actuals);
      }
      else {
        return idAst;
      }
    }
  }

  Ast actuals() {
    final var exprAsts = new ArrayList<Ast>();
    if (!check(")")) {
      exprAsts.add(expr());
      while (check(",")) {
        match(",");
        exprAsts.add(expr());
      }
    }
    return new Ast("ACTUALS", exprAsts);
  }

  private Token nextToken() {
    return _tokens.get(_nextIndex++);
  }

  private boolean check(String kind) {
    return _lookahead.kind.equals(kind);
  }

  private void match(String kind) {
    if (check(kind)) {
      _lookahead = nextToken();
    }
    else {
      String msg = String.format("syntax error: expecting '%s' at '%s'",
                                 kind, _lookahead.lexeme);
      die(msg);
    }
  }

  private void die(String msg) {
    System.err.println(msg);
    System.exit(1);
  }

  static class Ast {
    private final String tag;
    private final Ast[] kids;
    private Integer _value;
    private String _id;
    Ast(String tag, Ast[] kids) {
      this.tag = tag; this.kids = kids;
    }
    Ast(String tag, List<Ast> kids) {
      this(tag, kids.toArray(new Ast[]{}));
    }
    Ast(String tag) { this(tag, new Ast[] {}); }
    Ast(String tag, Ast kid1) { this(tag, new Ast[] { kid1, }); }
    Ast(String tag, Ast kid1, Ast kid2) {
      this(tag, new Ast[] { kid1, kid2, });
    }
    Ast(String tag, Ast kid1, Ast kid2, Ast kid3) {
      this(tag, new Ast[] { kid1, kid2, kid3, });
    }

    void setId(String id) { this._id = id; }
    void setValue(String value) { this._value = Integer.parseInt(value); }

    JSONObject toJson() {
      JSONObject json = new JSONObject();
      try {
        json.put("tag", tag);
        JSONArray kidsJson = new JSONArray();
        for (Ast kid : kids) { kidsJson.put(kid.toJson()); }
        json.put("kids", kidsJson);
        if (_value != null) json.put("value", _value);
        if (_id != null) json.put("id", _id);
      }
      catch (Exception e) {
        throw new RuntimeException(e);
      }
      return json;
    }


  }


}
