%{
#include <stdio.h>
#include <stdlib.h>
#if defined(_WIN32)
	#include <conio.h>
#endif
#include <string.h>
#include <math.h>
#include "y.tab.h"

#define LIM_REAL 2147483647
#define LIM_INT 32768
#define LIM_STR 32			// Incluye las comillas de inicio y fin de cadena

FILE  *yyin;
int yylval;
char *yyltext;

int yyerror();
int yylex();

void errorCharInvalido();
int verificarTamanio(int opc);
void guardarTS_Archivo();
void guardarLexemas(char *,int);
void guardarTS(char *);
int buscar(char *);

int i=0;
int k=0;

void capturaTipo(char *);

typedef struct {
       		    char lexema[50];
                char tipoDato[100];
                char  valor[30];
				char longitud[25];
	            } tsimbolos;

tsimbolos ts[100]; //pila con lexemas para agregar a la TS, puede guardar 100 lexemas.

%}

%option noyywrap
%option yylineno


DIGITO [0-9]
LETRA  [a-zA-Z]
ID    {LETRA}({LETRA}|{DIGITO}|"_")*
CTE_INT       {DIGITO}+
CTE_REAL		{DIGITO}+"."{DIGITO}+|{DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}*
COMILLAS	   	"\""
ESPACIO			" "
CTE_STR         {COMILLAS}({LETRA}|{DIGITO}|{ESPACIO}|_|@|%)*{COMILLAS}
COMENT_SIMPLE	"-/"({LETRA}|{DIGITO}|_|{ESPACIO}|":"|"="|"."|"+"|"("|")"|"["|"]"|","|"@"|" "|"%"|";"|["])*"/-"
COMENT_DOBLE	"-/"({LETRA}|{DIGITO}|_|{ESPACIO}|":"|"="|"."|"+"|"("|")"|"["|"]"|","|"@"|" "|"%"|";"|["]|{COMENT_SIMPLE})*"/-"


FLOAT			"FLOAT"|"float"|"Float"
INTEGER			"INTEGER"|"integer"|"Integer"
STRING			"STRING"|"string"|"String"

IF     		"IF"|"if"|"If"
ENDIF   	"ENDIF"|"endif"|"Endif"
THEN    	"THEN"|"then"|"Then"
ELSE   		"ELSE"|"else"|"Else"
WHILE  		"WHILE"|"while"|"While"
ENDWHILE 	"ENDWHILE"|"endwhile"|"Endwhile"


AND			"AND"|"and"|"And"
OR			"OR"|"or"|"Or"
NOT			"NOT"|"not"|"Not"
WRITE 		"WRITE"|"write"|"Write"
READ 		"READ"|"read"|"Read"
MOD			"MOD"|"mod"|"Mod"|"%"
DIV			"DIV"|"div"|"Div"
ANY				.
%%

"DECVAR"		{ return DECVAR; }
"ENDDEC"		{ return ENDDEC; }
{FLOAT}			{capturaTipo(yytext); return FLOAT; }
{INTEGER}		{capturaTipo(yytext);return INTEGER; }
{STRING}		{capturaTipo(yytext);return STRING;}
{IF}			{ return IF; }
{THEN}			{ return THEN; }
{ELSE}			{ return ELSE; }
{ENDIF}			{ return ENDIF; }
{AND}      	 	{ return AND; }
{OR}        	{ return OR; }
{NOT}       	{ return NOT; }
{WHILE}        	{ return WHILE; }
{ENDWHILE}     	{ return ENDWHILE; }
{WRITE}	    	{ return WRITE; }
{READ}	    	{ return READ; }
{MOD}			{return MOD; }
{DIV}			{return DIV; }
{COMENT_SIMPLE}	{  }
{COMENT_DOBLE}	{  }







"=="		{ return IGUAL; }
"<>"		{ return DIST; }
"<"			{ return MENOR; }
">"			{ return MAYOR; }
"<="		{ return MEN_IG; }
">="		{ return MAY_IG; }



{CTE_STR}		{
					if(verificarTamanio(CTE_STR) == 0)
					{
						printf("-------------ERROR-------------\n");
						printf("Cte string fuera de rango.\n");
						system ("Pause");
						exit(1);
					}
					else
					{
						guardarLexemas(yytext,1);
						return CTE_STR;					
					}
				}


{CTE_INT}		{	
					if(verificarTamanio(CTE_INT) == 0)
					{
						printf("-------------ERROR-------------\n");
						printf("Integer fuera de rango.\n");
						system ("Pause");
						exit(1);
					
					}
					else
					{
						guardarLexemas(yytext,2);
						return CTE_INT;
					}

				}


{CTE_REAL}	{	
				if(verificarTamanio(CTE_REAL) == 0)
					{
						printf("-------------ERROR-------------\n");
						printf("Real fuera de rango.\n");
						system ("Pause");
						exit(1);
					
					}
					else
					{
						guardarLexemas(yytext,3);

						return CTE_REAL;
					
					}


				}



{ID}     	{guardarLexemas(yytext,0);return ID; }


","			{ return COMA;}
";"			{ return PUNTO_COMA;}
"="		    { return OPE_ASIG; }
":"			{ return DOS_PUNTOS; }
"["			{ return C_A; }
"]"			{ return C_C; }
"+"			{ return OPE_SUM; }
"-"			{ return OPE_RES; }
"*"			{ return OPE_MUL; }
"/"			{ return OPE_DIV; }
"("			{ return P_A; }
")"			{ return P_C; }
"{"			{ return L_A; }
"}"			{ return L_C; }


"\n"
"\t"
" "
"\r\n"
{ANY}			{ errorCharInvalido();}

%%

void guardarTS_Archivo()
{
FILE* arch;
int x;

    arch = fopen("ts.txt", "w+");

	if (!arch){
		printf("Error. No se pudo crear el archivo ts.txt");
	exit(1);
	}
	fprintf(arch,"%-23s%-15s%-28s%8s\n","lexema","Tipo","Valor","Longitud");
	for(x=0;x<i;x++){

	fprintf(arch,"%-23s%-15s%-20s%8s",ts[x].lexema,ts[x].tipoDato,ts[x].valor,ts[x].longitud);
	fprintf(arch,"\n");
	}

	 fclose(arch);
}

void guardarLexemas(char *lexema,int val)
{

     if(val==0)
	{

	   if(buscar(lexema)!=0)
	   {
	      strcpy(ts[i].lexema,lexema);
		  i++;//incremento para conocer la cantidad de id que hay en la ctes
	   }


	}
    if(val==1)
	{
	    char *s=lexema;
		s++;//adelanto el puntero para que no tome la 1eras comillas
		int n=strlen(lexema)-2;//le resto 2 para que no copie las comillas (iniciales y finales)
		strncpy(lexema,s,n);
		while(n > 1)//llevo el puntero hasta la posicion que debe finalizar el string
		{
			n--;
		    s++;
		}
	    memset(s, '\0',n);//marco el fin del string

	  if(buscar(lexema)!=0)
	  {

	   strcpy(ts[i].lexema,"_");
       strcat(ts[i].lexema,lexema);;
	   strcpy(ts[i].valor,lexema);
	   #if defined(_WIN32)
	       itoa(strlen(lexema),ts[i].longitud,10);
       #else
           sprintf(ts[i].longitud, "%ld", strlen(lexema));
       #endif
        i++;//incremento para conocer la cantidad de id que hay en la ctes
      }

	}
   if(val==2)
	{

    if(buscar(lexema)!=0)
	 {
	   strcpy(ts[i].lexema,"_");
       strcat(ts[i].lexema,lexema);
	   strcpy(ts[i].valor,lexema);

	    i++;//incremento para conocer la cantidad de id que hay en la ctes
      }


	}
     if(val==3)
	{

    if(buscar(lexema)!=0)
	 {
	   strcpy(ts[i].lexema,"_");
       strcat(ts[i].lexema,lexema);
	   strcpy(ts[i].valor,lexema);
	   i++;//incremento para conocer la cantidad de id que hay en la ctes
      }


	}

}

int buscar(char * lexema)
{
 int x;
  for(x=0;x<i;x++){//50 cantidad de lexemas en la tabla
  if(strcmp(ts[x].lexema,lexema)==0)
   return 0;
  }
   return 1;
}



void capturaTipo(char * tvar)
 {
	strcpy(ts[k].tipoDato,tvar);
	k++;
}

int verificarTamanio(int opc){
	switch(opc){
		case CTE_INT:
			if(atoi(yytext) >= -LIM_INT && atoi(yytext) <= LIM_INT-1)
				return 1;
			return 0;
			break;
		case CTE_STR:
			if(strlen(yytext) <= LIM_STR) 
				return 1;
			return 0;
			break;
		case CTE_REAL:
			if(atof(yytext) >= -LIM_REAL && atof(yytext) <= LIM_REAL-1)
				return 1;
			return 0;
			break;
	}
	return 0;
}

void errorCharInvalido()
{
	printf("Caracter invalido ingresado\n");
	system ("Pause");
    exit (1);
}