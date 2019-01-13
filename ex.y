%{
	#include <stdio.h>
	#include <string.h>

	int yylex();
	int yyerror(const char *msg);

        int EsteCorecta = 1;
	char msg[500];

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}

%union { char* sir; int val; }
%locations
%token TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO TOK_INTEGER TOK_EQUALS TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIVIDE TOK_LEFT TOK_RIGHT TOK_PRINT TOK_ERROR

%token <val> TOK_INT
%token <sir> TOK_ID
%type <val> exp
%type <val> term
%type <val> factor

%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%type <sir> id_list

%%
prog : TOK_PROGRAM prog_name TOK_VAR dec_list TOK_BEGIN stmt_list TOK_END '.'
       | 
       error { EsteCorecta = 0; }
       ;
prog_name : TOK_ID;

dec_list : dec
	  |
	  dec_list ';' dec
	  ;
dec : id_list ':' type
      {
	if($1!=NULL)
	{
	  //printf("idlist=%s\n",$1);
	  char *token = strtok($1, " ,");
	  while(token!= NULL) 
	  {
	    //printf("%s\n",token);
	    if(ts->exists(token)==0)
		{
	   	ts->add(token);
		//printf("val %s=%d\n",token,ts->getValue(token));
		}
	    else
	    {
	     sprintf(msg,"%d:%d Eroare semantica: Redeclararea variabilei %s !", @1.first_line, @1.first_column, $1);
	     yyerror(msg);
	     YYERROR;
	    }
	   token = strtok(NULL, " ,");
	  }
	  free(token);
	}
      }
      ;
type : TOK_INTEGER;

id_list : TOK_ID { $$ = $1; }
	 |
 	 id_list ',' TOK_ID { 
		char buff[100];
		sprintf(buff,"%s %s",$1,$3); 		
		$$ = buff; }
	 ;
stmt_list : stmt
 	   |
	   stmt_list ';' stmt
	   ;
stmt : assign
       |
       read
       |
       write
       |
       for
       ;
assign : TOK_ID TOK_EQUALS exp
	{
	if($1!=NULL)
	{
		printf("assigning %s=%d\n",$1,$3);
		if(ts->exists($1)==0)
		{
			sprintf(msg,"%d:%d Eroare semantica assign: Variabila %s este folosita fara a fi declarata!", @1.first_line, @1.first_column, $1);
			yyerror(msg);
			YYERROR;
		}
		else ts->setValue($1,$3);
	}
	}
	  ;
exp : term { $$ = $1; }
      |
      exp TOK_PLUS term { $$ = $1 + $3; }
      |
      exp TOK_MINUS term { $$ = $1 - $3; }
      ;
term : factor { $$ = $1; }
       |
       term TOK_MULTIPLY factor { $$ = $1 * $3; }
       |
       term TOK_DIVIDE factor { $$ = $1 / $3; }
       ;
factor : TOK_ID
	{
	if($1!=NULL)
	{
		 if(ts->exists($1)!=0)
		{
			//printf("getting value %s\n",$1);
			int i=ts->getValue($1);
			if(i!=-1)
				$$=i;
			else{
			sprintf(msg,"%d:%d Eroare semantica: Variabila %s a fost folosita fara sa fie initializata!", @1.first_line, @1.first_column, $1);
		    	yyerror(msg);
		    	YYERROR;
		   	}
		}
	}
	}
         |
         TOK_INT { $$ = $1; }
         |
         TOK_LEFT exp TOK_RIGHT { $$ = $2; }
         ;
read : TOK_READ TOK_LEFT id_list TOK_RIGHT
	{
	   if($3 != NULL)
	   {
		//printf("%s",$3);
   		char *token = strtok($3, " ");
	    	while(token) 
		{
		   if(ts->exists(token) == 0)
		   {
		     sprintf(msg,"%d:%d Eroare semantica read: Variabila %s nu a fost declarata!", @1.first_line, @1.first_column, token);
		    yyerror(msg);
		    YYERROR;
		   }
		   else
		   {
			ts->setValue(token,0);
			printf("Reading %s\n",token);
		   	token=strtok(NULL, ", ");
		   }
			   
		}
		free(token);	
	   }
	}
	;
write : TOK_WRITE TOK_LEFT id_list TOK_RIGHT
	{
	   if($3 != NULL)
	   {
   		char *token = strtok($3, " ");
	    	while(token) 
		{
		   if(ts->exists(token) == 0)
		   {
		     sprintf(msg,"%d:%d Eroare semantica write: Variabila %s nu a fost declarata!", @1.first_line, @1.first_column, token);
		    yyerror(msg);
		    YYERROR;
		   }
		   else
		   {
			if(ts->getValue(token)==-1)
			{
			sprintf(msg,"%d:%d Eroare semantica write: Variabila %s a fost folosita fara a fi initializata!", @1.first_line, @1.first_column, token);
			yyerror(msg);
			YYERROR;
			}
			printf("Writing %s=%d\n",token,ts->getValue(token));
			token=strtok(NULL, ", ");
		   }
			   
		}
		free(token);	
	   }
	}
	;
for : TOK_FOR index_exp TOK_DO body;

index_exp : TOK_ID TOK_EQUALS exp TOK_TO exp
	{
	if($3 > $5)
	{
		sprintf(msg,"%d:%d Eroare semantica for: %d<%d!", @1.first_line, @1.first_column, $5,$3);
		yyerror(msg);
		YYERROR;
	}
	printf("%d - %d\n",$3,$5);
	if($1 != NULL){
		if(ts->exists($1)==1)
			ts->setValue($1,$3);
		else{
			sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost declarata!", @1.first_line, @1.first_column, $1);
			yyerror(msg);
			YYERROR;
		}
		}
	}
	;

body : stmt
	|
	TOK_BEGIN stmt_list TOK_END
       ;
%%


int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}	

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}

