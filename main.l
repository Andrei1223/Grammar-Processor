/* Timofte_Andrei-Ioan_335CC */
%{
#include <stdio.h>
#include <stack>
#include <vector>
//#include <string>

#define YY_NO_UNPUT
#undef yywrap

using namespace std;

/* 
    variabilele din fisierul curent
    pentru fiecare variabila locala gasita se asigura ca aceasta
    este scoada din stiva odata ce s a iesit din automat/gramatica
*/
vector<pair<string, vector<char> > > variabile;
/*
    vectori care retin simbolurile din alfabetul curent(a unui automat/gramatica).
    este gol daca nu se afla intr o astfel de structura.
    valoare_var este un vector care are scop auxiliar pentru a acumula
    valorile pentru variabila locala/globala curenta pana se ajunge la finalul declaratiei
    si se adauga in stiva de variabile
*/
vector<char> alfabet, valoare_var;

vector<string> stari, stari_finale;

/*
    structura folosita pentru a retine fiecare tranzitie a automatului.
    la finalul diecarei declarstii se foloseste lista de tranzitii pentru
    a afisa dar si verifica tipul automatului
*/
// m(s1, litera) = s2
typedef struct tranzitie {
    string s1;
    string litera; // poate retine si numele unei varaibile
    string s2;
}tranztie;

tranzitie t;

// variabila folosita pentru a determina daca un automat este determinist sau nu
// este modificata cand se intalneste o regula care indica ca este nedeterminist
bool is_determinist;
// se retin caracterele dintr un bloc de tarnzitii al unui automat pentru
// a verifica daca este neterminist
vector<string> aux_litere;

vector<tranzitie> tranzitii;

// varaibila care retine numele starii initiale unui automat
string stare_init;

void verifica_tip()
{
    for (string c : aux_litere) {
        if (c == t.litera || c == "e") {
            is_determinist = false;
            break;
        }
    }
    aux_litere.push_back(t.litera);
}

/*
    variabile folosite atunci cand se intalneste definitia unei
    variabile atat locale cat si globale
*/
int numar_var_locale;
string nume_variabila;

/*
    se folosesc pentru gramatica pentru a retine tipul gramaticii
    si numarul de reguli de productie
*/
string tip_gramatica;
int numar_reguli;

/*
    variabile folosite pentru a determina tipul gramaticii:
    GR, GIC, GDC, GFR
    acest lucru se realizeaza contorizand nr de terminali si neterminali
    din ambele parti ale unei reguli de productie
*/
int nr_neterminali_st, nr_neterminali_dr;
int nr_litere_st, nr_litere_dr;

%}

%option stack
%x IN_SINGLE_COMMENT IN_MULTIPLE_COMMENT
%x VARIABLE VARIABLE_VALUES
%x LOCAL_VARIABLE LOCAL_VARIABLE_VALUES
%x AUTOMAT
%x ALPHABET STATES INITIAL_STATE FINAL_STATES GRUP_TRANZITII TRANZITIE
%x GRAMATICA
%x START_SYMBOL NONTERMINALS REGULA GRUP_REGULI

tab                              \t
newline                          \n
spaces                           [ ]*
alphabet                         "alphabet"
variable                         "variable"
states                           "states"
start_symbol                     "start_symbol"
final_states                     "final_states"
initial_state                    "initial_state"
nonterminals                     "nonterminals"
semn_egal                        {spaces}"::="{spaces}
variable_nume                    [a-z][a-zA-Z0-9]*
stare_nume                       [a-zA-Z0-9]+
automat_nume                     [a-zA-Z0-9]+
neterminal_nume                  [A-Z][a-zA-Z0-9]*
automat_tip                      {spaces}"FiniteAutomaton"{spaces}{newline}*
gramatica_tip                    {spaces}"Grammar"{spaces}{newline}*
asignare                         {spaces}{semn_egal}{spaces}"{"{spaces}
final_linie_var                  "}"{spaces}";"


%%

<IN_SINGLE_COMMENT>\n {
    // la aparitia unui /n se termina comentariul(se revine la starea precedenta)
    yy_pop_state();
}
<IN_SINGLE_COMMENT>. {
    // se ignora caracterele
}


