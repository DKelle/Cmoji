
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

    while ((read = getline(&line, &len, stdin)) != -1) {
        printf("Retrieved line of length %zu :\n", read);
        printf("%s", line);
    }

    if (line)
        free(line);
    exit(EXIT_SUCCESS);
}

/*
char *get_utf8_input()
{
    char *line, *u8s;
    unsigned int *wcs;
    int len;

    size_t linelen = 0;
    ssize_t read;

    while ((read = getline(&line, &linelen, stdin)) != -1)
    {
        printf("Retrieved line of length %zu :\n", read);
        printf("%s", line);
    

    len = mbstowcs(NULL, line, 0)+1;
    wcs = malloc(len * sizeof(int));
    mbstowcs(wcs, line, len);
    u8s = malloc(len * sizeof(int));
    u8_toutf8(u8s, len*sizeof(int), wcs, len);
    free(line);
    free(wcs);
    printf("returning string: %s\n",u8s);
    }
    return u8s;
    
}*/
