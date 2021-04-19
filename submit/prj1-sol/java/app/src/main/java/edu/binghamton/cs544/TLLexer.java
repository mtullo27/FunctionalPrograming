package edu.binghamton.cs544;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class TLLexer {

  //double-brace initialization idiom
  private static final List<Pair<String, Pattern>> REGEXS =
    new ArrayList<>() {
      {
        add(new Pair("WS", Pattern.compile("\\s+")));
        add(new Pair("COMMENT", Pattern.compile("#.*")));
        add(new Pair("MULTI_OP", Pattern.compile("<=|>=|==|!=")));
        add(new Pair("INT", Pattern.compile("\\d+")));
        add(new Pair("ID", Pattern.compile("[a-zA-Z_]\\w*")));
        add(new Pair("CHAR", Pattern.compile(".")));
      }
    };

  static Pair<String, Matcher> nextMatch(String text) {
    for (var pair : REGEXS) {
      Matcher m = pair.val2.matcher(text);
      if (m.lookingAt()) return new Pair(pair.val1, m);
    }
    return null;
  }

  List<Token> scan(String text) {
    List<Token> tokens = new ArrayList<>();
    while (text.length() > 0) {
      var pair = nextMatch(text);
      var kind = pair.val1;
      var matcher = pair.val2;
      String lexeme = text.substring(0, matcher.end());
      if (!kind.equals("WS") && !kind.equals("COMMENT")) {
        if (kind.equals("MULTI_OP") || kind.equals("CHAR")) kind = lexeme;
        if (lexeme.equals("def")) kind = "DEF";
        tokens.add(new Token(kind, lexeme));
      }
      text = text.substring(lexeme.length());
    }
    tokens.add(new Token("<EOF>", "<EOF>"));
    return tokens;
  }

  static class Token {
    final String kind;
    final String lexeme;

    Token(String kind, String lexeme) {
      this.kind = kind; this.lexeme = lexeme;
    }
    public String toString() {
      return String.format("{kind:\"%s\", lexeme:\"%s\"}",
                           this.kind, this.lexeme);
    }
    Map<String, String> map() { //to keep JSON happy
      var map = new HashMap<String, String>(2);
      map.put("kind", this.kind);
      map.put("lexeme", this.lexeme);
      return map;
    }
  }

  static class Pair<T1, T2> {
    final T1 val1;
    final T2 val2;
    Pair(T1 v1, T2 v2) { val1 = v1; val2 = v2; }
  }

}
