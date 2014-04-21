/*
 * CS250
 *
 * simple.l: simple parser for the simple "C" language
 *
 */

%token	<string_val> WORD

%token 	NOTOKEN LPARENT RPARENT LBRACE RBRACE LCURLY RCURLY COMA SEMICOLON EQUAL STRING_CONST LONG LONGSTAR VOID CHARSTAR CHARSTARSTAR INTEGER_CONST AMPERSAND OROR ANDAND EQUALEQUAL NOTEQUAL LESS GREAT LESSEQUAL GREATEQUAL PLUS MINUS TIMES DIVIDE PERCENT IF ELSE WHILE DO FOR CONTINUE BREAK RETURN

%union	{
		char   *string_val;
		int nargs;
		int my_nlabel;
	}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_number;
const char * input_file;
char * asm_file;
FILE * fasm;

#define MAX_ARGS 5
int nargs;
char * args_table[MAX_ARGS];

#define MAX_GLOBALS 100
int nglobals = 0;
char * global_vars_table[MAX_GLOBALS];

#define MAX_STRINGS 100
int nstrings = 0;
char * string_table[MAX_STRINGS];

#define MAX_LOCALS 32
int nlocals = 0;
char * local_vars_table[MAX_LOCALS];

char *regStk[]={ "rbx", "r10", "r13", "r14", "r15"};
char nregStk = sizeof(regStk)/sizeof(char*);

char *regLowerStk[]={"bl","r10b","r13b","r14b","r15b"};
char *regArgs[]={ "rdi", "rsi", "rdx", "rcx", "r8", "r9"};
char nregArgs = sizeof(regArgs)/sizeof(char*);


int top = 0;
int jumpnum=0;
int charstar =0;
int global_char_star[MAX_GLOBALS];
int local_char_star[MAX_LOCALS];
int nargs =0;
int innerloop=0; 
int nlabel = 0;

%}

%%

goal:	program
	;

program :
        function_or_var_list;

function_or_var_list:
        function_or_var_list function
        | function_or_var_list global_var
        | /*empty */
	;

function:
         var_type WORD
         {
		nlocals=0;
		 fprintf(fasm, "\t.text\n");
		 fprintf(fasm, ".globl %s\n", $2);
		 fprintf(fasm, "%s:\n", $2);

		 fprintf(fasm, "# Save registers\n");
		 fprintf(fasm, "\tpushq %%rbx\n");
		 fprintf(fasm, "\tpushq %%r10\n");
		 fprintf(fasm, "\tpushq %%r13\n");
		 fprintf(fasm, "\tpushq %%r14\n");
		 fprintf(fasm, "\tpushq %%r15\n");

		fprintf(fasm,"\n");
		fprintf(fasm,"\tsubq $256, %%rsp\n");
	 }
	 LPARENT arguments RPARENT compound_statement
         {

		fprintf(fasm,"\taddq $256, %rsp");
		nargs=0;
		 fprintf(fasm, "# Restore registers\n");
		 fprintf(fasm, "\tpopq %%r15\n");
		 fprintf(fasm, "\tpopq %%r14\n");
		 fprintf(fasm, "\tpopq %%r13\n");
		 fprintf(fasm, "\tpopq %%r10\n");
		 fprintf(fasm, "\tpopq %%rbx\n");
		 fprintf(fasm, "\tret\n");
		top=0;
         }
	;

arg_list:
         arg
         | arg_list COMA arg
	 ;

arguments:
         arg_list{
		int i;
                for (i=0; i<nargs; i++){
                        local_vars_table[i] = args_table[i];
                        nlocals++;
                        fprintf(fasm, "\tmovq %%%s, %d(%%rsp)\n",regArgs[i],i*8);
                }
	}
	 | /*empty*/
	 ;

arg: var_type WORD{
local_char_star[nargs] = charstar;
args_table[nargs] = $<string_val>2;
nargs++;
};

global_var: 
        var_type global_var_list SEMICOLON;

global_var_list: WORD {
	global_vars_table[nglobals] = $<string_val>1;
	global_char_star[nglobals]=charstar;
	nglobals++;       
	fprintf(fasm,"\t.data\n");
	fprintf(fasm,"%s:\n",$<string_val>1);
	fprintf(fasm,".long 0\n");
	fprintf(fasm,".long 0\n");
 }