<IN_MULTIPLE_COMMENT>"*/" {
    // caracter care marcheaza finalul unui comentariu de mai multe randuri
    yy_pop_state();
}
<IN_MULTIPLE_COMMENT>.|\n {
    // se ignora toate caracterele inclusiv \n
}


<VARIABLE>" " {
    // se ignora spatiile
}
<VARIABLE>\n {
    // la \n se revine in starea precedenta
    variabile.push_back(make_pair(nume_variabila, valoare_var));
    printf("\n\n");

    // se revine in starea INITIAL
    yy_pop_state();
}
<VARIABLE>{variable_nume} {
    // se afiseaza numele variabilei
    nume_variabila = *new string(yytext);
    printf("\tIdentificator: %s\n", yytext);
}
<VARIABLE>{asignare} {
    // se trece trece la starea pt prelucrarea domeniului
    printf("\tDomeniu: {");
    yy_push_state(VARIABLE_VALUES);
}



<LOCAL_VARIABLE>" " {
    // se ignora spatiile
}
<LOCAL_VARIABLE>\n {
    // la \n se revine in starea precedenta
    variabile.push_back(make_pair(nume_variabila, valoare_var));
    yy_pop_state();
}
<LOCAL_VARIABLE>{variable_nume} {
    // se afiseaza numele variabilei
    nume_variabila = *new string(yytext);
}
<LOCAL_VARIABLE>{asignare} {
    yy_push_state(LOCAL_VARIABLE_VALUES);
}



<LOCAL_VARIABLE_VALUES>[a-z0-9] {
    // preia un element din alfabet 
    valoare_var.push_back(yytext[0]);
}
<LOCAL_VARIABLE_VALUES>{final_linie_var} {
    // se face match pe finalul definitiei si se revine la starea dinainte the variabila
    yy_pop_state();
}
<LOCAL_VARIABLE_VALUES>" "|"," {}


<VARIABLE_VALUES>[a-z0-9]                     { printf("%s", yytext); valoare_var.push_back(yytext[0]); } // preia un element din alfabet 
<VARIABLE_VALUES>","                          { printf(", "); } // se scrie virgula
<VARIABLE_VALUES>{final_linie_var}            { printf("}"); yy_pop_state();} // se face match pe finalul definitiei si se revine la starea dinainte the variabila
<VARIABLE_VALUES>" "                          {} // se ignora space urile



<ALPHABET>[a-z0-9] {
    alfabet.push_back(yytext[0]);
}
<ALPHABET>{spaces}";"{spaces}{newline} {
    // finalul instructiunii se revine la starea automatului
    yy_pop_state();
}
<ALPHABET>. {} // ignora caracterele


<STATES>{stare_nume} {
    stari.push_back(* new string(yytext));
}
<STATES>{spaces}";"{spaces}{newline} {
    // finalul instructiunii se revine la starea automatului
    yy_pop_state();
}
<STATES>. {}


<INITIAL_STATE>{stare_nume} {
    stare_init = *new string(yytext);
}
<INITIAL_STATE>{spaces}";"{spaces}{newline} {
    // finalul instructiunii se revine la starea automatului
    yy_pop_state();
}
<INITIAL_STATE>. {}


<FINAL_STATES>{stare_nume} {
    stari_finale.push_back(*new string(yytext));
}
<FINAL_STATES>{spaces}";"{spaces}{newline} {
    // finalul instructiunii se revine la starea automatului
    yy_pop_state();
}
<FINAL_STATES>. {}



<GRUP_TRANZITII>{stare_nume} {
    t.s1 = *new string(yytext);
    aux_litere.clear();
}
<GRUP_TRANZITII>"("{spaces}{newline} {
    yy_push_state(TRANZITIE);
}
<GRUP_TRANZITII>{spaces}|"->"|{tab} {}


