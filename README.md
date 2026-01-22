
# TEMA FLEX

Pentru implementarea temei am lucrat in Visual Studio Code in MacOS, folosind C++ in loc de C, deoarece am folosit
structuri de date precum vector si de "string" pentru a lucra mai usor cu sirurile de caractere.

## Stari folosite

Am folosit starea INITIAL ca stare initiala predefinita in Flex pentru:

    -> a ignora comentariile (atat cele pe un singur rand cat si cele pe mai multe randuri). Pentru a implementa
    asta, am folosit 2 stari secundare IN_SINGLE_COMMENT si IN_MULTIPLE_COMMENT. Aceste stari ignora orice caracter
    si ies automat din stare la intalnirea caracterului care marcheaza finalul unui comentariu. (\n in cazul unui comenrtariu
    pe un singur rand si *\ pentru unul pe mai multe randuri) Aceste stari revin in starea precedenta aceasta nu este mereu
    starea INITIAL, intrucat pot aparea comentarii in interiorul definitiei automatului sau gramaticii.

    -> a detecta declaratia unei variabile globale, caz in care se muta in starea VARIABLE. Aceasta stare are rolul de a extrage
    numele variabile si de a retine intr-un vector perechea (nume, vector de valori). Intrucat este o variabila globala se afiseaza
    si informatiile relevante acesteia(nume si valoarea) conform enuntului. Din aceasta satre se face trecerea in starea VARIABLE_VALUES
    care are rolul de a extrage si salva fiecare litera din alfabet pe care variabila o retine.

    -> a detecta declaratia unui automat, caz in care se face trecerea in starea AUTOMAT. Aceasta stare are rolul de a extrage si afisa
    numele automatului si toate informatiile relevante precum starile, starea initiala, starile finale, alfabetul. (acestea putand
    aparea in orice ordine) Totodata exista reguli pentru detectarea declaratiei variabilelor locale si a tranzitiilor automatului.
    Pentru toate aceste informatii exista stari speciale folosite pentru a parsa si extrage informatiile dorite, informatii care ajung
    sa fie retinute in vector sau variabile, intrucat afisarea acestora trebuie facuta la finalul parsarii intregii declaratii a 
    automatului. Pentru fieare bloc de tranzitii (adica ceea ce urmareaza dupa ->) se foloseste starea GRUP_TRANZITII care are 
    rolul de a extrage starea de pornire a tranzitiilor, apoi face trecerea in starea TRANZITIE pentru a parsa toate tranzitiile si la 
    final sa revina in starea AUTOMAT. Pentru fiecare tranzitie intalnita se apeleaza functia verifica_tip() care verifica daca s-a
    schimbat tipul automatului. (acesta este initial determinist pana la intalnirea unei reguli care nu respecta conditia)
    Pentru fiecare tranzitie se tine cont di de aparitia variabilelor in definitia acestora. Prin faptul ca variabilele pot inlocui
    mai multe litere din alfabet acestea pot schimba tipul automatului astfel se foloseste o bucla care adauga toate tranzitiile pentru
    fiecare litera retinuta de variabila. La fiecare pas se face verificarea daca automatul se schimba din determinist in nedeterminist.

    -> a detecta declaratia unei gramatice, caz in care se face trecerea in starea GRAMATICA. Aceasta stare are rolul de a extrage si afisa
    numele gramaticei si toate informatiile relevante precum multimile de simboluri terminale, neterminale, simbolul de start si productiile.
    (acestea putand aparea in orice ordine) Totodata, exista reguli pentru detectarea simbolurilor si a regulilor de productie.
    Pentru toate aceste informatii exista stari speciale folosite pentru a parsa si extrage informatiile dorite, informatii care ajung
    sa fie retinute in vectori sau variabile, intrucat afisarea acestora trebuie facuta la finalul parsarii intregii declaratii a 
    gramaticei. Pentru o regula de productie (adica partea care urmeaza dupa simbolul ->) se foloseste starea GRUP_REGULI, care are 
    rolul de a extrage neterminalul din partea stanga a productiei, apoi face trecerea in starea REGULA pentru a parsa toate 
    regulile asociate si, la final, revine in starea GRAMATICA. Se tine cont si de utilizarea simbolurilor speciale in productii
    (cum ar fi e sau variabile), care pot schimba tipul gramaticei. Pentru determinarea tipului gramaticii se porneste presupunerea
    ca este GR (cel mai restrictiv tip), iar in functie de regulile intalnite se schimba acest tip. Se folosesc variabile pentru a 
    retine numarul de terminali din fiecare tranzitie(partea stanga si partea dreapta).

Pentru a se asigura faptul ca toate comentariile sunt ignoarate, in starea automatului si a gramaticii exista verificari pentru
a detecta inceputul unui comentariu si, astfel, se realizeaza tranzitia in starea pentru comentarii.

Numele fisierelor de input sunt trimise ca argument cand se ruleaza programul, iar output este scris in stdout.

#### Tip gramatica:

    --> GFR: orice gramatica
    --> GDC: in stanga se afla mai putine elemente decat in dreapta.
    --> GIC: in stanga se afla doar un singur element(adica doar un neterminal)
    --> GR: in dreapta se afla maxim un neterminal si se afla pe cea mai din dreapta pozitie