| global_var_list COMA WORD {
	global_vars_table[nglobals] = $<string_val>3;
	global_char_star[nglobals]=charstar;
	nglobals++;
	fprintf(fasm,"%s:\n",$<string_val>3);
	fprintf(fasm,".long 0\n");
	fprintf(fasm,".long 0\n");
}
        ;

var_type: CHARSTAR{charstar = 1;} | CHARSTARSTAR{charstar=0;} | LONG{charstar=0;} | LONGSTAR{charstar=0;} | VOID{charstar=0;};

assignment:
         WORD EQUAL expression{
		char *id = $<string_val>1;
		int i;
		for (i = 0; i<nlocals; i++){
			if(strcmp(id,local_vars_table[i])==0){
				fprintf(fasm,"\tmovq %%%s, %d(%%rsp)\n",regStk[top-1],8*i);
				top--;
				break;
			}

		}
		for (i=0; i<nglobals; i++){
			if(strcmp(id,global_vars_table[i])==0){
				fprintf(fasm, "\tmovq %%%s, %s\n",regStk[top-1],id);
				top--;
			}
		}
	}
	 | WORD LBRACE expression RBRACE EQUAL expression{
		char *id = $<string_val>1;
		int i;
		for (i=0; i<nlocals; i++){
			if(strcmp(id,local_vars_table[i])==0){
				if(!local_char_star[i]){
					fprintf(fasm, "\timulq $8, %%%s\n", regStk[top-2]);
				}
				fprintf(fasm, "\taddq %d(%%rsp), %%%s\n", 8*i, regStk[top-2]);
				fprintf(fasm, "\tmovq %%%s,(%%%s)\n", regStk[top-1],regStk[top-2]);
				top-=2;
			}
		}
		for (i=0; i<nglobals;i++){
			if(strcmp(id,global_vars_table[i])==0){
				if(!global_char_star[i]){
					fprintf(fasm, "\timulq $8, %%%s\n",regStk[top-2]);
				}
				fprintf(fasm,"\taddq %s, %%%s\n", id, regStk[top-2]);
				fprintf(fasm,"\tmovq %%%s,(%%%s)\n",regStk[top-1],regStk[top-2]);
				top-=2;
			}
		}
	}
	 ;

call :
         WORD LPARENT  call_arguments RPARENT {
		 char * funcName = $<string_val>1;
		 int nargs = $<nargs>3;
		 int i;
		 fprintf(fasm,"     # func=%s nargs=%d\n", funcName, nargs);
     		 fprintf(fasm,"     # Move values from reg stack to reg args\n");
		 for (i=nargs-1; i>=0; i--) {
			top--;
			fprintf(fasm, "\tmovq %%%s, %%%s\n",
			  regStk[top], regArgs[i]);
		 }
		 if (!strcmp(funcName, "printf")) {
			 // printf has a variable number of arguments
			 // and it need the following
			 fprintf(fasm, "\tmovl    $0, %%eax\n");
		 }
		 fprintf(fasm, "\tcall %s\n", funcName);
		 fprintf(fasm, "\tmovq %%rax, %%%s\n", regStk[top]);
		 top++;
         }
      ;

call_arg_list:
         expression {
		$<nargs>$=1;
	 }
         | call_arg_list COMA expression {
		$<nargs>$++;
	 }

	 ;

call_arguments:
         call_arg_list { $<nargs>$=$<nargs>1; }
	 | /*empty*/ { $<nargs>$=0;}
	 ;

expression :
         logical_or_expr
	 ;

logical_or_expr:
         logical_and_expr
	 | logical_or_expr OROR logical_and_expr{
		fprintf(fasm,"\n\t# +\n");
		if (top<nregStk){
			fprintf(fasm,"\torq %%%s, %%%s \n",
				regStk[top-1],regStk[top-2]);
			top--;

		}
	}
	 ;