<TRANZITIE>.*%.* {yy_push_state(IN_SINGLE_COMMENT);}
<TRANZITIE>.*"/*".* {yy_push_state(IN_MULTIPLE_COMMENT);}
<TRANZITIE>{stare_nume}/{spaces}"->" {
    t.litera = *new string(yytext);    
}
<TRANZITIE>{stare_nume}/{spaces}";"{spaces}{newline} {
    t.s2 = *new string(yytext);

    // se adauga tranzitiile daca este o variabila
    for (auto p : variabile) {
        if (p.first == t.litera) {
            for (int i = 0; i < p.second.size() - 1; i++) {
                t.litera = p.second[i];

                verifica_tip();

                // se adauga tranzitia
                tranzitii.push_back(t);
            }

            t.litera = p.second[p.second.size() - 1];
        }
    }


    verifica_tip();

    // se adauga tranzitia
    tranzitii.push_back(t);
}
<TRANZITIE>")"{spaces}";"{spaces}{newline} {
    yy_pop_state();
    yy_pop_state();
}
<TRANZITIE>{tab}|"->"|";"|{newline}|{spaces} {}



<AUTOMAT>{tab}/.*"->".* {
    // se salveaza numele starii
    yy_push_state(GRUP_TRANZITII);
}

<AUTOMAT>{tab}{final_states} {
    yy_push_state(FINAL_STATES);
}

<AUTOMAT>{tab}{alphabet} {
    yy_push_state(ALPHABET);
}

<AUTOMAT>{tab}{states} {
    yy_push_state(STATES);
}

<AUTOMAT>{tab}{initial_state} {
    yy_push_state(INITIAL_STATE);
}

<AUTOMAT>{tab}{variable} {
    /*
        updatare pt noua variabila locala
    */

    numar_var_locale++;
    valoare_var.clear();
    yy_push_state(LOCAL_VARIABLE);
}

<AUTOMAT>"("{spaces}\n {
    numar_var_locale = 0;
    is_determinist = true;
    alfabet.clear();
    stari_finale.clear();
    stari.clear();
    tranzitii.clear();
}

<AUTOMAT>% { yy_push_state(IN_SINGLE_COMMENT); }
<AUTOMAT>"/*" { yy_push_state(IN_MULTIPLE_COMMENT); }

<AUTOMAT>{spaces}")"{spaces}";;"{spaces} {
    // scrie info despre automat

    int size = alfabet.size();

    printf("Tipul automatului: Automat finit ");
    if (is_determinist) {
        printf("determinist\n");
    } else {
        printf("nedeterminist\n");
    }

    printf("Alfabetul de intrare: {");
    for (int i = 0; i < size; i++) {
        if (i + 1 != size)
            printf("%c, ", alfabet[i]);
        else
            printf("%c", alfabet[i]);
    }
    printf("}\n");

    printf("Numarul de stari: %lu\n", stari.size());
    printf("Starea initiala: %s\n", stare_init.c_str());

    printf("Starile finale: {");
    size = stari_finale.size();
    for (int i = 0; i < size; i++) {
        if (i + 1 == size)
            printf("%s", stari_finale[i].c_str());
        else 
            printf("%s, ", stari_finale[i].c_str());
    }
    printf("}\n");

    printf("Functia de tranzitie:\n");
    for (int i = 0; i < tranzitii.size(); i++) {
        printf("\tm(%s, %s) = %s\n", tranzitii[i].s1.c_str(), tranzitii[i].litera.c_str(), tranzitii[i].s2.c_str());
    }

    for (int i = 0; i < numar_var_locale; i++) {
        printf("Variabila locala:\n\tIndetificator: %s\n", variabile[variabile.size() - 1].first.c_str());
        printf("\tDomeniu: {");
        int size = variabile[variabile.size() - 1].second.size();

        for (int j = 0; j < size; j++) {
            if (j + 1 == size) {
                printf("%c", variabile[variabile.size() - 1].second[j]);
            } else {
                printf("%c, ", variabile[variabile.size() - 1].second[j]);
            }
        }
        printf("}\n");
        variabile.pop_back();
    }

    printf("\n");

    yy_pop_state();
}

<AUTOMAT>{spaces}|\n|{semn_egal}{automat_tip}|{tab} {}



