%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
  //  #include"lex.yy.c"
    
    void yyerror(const char *s);
    int yylex();
    int yywrap();
    void add(char);
    void insert_type();
int last_entry=0;
    int search(char *);
    void insert_type();
extern char* yytext;

    struct dataType {
        char * id_name;
        char * data_type;
        char * type;
       
		char * value;
    } symbol_table[100];

    int count=0;
    int q;
    char type[10];
    extern int countn;
%}
//https://github.com/Abdallah-Sobehy/compiler/blob/master/yacc.y
%define parse.error verbose
%token VOID CHARACTER PRINTFF SCANFF DEBUG INT CASE SWITCH BREAK FLOAT CHAR FOR WHILE IF ELSE TRUE FALSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT AND OR STR ADD MULTIPLY DIVIDE SUBTRACT UNARY INCLUDE RETURN 

%%

program: /* empty */ 
        | function
;
function: /* empty */
        | function main '(' ')' '{' body return '}';
		

 
headers: headers headers
| INCLUDE { add('H'); }
;

main: datatype ID { add('F'); }
;

datatype: INT { insert_type(); }
| FLOAT { insert_type(); }
| CHAR { insert_type(); }
| VOID { insert_type(); }
;

body: FOR { add('K'); } '(' statement ';' condition ';' statement ')' '{' body '}'
|WHILE { add('K'); } '(' condition ')' '{' body '}'
 |switchstatements
| IF { add('K'); } '(' condition ')' '{' body '}' else
| statement ';'
| body body 
| PRINTFF { add('K'); } '(' STR ')' ';'
| SCANFF { add('K'); } '(' STR ',' '&' ID ')' ';'
|DEBUG {printf("We are here");}
;
switchstatements: SWITCH { add('K'); } '(' ID   ')'   '{' casestatements  '}'
casestatements
	: CASE { add('K'); } NUMBER ':' body BREAK { add('K'); } ';'casestatements
	
	| {;}
	;
else: ELSE { add('K'); } '{' body '}'
|
;

condition: value relop value 
| TRUE { add('K'); }
| FALSE { add('K'); }
|
;

statement: datatype ID { add('V'); } init
| ID '=' expression
| ID relop expression
| ID UNARY
| UNARY ID
|error ';'
|error '}'
|error '{'

;

init: '=' value
|
;

expression: expression arithmetic expression
| value

;

arithmetic: ADD 
| SUBTRACT 
| MULTIPLY 
| DIVIDE

;

relop: LT
| GT
| LE
| GE
| EQ
| NE
;

value: NUMBER { add('C'); }
| FLOAT_NUM { add('C'); }
| CHARACTER { add('C'); }
| ID  
;

return: RETURN { add('K'); } value ';'
|
;

%%

int main() {
  yyparse();
  printf("\n\n");
	printf("\t\t\t\t\t\t\t\t PHASE 1: LEXICAL ANALYSIS \n\n");
	printf("\nSYMBOL   DATATYPE   TYPE    Value \n");
	printf("_______________________________________\n\n");
	int i=0;
	for(i=0; i<count; i++) {
		printf("%s\t%s\t%s\t%s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].value);
	}
	for(i=0;i<count;i++) {
		free(symbol_table[i].id_name);
		free(symbol_table[i].type);
	}
	printf("\n\n");
}

int search(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, type)==0) {
			return -1;
			break;
		}
	}
	return 0;
}

void add(char c) {
  /* q=search(yytext); */

    if(c == 'H') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			/* symbol_table[count].line_no=countn; */
			symbol_table[count].type=strdup("Header");
			
			count++;
		}
		else if(c == 'K') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("N/A");
			/* symbol_table[count].line_no=countn; */
			symbol_table[count].type=strdup("Keyword\t");
			count++;
		}
		else if(c == 'V') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			/* symbol_table[count].line_no=countn; */
			symbol_table[count].type=strdup("Variable");
			count++;
		}
		else if(c == 'C') {

			symbol_table[count-1].value=strdup(yytext);
			
			
		}
		else if(c == 'F') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			/* symbol_table[count].line_no=countn; */
			symbol_table[count].type=strdup("Function");
			count++;
		}
	
}

void insert_type() {
	strcpy(type, yytext);
}

void yyerror(const char* msg) {
  printf( "line %d: %s %s\n",countn, msg,yytext);
}