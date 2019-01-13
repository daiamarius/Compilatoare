%{
	#include "y.tab.h"
	int lineNo = 1;
	int colNo = 1;
%}

%option yylineno

%%

"PROGRAM"			{ colNo+=strlen(yytext); return TOK_PROGRAM; }
"VAR"				{ colNo+=strlen(yytext); return TOK_VAR; }
"BEGIN"				{ colNo+=strlen(yytext); return TOK_BEGIN; }
"END"				{ colNo+=strlen(yytext); return TOK_END; }
"READ"				{ colNo+=strlen(yytext); return TOK_READ; }
"WRITE"				{ colNo+=strlen(yytext); return TOK_WRITE; }
"FOR"				{ colNo+=strlen(yytext); return TOK_FOR; }
"DO"				{ colNo+=strlen(yytext); return TOK_DO; }
"TO"				{ colNo+=strlen(yytext); return TOK_TO; }
"INTEGER"			{ colNo+=strlen(yytext); return TOK_INTEGER; }
":="				{ colNo+=strlen(yytext); return TOK_EQUALS; }
"+"				{ colNo++; return TOK_PLUS; }
"-"				{ colNo++; return TOK_MINUS; }
"*"				{ colNo++; return TOK_MULTIPLY; }
"("				{ colNo++; return TOK_LEFT; }
")"				{ colNo++; return TOK_RIGHT; }
","				{ colNo++; return ','; }
":"				{ colNo++; return ':'; }
"."				{ colNo++; return '.'; }
";"				{ colNo++; return ';'; }
0|[1-9][0-9]*			{ yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.val = atoi(yytext); return TOK_INT; }
[a-zA-Z][a-zA-Z0-9_]* { yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext); return TOK_ID;}
[ ]				{ colNo++; }
\r\n				{ lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
.				{ return TOK_ERROR; }


%%