<START_SYMBOL>{neterminal_nume} {
    stare_init = *new string(yytext);
}
<START_SYMBOL>{spaces}";"{spaces}{newline} {
    // finalul instructiunii se revine la starea automatului
    yy_pop_state();
}
<START_SYMBOL>. {}


<NONTERMINALS>{neterminal_nume} {
    stari.push_back(*new string(yytext));
}
<NONTERMINALS>{spaces}";"{spaces}{newline} {
    // finalul instructiunii se revine la starea automatului
    yy_pop_state();
}
<NONTERMINALS>. {}



<REGULA>{spaces}"|"{spaces} {
    numar_reguli++;

    // se verifica daca sunt mai multe elemente in stanga decat in dreapta
    if (nr_neterminali_st + nr_litere_st > nr_neterminali_dr + nr_litere_dr)
        tip_gramatica = "GFR";

    // se trece la urmatoarea regula si se reseteaza campurile
    nr_neterminali_dr = 0;
    nr_litere_dr = 0;
}
<REGULA>[a-z0-9] {
    nr_litere_dr++;

    // daca intr o regula exista cel putin 2 neterminali atunci nu este GR
    if (nr_neterminali_dr >= 1) {
        if (tip_gramatica == "GR") {
            tip_gramatica = "GIC";
        }
    }
}
<REGULA>{variable_nume} {
    /*
        se verifica daca varaibila exista
    */
    string s = *new string(yytext);
    bool found = false;

    // se cauta in lista de variabila
    for (auto pair : variabile) {
        if (pair.first == s) {
            // variabila este considerata un caracter din alfabet
            nr_litere_dr++;
            if (nr_neterminali_dr >= 1) {
                if (tip_gramatica == "GR") {
                    tip_gramatica = "GIC";
                }
            }

            found = true;
        }
    }

    // daca nu este o variabila atunci se da reject
    if (!found) {
        REJECT;
    }
}
<REGULA>{neterminal_nume} {
    nr_neterminali_dr++;

    // daca o regula are cel putin 2 neterminali atunci nu este GR
    if (nr_neterminali_dr >= 2 && tip_gramatica == "GR") {
        tip_gramatica = "GIC";
    }
}
<REGULA>{spaces}";"{spaces}{newline} {
    numar_reguli++;

    // se verifica daca sunt mai multe elemente in stanga decat in dreapta
    if (nr_neterminali_st + nr_litere_st > nr_neterminali_dr + nr_litere_dr)
        tip_gramatica = "GFR";

    // se revine in starea GRAMATICA
    yy_pop_state();
    yy_pop_state();
}
<REGULA>{spaces}|"&" {}



<GRUP_REGULI>"->" {
    nr_neterminali_dr = 0;
    nr_litere_dr = 0;
    yy_push_state(REGULA);
}
<GRUP_REGULI>{neterminal_nume} {
    nr_neterminali_st++;
    if (nr_litere_st + nr_neterminali_st > 1 && tip_gramatica != "GFR")
        tip_gramatica = "GDC";
}
<GRUP_REGULI>[a-z0-9] {
    nr_litere_st++;
    if (nr_litere_st + nr_neterminali_st > 1 && tip_gramatica != "GFR")
        tip_gramatica = "GDC";
}
<GRUP_REGULI>{spaces}";"{spaces}{newline} {
    yy_pop_state();
}
<GRUP_REGULI>{spaces}|. {}


<GRAMATICA>{tab}/.*"->".* {
    nr_neterminali_st = 0;
    nr_litere_st = 0;
    // se salveaza numele starii
    yy_push_state(GRUP_REGULI);
}

<GRAMATICA>{tab}{alphabet} {
    yy_push_state(ALPHABET);
}

<GRAMATICA>{tab}{nonterminals} {
    yy_push_state(NONTERMINALS);
}

<GRAMATICA>{tab}{start_symbol} {
    // TODO change neterminalii incep cu litera mare
    yy_push_state(START_SYMBOL);
}