logical_and_expr:
         equality_expr
	 | logical_and_expr ANDAND equality_expr{
		fprintf(fasm,"\n\t# +\n");
		if(top<nregStk){
			fprintf(fasm,"\tandq %%%s, %%%s \n",
				regStk[top-1],regStk[top-2]);
			top--;
		}
	}
	 ;

equality_expr:
         relational_expr
	 | equality_expr EQUALEQUAL relational_expr{
		fprintf(fasm,"\n\t# +\n");
		if (top<nregStk){
			jumpnum++;
			fprintf(fasm, "\tcmp %%%s,%%%s\n", regStk[top-1],regStk[top-2]);
			fprintf(fasm, "\tjne jmpspot%d\n",jumpnum-1);
			fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
			fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
			fprintf(fasm,"\tmovq $0, %%%s\n",regStk[top-2]);
			jumpnum++;
			fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
			fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
			fprintf(fasm,"\tmovq $1, %%%s\n",regStk[top-2]);
			fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
			fprintf(fasm,"jmpspot%d:\n",jumpnum);
			jumpnum++;
			top--;
		}

	}
	 | equality_expr NOTEQUAL relational_expr{
      		 fprintf(fasm,"\n\t# +\n");
                if (top<nregStk){
                        jumpnum++;
                        fprintf(fasm, "\tcmp %%%s,%%%s\n", regStk[top-1],regStk[top-2]);
                        fprintf(fasm, "\tjne jmpspot%d\n",jumpnum-1);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $1, %%%s\n",regStk[top-2]);
                        jumpnum++;
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $0, %%%s\n",regStk[top-2]);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum);
                        jumpnum++;
                        top--;
                }

	}
	 ;

relational_expr:
         additive_expr
	 | relational_expr LESS additive_expr{
	       fprintf(fasm,"\n\t# +\n");
                if (top<nregStk){
                        jumpnum++;
                        fprintf(fasm, "\tcmp %%%s,%%%s\n", regStk[top-1],regStk[top-2]);
                        fprintf(fasm, "\tjl jmpspot%d\n",jumpnum-1);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $1, %%%s\n",regStk[top-2]);
                        jumpnum++;
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $0, %%%s\n",regStk[top-2]);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum);
                        jumpnum++;
                        top--;
                }

	}
	 | relational_expr GREAT additive_expr{
	       fprintf(fasm,"\n\t# +\n");
                if (top<nregStk){
                        jumpnum++;
                        fprintf(fasm, "\tcmp %%%s,%%%s\n", regStk[top-1],regStk[top-2]);
                        fprintf(fasm, "\tjg jmpspot%d\n",jumpnum-1);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $1, %%%s\n",regStk[top-2]);
                        jumpnum++;
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $0, %%%s\n",regStk[top-2]);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum);
                        jumpnum++;
                        top--;
                }

	}
	 | relational_expr LESSEQUAL additive_expr{
	       fprintf(fasm,"\n\t# +\n");
                if (top<nregStk){
                        jumpnum++;
                        fprintf(fasm, "\tcmp %%%s,%%%s\n", regStk[top-1],regStk[top-2]);
                        fprintf(fasm, "\tjle jmpspot%d\n",jumpnum-1);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $1, %%%s\n",regStk[top-2]);
                        jumpnum++;
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $0, %%%s\n",regStk[top-2]);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum);
                        jumpnum++;
                        top--;
                }

	}
	 | relational_expr GREATEQUAL additive_expr{
	       fprintf(fasm,"\n\t# +\n");
                if (top<nregStk){
                        jumpnum++;
                        fprintf(fasm, "\tcmp %%%s,%%%s\n", regStk[top-1],regStk[top-2]);
                        fprintf(fasm, "\tjge jmpspot%d\n",jumpnum-1);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $1, %%%s\n",regStk[top-2]);
                        jumpnum++;
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum-1);
                        fprintf(fasm,"\tmovq $0, %%%s\n",regStk[top-2]);
                        fprintf(fasm,"\tjmp jmpspot%d\n",jumpnum);
                        fprintf(fasm,"jmpspot%d:\n",jumpnum);
                        jumpnum++;
                        top--;
                }

	}
	 ;

