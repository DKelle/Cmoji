/* takes a token, and returs a token with the negated value */
TOKEN negate(TOKEN tok);

/* applies the sign to tok */
TOKEN givesign(TOKEN sign, TOKEN tok);

/* Creates a duplicate token, with the same tokentype, and whichval/intval/etc  */
TOKEN copytok(TOKEN tok);

/* Makes a NUMBERTOK with intval val*/
TOKEN makenumbertok(int val);

/* Makes an OPERATOR token with whichval val*/
TOKEN makeoperatortok(int val);
/* parse.h     Gordon S. Novak Jr.    */
/* 16 Apr 04; 23 Feb 05; 17 Nov 05; 18 Apr 06; 26 Jul 12; 07 Aug 13 */

/* You may use the function headers below if you wish, or you may
   replace them if you wish.  */

/* cons links a new item onto the front of a list.  Equivalent to a push.
   (cons 'a '(b c))  =  (a b c)    */
TOKEN cons(TOKEN item, TOKEN list);

/* nconc concatenates two token lists, destructively, by making the last link
   of lista point to listb.
   (nconc '(a b) '(c d e))  =  (a b c d e)  */
/* nconc is useful for putting together two fieldlist groups to
   make them into a single list in a record declaration. */
TOKEN nconc(TOKEN lista, TOKEN listb);

/* binop links a binary operator op to two operands, lhs and rhs. */
TOKEN binop(TOKEN op, TOKEN lhs, TOKEN rhs);

/* makeop makes a new operator token with operator number opnum.
   Example:  makeop(FLOATOP)  */
TOKEN makeop(int opnum);

/* copytok makes a new token that is a copy of origtok */
TOKEN copytok(TOKEN origtok);

/* makeif makes an IF operator and links it to its arguments.
   tok is a (now) unused token that is recycled to become an IFOP operator */
TOKEN makeif(TOKEN tok, TOKEN exp, TOKEN thenpart, TOKEN elsepart);

/* dogoto is the action for a goto statement.
   tok is a (now) unused token that is recycled. */
TOKEN dogoto(TOKEN tok, TOKEN labeltok);

/* makelabel makes a new label, using labelnumber++ */
TOKEN makelabel();

/* dolabel is the action for a label of the form   <number>: <statement>
   tok is a (now) unused token that is recycled. */
TOKEN dolabel(TOKEN labeltok, TOKEN tok, TOKEN statement);

/* instlabel installs a user label into the label table */
void  instlabel (TOKEN num);

/* makegoto makes a GOTO operator to go to the specified label.
   The label number is put into a number token. */
TOKEN makegoto(int label);

/* makefuncall makes a FUNCALL operator and links it to the fn and args.
   tok is a (now) unused token that is recycled. */
TOKEN makefuncall(TOKEN tok, TOKEN fn, TOKEN args);

/* makewhile makes structures for a while statement.
   tok and tokb are (now) unused tokens that are recycled. */
TOKEN makewhile(TOKEN tok, TOKEN expr, TOKEN tokb, TOKEN statement);

/* makefor makes structures for a for statement.
   sign is 1 for normal loop, -1 for downto.
   asg is an assignment statement, e.g. (:= i 1)
   endexpr is the end expression
   tok, tokb and tokc are (now) unused tokens that are recycled. */
TOKEN makefor(int sign, TOKEN tok, TOKEN asg, TOKEN tokb, TOKEN endexpr,
              TOKEN tokc, TOKEN statement);

/* instconst installs a constant in the symbol table */
void  instconst(TOKEN idtok, TOKEN consttok);

/* instvars will install variables in symbol table.
   typetok is a token containing symbol table pointer for type. */
void  instvars(TOKEN idlist, TOKEN typetok);

/* makeplus makes a + operator.
   tok (if not NULL) is a (now) unused token that is recycled. */
TOKEN makeplus(TOKEN lhs, TOKEN rhs, TOKEN tok);

/* makes a constant given the sign and the  constant */
TOKEN makeconst(TOKEN sign, TOKEN tok);

/* talloc allocates a new TOKEN record. */
TOKEN talloc();

TOKEN makeloop(TOKEN range, TOKEN stmn);

TOKEN makestatement(TOKEN stmnt);

TOKEN makeprogn(TOKEN tkn, TOKEN prog);
