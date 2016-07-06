#include <stdio.h>
#include "token.h"
#include "genasm.h"

void genimmediate(int imed, int reg)
{
    printf("\tmovi\t%d\treg%d\t\t//move %d -> reg%d\n", imed, reg, imed, reg);
}

void genmov(int source, int dest)
{
    printf("\tmov\treg%d\treg%d\t\t//move reg%d -> reg%d\n", source, dest, source, dest);
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
    
    printf("\t%s\treg%d\treg%d\treg%d",inst,lhs,rhs,dest);
    printf("\t//reg%d %c reg%d -> reg%d\n", lhs,symbol,rhs,dest);

}

void genif(TOKEN operator, int lhs, int rhs, int label)
{
    //we want to take the jump if the condition is false
    //Our only comparison instruction is jlt
    switch(operator->whichval)
    {
        case LEOP - OPERATOR_BIAS:
            //rhs < lhs
            printf("\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d < reg%d jmp LABEL%d\n",rhs,lhs,label,rhs,lhs,label);
            break;
        case GEOP - OPERATOR_BIAS:
            printf("\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d < reg%d jmp LABEL%d\n",lhs,rhs,label,lhs,rhs,label);
            break;
        case LTOP - OPERATOR_BIAS:
            printf("\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d <= reg%d jmp LABEL%d\n",rhs,lhs,label,rhs,lhs,label);
            printf("\tjeq\treg%d\treg%d\tLABEL%d\t//\"\t\t\t\"\n",rhs,lhs,label);
            break;
        case GTOP - OPERATOR_BIAS:
            printf("\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d <= reg%d jmp LABEL%d\n",lhs,rhs,label,lhs,rhs,label);
            printf("\tjeq\treg%d\treg%d\tLABEL%d\t//\"\t\t\t\"\n",lhs,rhs,label);
            break;
        case EQOP - OPERATOR_BIAS:
            printf("\tjeq\treg%d\treg%d\t\tLABEL%d\t",lhs,rhs,label);
            break;
    }
}

void genjump(int label)
{
    printf("\tjmp\tLABEL%d\t\t\t//Jump to LABEL %d\n", label, label);
}

void genlabel(int label)
{
    printf(".LABEL%d\n", label);
}

void genprint(int reg)
{
    printf("\tprint \treg%d\t\t\t//print reg%d\n", reg, reg);
}

/* gena a halt */
void genhalt()
{
    printf("\thalt\t\t\t\t//halt\n");
}