additive_expr:
          multiplicative_expr
	  | additive_expr PLUS multiplicative_expr {
		fprintf(fasm,"\n\t# +\n");
		if (top<nregStk) {
			fprintf(fasm, "\taddq %%%s,%%%s\n", 
				regStk[top-1], regStk[top-2]);
			top--;
		}
	  }
	  | additive_expr MINUS multiplicative_expr {
                fprintf(fasm,"\n\t# +\n");
                if (top<nregStk) {
                        fprintf(fasm, "\tsubq %%%s,%%%s\n",
                                regStk[top-1], regStk[top-2]);
                        top--;
                }
          }
	  ;

multiplicative_expr:
          primary_expr
	  | multiplicative_expr TIMES primary_expr {
		fprintf(fasm,"\n\t# *\n");
		if (top<nregStk) {
			fprintf(fasm, "\timulq %%%s,%%%s\n", 
				regStk[top-1], regStk[top-2]);
			top--;
		}
          }
	  | multiplicative_expr DIVIDE primary_expr {
                fprintf(fasm,"\n\t# +\n");
                if (top<nregStk) {
			fprintf(fasm,"\tsubq %rdx, %rdx\n");
			fprintf(fasm,"\tmovq %%%s, %rax\n", regStk[top-2]);
                        fprintf(fasm, "\tidivq %%%s\n",
                                regStk[top-1]);
			fprintf(fasm,"\tmovq %rax, %%%s\n", regStk[top-2]);
                        top--;
                }
  }

	  | multiplicative_expr PERCENT primary_expr {
                fprintf(fasm,"\n\t# +\n");
                if (top<nregStk) {
			fprintf(fasm,"\tsubq %rdx, %rdx\n");
                        fprintf(fasm,"\tmovq %%%s, %rax\n", regStk[top-2]);
                        fprintf(fasm, "\tidivq %%%s\n",
                                regStk[top-1]);
                        fprintf(fasm,"\tmovq %rdx, %%%s\n", regStk[top-2]);
                        top--;
                }
          }

	  ;

primary_expr:
	  STRING_CONST {
		  // Add string to string table.
		  // String table will be produced later
		  string_table[nstrings]=$<string_val>1;
		  fprintf(fasm, "\t#top=%d\n", top);
		  fprintf(fasm, "\n\t# push string %s top=%d\n",
			  $<string_val>1, top);
		  if (top<nregStk) {
		  	fprintf(fasm, "\tmovq $string%d, %%%s\n", 
				nstrings, regStk[top]);
			//fprintf(fasm, "\tmovq $%s,%%%s\n", 
				//$<string_val>1, regStk[top]);
			top++;
		  }
		  nstrings++;
	  }
          | call
	  | WORD {
		  char * id = $<string_val>1;
		int i;
		for (i=0; i<nlocals; i++){
			if(strcmp(local_vars_table[i], id)==0){
				fprintf (fasm,"\tmovq %d(%%rsp), %%%s\n", 8*i,regStk[top]);
				top++;
				break;
			}

		}
		for(i=0;i<nglobals;i++){
			if(strcmp(global_vars_table[i],id)==0){
		 		 fprintf(fasm, "\tmovq %s,%%%s\n", id, regStk[top]);
		  		top++;
			}
		}
	  }
	  | WORD LBRACE expression RBRACE{
		char *id=$<string_val>1;
		int i;
		for (i=0; i<nlocals; i++){
			if(strcmp(local_vars_table[i], id)==0){
				if(!local_char_star[i]){
					fprintf(fasm,"\timulq $8, %%%s\n", regStk[top-1]);
				fprintf(fasm,"\taddq %d(%%rsp), %%%s\n", i*8, regStk[top-1]);
				fprintf(fasm,"\tmovq (%%%s),%%%s\n",regStk[top-1],regStk[top-1]);
				}
				else
				{
					fprintf(fasm,"\taddq %d(%%rsp), %%%s\n", i*8, regStk[top-1]);
					fprintf(fasm,"\tmovq (%%%s),%%%s\n",regStk[top-1],regStk[top-1]);
					fprintf(fasm,"\tmovzbq %%%s,%%%s\n",regLowerStk[top-1],regStk[top-1]);
				}
			}
		}
		for (i=0; i<nglobals;i++){
			if(strcmp(global_vars_table[i],id)==0){
				if(!global_char_star[i]){
					fprintf(fasm,"\timulq $8, %%%s\n",regStk[top-1]);
				fprintf(fasm,"\taddq %s, %%%s\n", id, regStk[top-1]);
				fprintf(fasm,"\tmovq (%%%s),%%%s\n",regStk[top-1],regStk[top-1]);
				}
				else{
					fprintf(fasm,"\taddq %s, %%%s\n",id,regStk[top-1]);
					fprintf(fasm,"\tmovq (%%%s),%%%s\n",regStk[top-1],regStk[top-1]);
					fprintf(fasm,"\tmovzbq %%%s,%%%s\n",regLowerStk[top-1],regStk[top-1]);
				}
			}
		}

	}
	  | AMPERSAND WORD{
		char *id = $<string_val>2;
		int i;
		for (i=0; i<nlocals; i++){
			if(strcmp(local_vars_table[i],id)==0){
				fprintf(fasm,"\tmovq %%rsp, %%%s\n",regStk[top]);
				fprintf(fasm,"\taddq $%d, %%%s\n",i*8,regStk[top]);
				top++;
			}
		}
		for (i=0; i<nglobals;i++){
			if(strcmp(global_vars_table[i],id)==0){
				fprintf(fasm,"\tmovq $%s, %%%s\n",id,regStk[top]);
				top++;
			}
		}
	}
	  | INTEGER_CONST {
		  fprintf(fasm, "\n\t# push %s\n", $<string_val>1);
		  if (top<nregStk) {
			fprintf(fasm, "\tmovq $%s,%%%s\n", 
				$<string_val>1, regStk[top]);
			top++;
		  }
	  }
	  | LPARENT expression RPARENT
	  ;

