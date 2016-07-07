/*gen a move immediate inst */
void genimmediate(int imed, int reg);

/* gen a mov inst */
void genmov(int source, int dest);

/*gen a math operation */
void genmath(int operator, int lhs, int rhs, int dest);

/* gen a jle inst from an if */
void genif(TOKEN operator, int lhs, int rhs, int label);

/* gen an absolue jump */
void genjump(int label);

/* gen a label to jump to later */
void genlabel(int label);

/*gen a print */
void genprint(int reg);

/* gen a halt */
void genhalt();

/*open the .cms file for the asm */
void openfile();

/* close the .cms file */
void closefile();
