#include <stdio.h>
#include "token.h"
#include "genasm.h"

void genimmediate(int imed, int reg)
{
    printf("movi\t%d\treg%d\t\t//move %d -> reg%d\n", imed, reg, imed, reg);
}

void genmov(int source, int dest)
{
    printf("mov\treg%d\treg%d\t\t//move reg%d -> reg%d\n", source, dest, source, dest);
}

void genmath(int operator, int lhs, int rhs, int dest)
{
    char symbol;
    char* inst;
    switch(operator)
    {
        case PLUSOP - OPERATOR_BIAS:
            symbol = '+';
            inst = "add";
            break;
        case MINUSOP - OPERATOR_BIAS:
            symbol = '-';
            inst = "sub";
            break;
        case TIMESOP - OPERATOR_BIAS:
            symbol = '*';
            inst = "mul";
            break;
        case DIVIDEOP - OPERATOR_BIAS:
            symbol = '/';
            inst = "div";
            break;
    }
    
    printf("%s\treg%d\treg%d\treg%d",inst,lhs,rhs,dest);
    printf("\t//reg%d %c reg%d -> reg%d\n", lhs,symbol,rhs,dest);

}