<GRAMATICA>{tab}{variable} {
    /*
        updatare pt noua variabila locala
    */
    numar_var_locale++;
    valoare_var.clear();
    yy_push_state(LOCAL_VARIABLE);
}

<GRAMATICA>"("{spaces}\n {
    numar_var_locale = 0;
    numar_reguli = 0;
    tip_gramatica = "GR";
    alfabet.clear();
    stari_finale.clear();
    stari.clear();
    tranzitii.clear();
}

<GRAMATICA>% { yy_push_state(IN_SINGLE_COMMENT); }
<GRAMATICA>"/*" { yy_push_state(IN_MULTIPLE_COMMENT); }

<GRAMATICA>{spaces}")"{spaces}";;"{spaces} {
    // scrie info despre gramatica

    int size = alfabet.size();

    printf("Tipul gramaticii: %s\n", tip_gramatica.c_str());
    printf("Numarul de reguli de productie: %d\n", numar_reguli);

    printf("Alfabetul gramaticii: {");
    for (int i = 0; i < size; i++) {
        if (i + 1 != size)
            printf("%c, ", alfabet[i]);
        else
            printf("%c", alfabet[i]);
    }
    printf("}\n");

    for (int i = 0; i < numar_var_locale; i++) {
        printf("Variabila locala:\n\tIndetificator: %s\n", variabile[variabile.size() - 1].first.c_str());
        printf("\tDomeniu: {");
        int size = variabile[variabile.size() - 1].second.size();

        for (int j = 0; j < size; j++) {
            if (j + 1 == size) {
                printf("%c", variabile[variabile.size() - 1].second[j]);
            } else {
                printf("%c, ", variabile[variabile.size() - 1].second[j]);
            }
        }
        printf("}\n");

        // se scoate variabila locala din vector
        variabile.pop_back();
    }
    printf("\n");

    yy_pop_state();
}
<GRAMATICA>{spaces}|\n|{tab}|{semn_egal}{gramatica_tip} {}



<INITIAL>% { yy_push_state(IN_SINGLE_COMMENT); }
<INITIAL>"/*" { yy_push_state(IN_MULTIPLE_COMMENT); }

<INITIAL>"variable" {
    /*
        se identifica o variabila
    */
    printf("Variabila globala:\n");

    valoare_var.clear();
    yy_push_state(VARIABLE);
}

<INITIAL>{automat_nume}/{semn_egal}{automat_tip} {
    /*
        se identifica definitia unui automat
    */
    printf("Numele automatului: %s\n", yytext);
    yy_push_state(AUTOMAT);
}

<INITIAL>{automat_nume}/{semn_egal}{gramatica_tip} {
    /*
        se identifica definitia unei gramatici
    */
    printf("Numele gramaticii: %s\n", yytext);
    yy_push_state(GRAMATICA);
}
<INITIAL>.|{newline} {}

%%

char **fisiere;
int cnt_fisier, num_fisiere;

int yywrap()
{
    FILE *fisier = NULL;

    fclose(yyin);

    // se verifica daca mai sunt fisiere de parcurs
    if (cnt_fisier + 1< num_fisiere) {
        fisier = fopen(fisiere[cnt_fisier++], "r");

        // se verifica daca fisierul nu a fost deschis corect
        if (fisier == NULL) {
            printf("Nu s a putut deschide fisierul %s\n", fisiere[cnt_fisier - 1]);
            return 0;
        }
    }

    yyin = fisier;

    return fisier == NULL;
}

int main(int argc, char **argv)
{
    // se verifica daca nr de argumente este corect
    if (argc < 2) {
        printf("Nr incorect de argumente [num] [files] ... \n");
        return -1;
    }

    // se initializeaza variabilele
    num_fisiere = argc - 1;
    cnt_fisier = 0;
    fisiere = argv + 2;

    // se deschide primul fisier
    FILE *fisier = fopen(fisiere[cnt_fisier++], "r");
    if (fisier == NULL) {
        printf("Nu s a putut deschide fisierul %s\n", fisiere[cnt_fisier - 1]);
        return -1;
    }

    yyin = fisier;

    yylex();

    return 0;
}
