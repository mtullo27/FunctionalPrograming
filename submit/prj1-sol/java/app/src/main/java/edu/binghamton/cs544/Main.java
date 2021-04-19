package edu.binghamton.cs544;

import java.io.BufferedReader;
import java.io.InputStreamReader;

import org.json.JSONArray;

import edu.binghamton.cs544.TLLexer;
import edu.binghamton.cs544.TLParser;

public class Main {

  public static void main(String[] args) {
    var lexer = new TLLexer();
    var text = Main.readStdin();
    var tokens = lexer.scan(text);
    JSONArray json = new JSONArray();
    if (args.length == 0) {
      for (TLLexer.Token t : tokens) json.put(t.map());
    }
    else {
      TLParser parser = new TLParser(tokens);
      var asts = parser.parse();
      for (var ast : asts) json.put(ast.toJson());
    }
    System.out.println(json);
  }

  private static String readStdin() {
    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    var content = "";
    try {
      var line = "";
      while ((line = br.readLine()) != null) content += line + "\n";
    }
    catch (Exception e) {
      System.err.println(e.toString());
      System.exit(1);
    }
    return content;
  }

}
