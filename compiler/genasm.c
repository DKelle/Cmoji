#include <stdio.h>
#include "token.h"
#include "genasm.h"

int DEBUG;
FILE *fout;

void openfile(int debug)
{

    DEBUG = debug;
    fout = fopen("a.cms", "w");
}

void closefile()
{
    fclose(fout);
}

void genimmediate(int imed, int reg)
{
    char asmout[100];
    sprintf(asmout,"\tmovi\t%d\treg%d\t\t//move %d -> reg%d\n", imed, reg, imed, reg);
    if(DEBUG)
        printf("%s",asmout);
    fputs(asmout, fout);
}

void genmov(int source, int dest)
{
    char asmout[100];
    sprintf(asmout, "\tmov\treg%d\treg%d\t\t//move reg%d -> reg%d\n", source, dest, source, dest);
    if(DEBUG)
        printf("%s", asmout);
    fputs(asmout, fout);
}

void genmath(int operator, int lhs, int rhs, int dest)
{
    char symbol;
    char* inst;
    char asmout[100];
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
    
    sprintf(asmout,"\t%s\treg%d\treg%d\treg%d\t//reg%d %c reg%d -> reg%d\n",inst,lhs,rhs,dest, lhs,symbol,rhs,dest);
    if(DEBUG)
        printf("%s", asmout);
    fputs(asmout, fout);
}

void genif(TOKEN operator, int lhs, int rhs, int label)
{
    char asmout[100];
    char asmout2[100];
    //we want to take the jump if the condition is false
    //Our only comparison instruction is jlt
    switch(operator->whichval)
    {
        case LEOP - OPERATOR_BIAS:
            sprintf(asmout, "\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d < reg%d jmp LABEL%d\n",rhs,lhs,label,rhs,lhs,label);
            break;
        case GEOP - OPERATOR_BIAS:
            sprintf(asmout, "\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d < reg%d jmp LABEL%d\n",lhs,rhs,label,lhs,rhs,label);
            break;
        case LTOP - OPERATOR_BIAS:
            sprintf(asmout, "\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d <= reg%d jmp LABEL%d\n",rhs,lhs,label,rhs,lhs,label);
            sprintf(asmout2, "\tjeq\treg%d\treg%d\tLABEL%d\t//\"\t\t\t\t\"\n",rhs,lhs,label);
            break;
        case GTOP - OPERATOR_BIAS:
            sprintf(asmout, "\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d <= reg%d jmp LABEL%d\n",lhs,rhs,label,lhs,rhs,label);
            sprintf(asmout2, "\tjeq\treg%d\treg%d\tLABEL%d\t//\"\t\t\t\t\"\n",lhs,rhs,label);
            break;
        case EQOP - OPERATOR_BIAS:
            sprintf(asmout, "\tjlt\treg%d\treg%d\tLABEL%d\t//if reg%d != reg%d jmp LABEL%d\n",lhs,rhs,label,lhs,rhs,label);
            sprintf(asmout2, "\tjlt\treg%d\treg%d\tLABEL%d\t//\"\t\t\t\t\"\n",rhs,lhs,label);
            break;
    }

    if(DEBUG)
    {
        printf("%s", asmout);
        if(operator->whichval == LTOP - OPERATOR_BIAS ||
           operator->whichval == GTOP - OPERATOR_BIAS ||
           operator->whichval == EQOP - OPERATOR_BIAS)
            printf("%s", asmout2);
    }
    fputs(asmout, fout);
    if(operator->whichval == LTOP - OPERATOR_BIAS ||
       operator->whichval == GTOP - OPERATOR_BIAS ||
       operator->whichval == EQOP - OPERATOR_BIAS)
        fputs(asmout2, fout);
}

void genjump(int label)
{
    char asmout[100];
    sprintf(asmout, "\tjmp\tLABEL%d\t\t\t//jump to LABEL%d\n", label, label);
    if(DEBUG)
        printf("%s", asmout);
    fputs(asmout, fout);
}

/* gen a label based off a given label number */
void genlabel(int label)
{
    char asmout[100];
    sprintf(asmout, ".LABEL%d\n", label);
    if(DEBUG)
        printf("%s", asmout);
    fputs(asmout, fout);
}

void genprint(int reg)
{
    char asmout[100];
    sprintf(asmout, "\tprint \treg%d\t\t\t//print reg%d\n", reg, reg);
    if(DEBUG)
        printf("%s", asmout);
    fputs(asmout, fout);
}

void genprintc(int num)
{
    char asmout[100];
    sprintf(asmout, "\tprintc \t%d\t\t\t//print constant %d\n", num, num);
    if(DEBUG)
        printf("%s", asmout);
    fputs(asmout, fout);
}

/* gena a halt */
void genhalt()
{
    char asmout[100];
    sprintf(asmout, "\thalt\t\t\t\t//halt\n");
    if(DEBUG)
        printf("%s", asmout);
    fputs(asmout, fout);
}
