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