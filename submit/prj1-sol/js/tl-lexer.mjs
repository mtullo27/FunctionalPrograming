#!/usr/bin/env node

import fs from 'fs';
import Path from 'path';

/** Returns single char tokens with kind set to the char; i.e.
 *  '+' converts to Token('+', '+') with kind '+' and lexeme '+'.
 */
function scan(str) {
  const toks = [];
  let m;
  for (let s = str; s.length > 0; s = s.slice(m[0].length)) {
    if (m = s.match(/^\s+/)) { //s starts with whitespace
      continue; //skip whitespace
    }
    else if (m = s.match(/^#.*/)) {
      continue; //skip comments
    }
    else if (m = s.match(/(^<=)|(^>=)|(^==)|(^!=)/)) {
      toks.push(new Token(m[0], m[0]));
    }
    else if (m = s.match(/^\d+/)) { //one or more digits
      toks.push(new Token('INT', m[0]));
    }
    else if (m = s.match(/^[_a-zA-Z]\w*/)) {
      toks.push(new Token(m[0] === 'def' ? 'DEF' : 'ID', m[0]));
    }
    else if (m = s.match(/^./)) {  //any single char
      toks.push(new Token(m[0], m[0]));
    }
  }
  toks.push(new Token('<EOF>', '<EOF>'));
  return toks;
}

class Token {
  constructor(kind, lexeme) {
    Object.assign(this, {kind, lexeme});
  }
}

const CHAR_SET = 'utf8'
function main() {
  const text = fs.readFileSync(0, CHAR_SET);
  console.log(JSON.stringify(scan(text)));
}

function isRun() {
  const url = new URL(import.meta.url);
  const path = url.pathname;
  return (Path.basename(path) === Path.basename(process.argv[1]));
}
if (isRun()) main();

export default scan;

