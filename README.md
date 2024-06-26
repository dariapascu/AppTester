# AppTester
Script pentru testarea unei aplicații(timp de execuție, input-output, apeluri de sistem(strace), apeluri de biblioteca(ltrace). Modularizat.

# 18.06.2024
-am ales sa testez aplicatia GIMP (un editor foto) deoarece are multe functionalitati a caror timpi de executie, apeluri de sistem si de biblioteci pot varia in functie de modificarile facute
-am instalat aplicatia si m-am documentat despre cum poate fi actionata si din linie de comanda
-am ales o poza careia sa ii aplic un filtru alb-negru si am masurat timpul de executie al acestei actiuni

# 19.06.2024
-am organizat codul astfel incat sa fie mai usor de inteles si de utilizat
-am realizat scrierea in fisiere de log a apelurilor de sistem si biblioteci pe care le-am obtinut la aplicarea filtrului black and white
-am folosit ImageMagick pentru a testa si in cadrul scriptului daca imaginea rezultata la output este in alb si negru, pentru a nu fi nevoie sa se acceseze imaginea pentru verificarea rfezultatului

# 20.06.2024
-am realizat functia de redimensionare a imaginii care modifica dimensiunile imaginii cu cele specificate de utilizator, verifica daca modificarile s-au efectuat corespunzator, masoara timpul de executie al acestei operatii si inregistreaza apelurile de sistem si de biblioteci pe care le face aplicatia
-am adaugat in meniu verificari pentru minimizarea erorilor umane
-am inceput lucrul la o functie de rotire a imaginii conform datelor introduse de utilizator

# 21.06.2024 - 25.06.2024
-am facut un script in python care pune la dispozitie o interfata grafica si ruleaza scriptul din bash
-am adaugat un fisier "safe_syscalls" care contine apelurile de sistem considerate safe
-am afisat apelurile de sistem efectuate de functionalitatea care se testeaza din aplicatie care nu se afla in fisierul cu apeluri sigure si am dat posibilitatea utilizatorului sa le marcheze ca fiind safe, astfel acestea fiind adaugate in fisierul "safe_syscalls"

# 26.06.2024
-am adaugat posibilitatea de vizualizare a fisierelor create/modificate de aplicatia testata