compound_statement:
	 LCURLY statement_list RCURLY
	 ;

statement_list:
         statement_list statement
	 | /*empty*/
	 ;

local_var:
        {charstar=0;}var_type local_var_list SEMICOLON;

local_var_list: WORD{
	local_vars_table[nlocals] = $<string_val>1;
	local_char_star[nlocals]=charstar;
	nlocals++;
}
        | local_var_list COMA WORD{
	local_vars_table[nlocals] = $<string_val>3;
	local_char_star[nlocals]=charstar;
	nlocals++;
}
        ;

statement:
         assignment SEMICOLON
	 | call SEMICOLON{
		top--;
}
	 | local_var
	 | compound_statement
	 | IF LPARENT{
		$<my_nlabel>1 = nlabel;
		nlabel++;
		fprintf(fasm, "start_%d:\n",$<my_nlabel>1);
	}
	 expression RPARENT{
		fprintf(fasm,"\tcmpq $1, %%%s\n",regStk[top-1]);
		fprintf(fasm,"\tjne end_%d\n",$<my_nlabel>1);
	}
	 statement{
		fprintf(fasm, "end_%d:\n",$<my_nlabel>1);

	}
	else_optional
	 | WHILE LPARENT {
		// act 1
		$<my_nlabel>1=nlabel;
		innerloop=nlabel;
		nlabel++;
		fprintf(fasm, "start_%d:\n", $<my_nlabel>1);
         }
         expression RPARENT {
		// act2
		fprintf(fasm, "\tcmpq $0, %%%s\n",regStk[top-1]);
		fprintf(fasm, "\tje end_%d\n", $<my_nlabel>1);
		top--;
         }
         statement {
		// act3
		fprintf(fasm, "\tjmp start_%d\n", $<my_nlabel>1);
		fprintf(fasm, "end_%d:\n", $<my_nlabel>1);
	 }
	 | DO{
		$<my_nlabel>1=nlabel;
		innerloop=nlabel;
		nlabel++;
		fprintf(fasm, "start_%d:\n", $<my_nlabel>1);
	}
	 statement WHILE LPARENT expression RPARENT{
		fprintf(fasm,"\tcmpq $1, %%%s\n",regStk[top-1]);
		fprintf(fasm,"\tje start_%d\n", $<my_nlabel>1);
		fprintf(fasm,"end_%d:\n", $<my_nlabel>1);

	}
	 SEMICOLON
	 | FOR LPARENT assignment SEMICOLON{
		$<my_nlabel>1=nlabel;
		innerloop=nlabel;
		nlabel++;
		fprintf(fasm,"start_for_%d:\n",$<my_nlabel>1);
	}
	 expression SEMICOLON{
		fprintf(fasm,"\tcmpq $0, %%%s\n",regStk[top-1]);
		fprintf(fasm,"\tje end_%d\n",$<my_nlabel>1);
		top--;
		fprintf(fasm,"\tjmp end_assign_%d\n",$<my_nlabel>1);
		fprintf(fasm,"start_%d:\n",$<my_nlabel>1);
	}
	 assignment RPARENT{
		fprintf(fasm,"\tjmp start_for_%d\n",$<my_nlabel>1);
		fprintf(fasm,"end_assign_%d:\n",$<my_nlabel>1);
	}
	 statement{
		fprintf(fasm,"\tjmp start_%d\n", $<my_nlabel>1);
		fprintf(fasm,"end_%d:\n",$<my_nlabel>1);
}
	 | jump_statement
	 ;

