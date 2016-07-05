/*gen a move immediate inst */
void genimmediate(int imed, int reg);

/* gen a mov inst */
void genmov(int source, int dest);

/*gen a math operation */
void genmath(int operator, int lhs, int rhs, int dest);
