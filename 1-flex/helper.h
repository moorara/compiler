#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h> 
#include <string.h>
#include <math.h>


int st_len = 0;
char* st[1000];

char* copy_string(char* str) {
    int len = strlen(str) + 1;
    char* res = (char*)(malloc(len));
    for (int i = 0; i < len; i++)
        res[i] = str[i];
	res[len - 1] = 0;

	return res;
}

char* substring(char* str, int s, int l) {
    int len = strlen(str);
    if ((s + l) > len)
        return 0;

    char* res = (char*)(malloc(l + 1));
    for (int i = 0; i < l; i++)
        res[i] = str[s + i];
    res[l] = 0;

    return res;
}

char* int_to_string(unsigned int n) {
    if (n == 0) {
        char* zero = (char*)(malloc(2));
        zero[0] = '0'; // Zero character
        zero[1] =  0;  // Null character for end of string
        return zero;
    }

    unsigned int temp = n;
    int count = 0;
    while (temp !=0) {
        temp = temp / 10;
        count++;
    }

    int digit = 0;
    char* res = (char*)(malloc(count + 1));
    for (int i = (count - 1); i >= 0; i--) {
        digit = n % 10;
        n = n / 10;
        res[i] = (char)(digit + 48);
    }
    res[count] = 0;

    return res;
}

int process_id(char* lexeme) {
    for (int i = 0; i < st_len; i++)
        if (strcmp(st[i], lexeme) == 0)
            return	i;
    st[st_len++] = copy_string(lexeme);
    return st_len - 1;
}

unsigned int process_binary(char* lexeme) {
    int len = strlen(lexeme);
    unsigned int res = 0;
    for (int i = 2; i < len; i++)
        res = (res * 2) + (int)(lexeme[i]) - 48;
    return res;
}

unsigned int process_decimal(char* lexeme) {
    int len = strlen(lexeme);
    unsigned int res = 0;
    for (int i = 0; i < len; i++)
        res = (res * 10) + (int)(lexeme[i]) - 48;
    return res;
}

unsigned int process_hex(char* lexeme) {
    int len = strlen(lexeme);
    unsigned int res = 0;
    for (int i = 2; i < len; i++)
        if (lexeme[i] < '9')
            res = (res * 16) + (int)(lexeme[i]) - 48;
        else if (lexeme[i] < 'F')
            res = (res * 16) + (int)(lexeme[i]) - 55;
        else if (lexeme[i] < 'f')
            res = (res * 16) + (int)(lexeme[i]) - 87;
    return res;
}

float process_float(char* lexeme) {
    float res = 0;
    int len = strlen(lexeme);
    int dpos = -1, epos = len;
    for (int i = 0; i < len; i++)
        if (lexeme[i] == '.')
            dpos = i;
        else if (lexeme[i] == 'e')
            epos = i;

    int intv = 0;
    for (int i = 0; i < dpos; i++)
        intv = (intv * 10) + (int)(lexeme[i]) - 48;

    float floatv = 0;
    for (int i = (epos - 1); i > dpos; i--)
        floatv = (floatv / 10) + (int)(lexeme[i]) - 48;
    floatv = floatv / 10;

    int p = 0, f = 1;
    if (epos < len) {
        for (int i = (epos + 1); i < len; i++)
            if (lexeme[i] == '+')
                f = 1;
            else if (lexeme[i] == '-')
                f = -1;
            else
                p = (p * 10) + (int)(lexeme[i]) - 48;
        p = f * p;
    }

    res = (intv + floatv) * pow(10, p);
    return res;
}

char* process_char(char* lexeme) {
    int len = strlen(lexeme) + 1;
    return substring(lexeme, 1, len - 2);
}

char* process_simple_string(char* lexeme) {
    int len = strlen(lexeme);
    return substring(lexeme, 1, len - 2);
}

char* process_concat_string(char* lexeme) {
    int len = strlen(lexeme);
    int count = 0;
    bool parity = true;
    for (int i = 1; i < len; i++) {
        if ((lexeme[i - 1] != '\\') && (lexeme[i] == '\"'))
            parity = !parity;
        else if (parity == true)
            count++;
    }

    char* res = (char*)(malloc(count + 1));
    int j = 0;
    parity = true;
    for (int i = 1; i < len; i++) {
        if ((lexeme[i - 1] != '\\') && (lexeme[i] == '\"'))
            parity = !parity;
        else if (parity == true)
            res[j++] = lexeme[i];
    }

    res[count] = 0;

    return res;
}

char* process_single_comment(char* lexeme) {
    int len = strlen(lexeme);
    return substring(lexeme, 2, len - 2);
}

char* process_multi_comment(char* lexeme) {
    int len = strlen(lexeme);
    return substring(lexeme, 3, len - 6);
}

void process_token(char* lexeme, const char* token, const char* attribute) {
}


void print_string_out(char* lexeme, const char* token, const char* attribute) {
    printf("\033[0;0mLexeme:    \033[0;33m%s \n\033[0;0mToken:     \033[0;32m%s \n\033[0;0mAttribute: \033[0;36m%s \033[0;0m\n\n", lexeme, token, attribute);
}

void print_int_out(char* lexeme, const char* token, const int attribute) {
    printf("\033[0;0mLexeme:    \033[0;33m%s \n\033[0;0mToken:     \033[0;32m%s \n\033[0;0mAttribute: \033[0;36m%d \033[0;0m\n\n", lexeme, token, attribute);
}

void print_uint_out(char* lexeme, const char* token, const unsigned int attribute) {
    printf("\033[0;0mLexeme:    \033[0;33m%s \n\033[0;0mToken:     \033[0;32m%s \n\033[0;0mAttribute: \033[0;36m%u \033[0;0m\n\n", lexeme, token, attribute);
}

void print_float_out(char* lexeme, const char* token, const float attribute) {
    printf("\033[0;0mLexeme:    \033[0;33m%s \n\033[0;0mToken:     \033[0;32m%s \n\033[0;0mAttribute: \033[0;36m%f \033[0;0m\n\n", lexeme, token, attribute);
}