else_optional:
         ELSE{
		$<my_nlabel>1=nlabel;
		nlabel++;
		fprintf(fasm, "\tcmpq $1, %%%s\n",regStk[top-1]);
		fprintf(fasm, "\tje end_%d\n", $<my_nlabel>1);
		top--;
} 
	 statement{
		fprintf(fasm, "end_%d:\n", $<my_nlabel>1);
}
	 | /* empty */{
	top--;
	}
         ;

jump_statement:
         CONTINUE SEMICOLON{
		fprintf(fasm, "\tjmp start_%d\n",innerloop);
	}
	 | BREAK SEMICOLON{
		fprintf(fasm, "\tjmp end_%d\n",innerloop);
	}
	 | RETURN expression SEMICOLON {
		 fprintf(fasm, "\tmovq %%%s, %%rax\n",regStk[top-1]);
		top--;
		fprintf(fasm,"\taddq $256, %%rsp\n");
		fprintf(fasm,"\tpopq %%r15\n");
		fprintf(fasm,"\tpopq %%r14\n");
		fprintf(fasm,"\tpopq %%r13\n");
		fprintf(fasm,"\tpopq %%r10\n");
		fprintf(fasm,"\tpopq %%rbx\n");
		 fprintf(fasm,"\tret\n");
	 }
	 ;

%%

void yyset_in (FILE *  in_str );

int
yyerror(const char * s)
{
	fprintf(stderr,"%s:%d: %s\n", input_file, line_number, s);
}


int
main(int argc, char **argv)
{
	printf("-------------WARNING: You need to implement global and local vars ------\n");
	printf("------------- or you may get problems with top------\n");
	
	// Make sure there are enough arguments
	if (argc <2) {
		fprintf(stderr, "Usage: simple file\n");
		exit(1);
	}

	// Get file name
	input_file = strdup(argv[1]);

	int len = strlen(input_file);
	if (len < 2 || input_file[len-2]!='.' || input_file[len-1]!='c') {
		fprintf(stderr, "Error: file extension is not .c\n");
		exit(1);
	}

	// Get assembly file name
	asm_file = strdup(input_file);
	asm_file[len-1]='s';

	// Open file to compile
	FILE * f = fopen(input_file, "r");
	if (f==NULL) {
		fprintf(stderr, "Cannot open file %s\n", input_file);
		perror("fopen");
		exit(1);
	}

	// Create assembly file
	fasm = fopen(asm_file, "w");
	if (fasm==NULL) {
		fprintf(stderr, "Cannot open file %s\n", asm_file);
		perror("fopen");
		exit(1);
	}

	// Uncomment for debugging
	//fasm = stderr;

	// Create compilation file
	// 
	yyset_in(f);
	yyparse();

	// Generate string table
	int i;
	for (i = 0; i<nstrings; i++) {
		fprintf(fasm, "string%d:\n", i);
		fprintf(fasm, "\t.string %s\n\n", string_table[i]);
	}

	fclose(f);
	fclose(fasm);

	return 0;
}

