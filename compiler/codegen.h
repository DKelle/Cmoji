/* Generate arithmetic expression, return a register number */
int genarith(TOKEN code, int dest);

/* Generate code for a statement */
void genc(TOKEN code);

void genoperator(TOKEN code);

void init();

/*used to find an open register to generate code into */
int getreg();

/*Generate some arithmetic expression into a register, and return the register */
int genarith();

/* Make a register available for use again */
void openreg(int reg);

void genmove(int src, int dest);

int getlabel();
