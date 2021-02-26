export default {
  //$Ignore: /\s+/, 	//this will be ignored.
  $Ignore: /(\/\/.*)|\s+/,
  INT: /\d+/,      //token with kind INT   
  ID: /\w+/,      
  CHAR: /./       //single char: must be last
};
