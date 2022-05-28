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
void increase_scope();
void exit_scope();
    int search(char *);
    void insert_type();
extern char* yytext;

    struct dataType {
        char * id_name;
        char * data_type;
        char * type;
       int scope_id;
	   int scope_exit;
		char * value;
    } symbol_table[100];


struct scope_node {
      int scope_id;
	  char scope_variables[30];
    }*scope_head=NULL;


    int count=0;
	int scope=0;
    int q;
    char type[10];
    extern int countn;
	int temp=0;
	int label=0;
	int for_check;
	char intermediate[100][100];
	int inter_index=0;
	char buffer[50];
%}

%union{
char * str;
struct node{
	char name[100];
}node_;
struct code{
	char name[100];
	char if_body[5];
	char else_body[5];
}code_object;
}
//https://github.com/Abdallah-Sobehy/compiler/blob/master/yacc.y
%define parse.error verbose
%token<node_> VOID ID CHARACTER PRINTFF SCANFF DEBUG INT CASE SWITCH BREAK FLOAT CHAR FOR WHILE IF ELSE TRUE FALSE NUMBER FLOAT_NUM  LE GE EQ NE GT LT AND OR STR ADD MULTIPLY DIVIDE SUBTRACT UNARY INCLUDE RETURN 

%type <node_> headers main body return datatype expression statement init value arithmetic relop program  else
%type<code_object>condition
%%

program: /* empty */ 
        | function
;
function: /* empty */
        | function main '(' ')' '{' {increase_scope();}body return '}'{ exit_scope();};
	
		

 
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

body: FOR { add('K'); for_check = 1;} '(' statement ';' condition ';' statement ')' '{'{increase_scope();} body '}'{ exit_scope();  
  sprintf(intermediate[inter_index++], buffer); 
    sprintf(intermediate[inter_index++], "JUMP to %s\n", $6.if_body);
    sprintf(intermediate[inter_index++], "\nLABEL %s:\n", $6.else_body);
}
|WHILE { add('K'); } '(' condition ')' '{'{increase_scope();}  body '}'{ exit_scope();}
 |switchstatements
| IF { add('K'); for_check = 0;} '(' condition ')'  { sprintf(intermediate[inter_index++], "\nLABEL %s:\n", $4.if_body); }'{' {increase_scope();} body '}' { sprintf(intermediate[inter_index++], "\nLABEL %s:\n", $4.else_body); }{ exit_scope();} else
{ 
	
	sprintf(intermediate[inter_index++], "GOTO next\n");
}
| statement ';'
| body body 
| PRINTFF { add('K'); } '(' STR ')' ';'
| SCANFF { add('K'); } '(' STR ',' '&' ID ')' ';'
|DEBUG {printf("We are here");}
;
switchstatements: SWITCH { add('K'); } '(' ID   ')'   '{' {increase_scope();} casestatements  '}'{ exit_scope();}
casestatements
	: CASE { add('K'); } NUMBER ':' body BREAK { add('K'); } ';'casestatements
	
	| {;}
	;
else: ELSE { add('K'); } '{'{increase_scope();}  body '}'{ exit_scope();}
|
;

condition: value relop value 
{ if(for_check) {  
        sprintf($$.if_body, "L%d", label++);  
        sprintf(intermediate[inter_index++], "\nLABEL %s:\n", $$.if_body);
        sprintf(intermediate[inter_index++], "\nif NOT (%s %s %s) GOTO L%d\n", $1.name, $2.name, $3.name, label);  
        sprintf($$.else_body, "L%d", label++); 
    } 
    else {  
        sprintf(intermediate[inter_index++], "\nif (%s %s %s) GOTO L%d else GOTO L%d\n", $1.name, $2.name, $3.name, label, label+1);
        sprintf($$.if_body, "L%d", label++);  
        sprintf($$.else_body, "L%d", label++); 
    }}
| TRUE { add('K'); }
| FALSE { add('K'); }
|
;

statement: datatype ID { add('V'); } init
{  
sprintf(intermediate[inter_index++], "%s = %s\n", $2.name, $4.name);
	}
| ID '=' expression{ sprintf(intermediate[inter_index++], "%s = %s\n", $1.name, $3.name);}
| ID relop expression
| ID UNARY  {
	if(!strcmp($2.name, "++")) {
		sprintf(buffer, "t%d = %s + 1\n%s = t%d\n", temp, $1.name, $1.name, temp);
	}
	else {
		sprintf(buffer, "t%d = %s + 1\n%s = t%d\n", temp, $1.name, $1.name, temp);
	}}
| UNARY ID{if(!strcmp($1.name, "++")) {
		sprintf(buffer, "t%d = %s + 1\n%s = t%d\n", temp, $2.name, $2.name, temp++);
	}
	else {
		sprintf(buffer, "t%d = %s - 1\n%s = t%d\n", temp, $2.name, $2.name, temp++);

	}}


;

init: '=' value{strcpy($$.name, $2.name); }
|{strcpy($$.name, "NULL");}
;

expression: expression arithmetic expression{sprintf($$.name, "t%d", temp);
	temp++;
	sprintf(intermediate[inter_index++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);}
| value { strcpy($$.name, $1.name); }

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

value: NUMBER { add('C');  strcpy($$.name, $1.name);}
| FLOAT_NUM { add('C');  strcpy($$.name, $1.name);}
| CHARACTER { add('C');  strcpy($$.name, $1.name);}
| ID  { strcpy($$.name, $1.name);}
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
		printf("%s\t%s\t%s\t%s\t%d\t%d\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].value,symbol_table[i].scope_id,symbol_table[i].scope_exit);
	}
	for(i=0;i<count;i++) {
		free(symbol_table[i].id_name);
		free(symbol_table[i].type);
	}
	printf("\n\n");

	printf("\t\t\t\t\t\t\t   PHASE 4: INTERMEDIATE CODE GENERATION \n\n");
	for(int i=0; i<inter_index; i++){
		printf("%s", intermediate[i]);
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
void increase_scope(){
	scope=scope+1;
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
		//adding variables
		else if(c == 'V') {
           int found=0;
			for(int i=0;i<count;i++)
			{    
				if(symbol_table[i].scope_id==scope)
				{ 
					if(strcmp(symbol_table[i].id_name,strdup(yytext) )==0)
					{
			
                       found=1;
					}
				}
			}
			if(found==0)
			{symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			/* symbol_table[count].line_no=countn; */
			symbol_table[count].type=strdup("Variable");

			count++;
			}
			else{
			
			}
		}
		else if(c == 'C') {
			char * t=strdup("Variable");
            if(strcmp(symbol_table[count-1].type,t )==0)
			{
				symbol_table[count-1].value=strdup(yytext);
			symbol_table[count-1].scope_id=scope;
			}
			
			
		}
		else if(c == 'F') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			/* symbol_table[count].line_no=countn; */
			symbol_table[count].type=strdup("Function");
						symbol_table[count].scope_id=scope;
			count++;
		}
	
}

void insert_type() {
	strcpy(type, yytext);
}
void exit_scope(){
	for(int i=0;i<count;i++)
	{
		if(symbol_table[i].scope_id==scope)
		{
			symbol_table[i].scope_exit=-1;
		}
	}
	scope--;
}
void yyerror(const char* msg) {
  printf( "line %d: %s %s\n",countn, msg,yytext);
}