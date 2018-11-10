# Obtenir la valeur maximale d'un type non signé

Maintenant que nous connaissons la représentation des nombres non signés ainsi que les opérateurs de manipulation des *bits*, vos devriez pouvoir trouver comment obtenir la plus grande valeur représentable par le type `unsigned int`.

## Indice

[[secret]]
| Rappelez-vous : dans la représentation des entiers non signés, chaque *bit* représente une puissance de deux.

## Solution

[[secret]]
|```c
| #include <stdio.h>
| 
| 
| int main(void)
| {
|     printf("%u\n", ~0U);
|     return 0;
| }
|```
|
| [[attention]]
| | Notez bien que nous avons utilisé le suffixe `U` afin que le type de la constante `0` soit `unsigned int` et non `int` (n'hésitez pas à revoir le chapitre relatif aux opérations mathématiques si cela ne vous dit rien).
|
| [[erreur]]
| | Cette technique n'est valable que pour les entiers *non signés*, la représentation où tous les *bits* sont à un étant potentiellement invalide dans le cas des entiers signés (représentation en complément à un).

# Afficher la représentation en base deux d'un entier

Vous le savez, il n'existe pas de format de la fonction `printf()` qui permet d'afficher la représentation binaire d'un nombre. Pourtant, cela pourait s'avérer bien pratique dans certains cas, même si la représentation hexadécimale est disponible.

Dans ce second exercice, votre tâche sera de réaliser une fonction capable d'afficher la représentation binaire d'un `unsigned int` *en gros-boutiste*.

## Indice

[[secret]]
| Pour afficher la représentation gros-boutiste, il va vous falloir commencer par afficher le *bit* de poids de fort suivit des autres. Pour ce faire, vous allez avoir besoin d'un masque dont seul ce *bit* sera à un. Pour ce faire, vous pouvez vous aider de l'exercice précédent.

## Solution

[[secret]]
|```c
| #include <stdio.h>
|
| 
| void affiche_bin(unsigned n)
| {
|     unsigned mask = ~(~0U >> 1);
|     unsigned i = 0;
| 
|     while (mask > 0)
|     {
|     	if (i != 0 && i % 4 == 0)
|     		putchar(' ');
| 
|     	putchar((n & mask) ? '1' : '0');
|     	mask >>= 1;
|     	++i;
|     }
| 
|     putchar('\n');
| }
| 
| 
| int main(void)
| {
|     affiche_bin(1);
|     affiche_bin(42);
|     return 0;
| }
|```
|
|```text
| 0000 0000 0000 0000 0000 0000 0000 0001
| 0000 0000 0000 0000 0000 0000 0010 1010
|```
|
| L'expression `~(~0U >> 1)` nous permet d'obtenir un masque ou seul le *bit* de poids fort est à un. Nous pouvons ensuite l'employer successivement en décalant le *bit* à un de sorte d'obtenir la représentation binaire d'un entier *non signé*.
|
| [[erreur]]
| | À nouveau, faites bien attention que ceci n'est valable que pour les entiers *non signés*, une représentation dont tous les *bits* sont à un ou dont seul le *bit* de poids fort est à un étant possiblement incorrecte dans le cas des entiers signés.

# Déterminer si un nombre est une puissances de deux

Vous le savez : les puissances de deux ont la particularité de n'avoir qu'un seul bit à un, tous les autres étant à zéro. Toutefois, elles ont une autre propriété : si l'on soustrait un à une puissance de deux $n$, tous les *bits* précédent celui de la puissance seront mis à un (par exemple `0000 1000 - 1 == 0000 0111`). En particulier, on remarque que $n$ et $n-1$ n'ont aucun bit à 1 en commun. Réciproquement, si $n$ n'est pas une puissance de 2, alors le bit à 1 le plus fort est aussi à 1 dans $n-1$. par exemple `0000 1010 - 1 == 0000 1001`). 

Sachant cela, il nous est possible de créer une fonction très simple déterminant si un nombre est une puissance de 2 ou non.

[[secret]]
| ```c
| #include <stdio.h>
| 
| 
| int puissance_de_deux(unsigned int n)
| {
|     return n != 0 && (n & (n - 1)) == 0;
| }
| 
| 
| int main(void)
| {
|     if (puissance_de_deux(256))
|         printf("256 est une puissance de deux\n");
|     else
|         printf("256 n'est pas une puissance de deux\n");
| 
|     if (puissance_de_deux(48))
|         printf("48 est une puissance de deux\n");
|     else
|         printf("48 n'est pas une puissance de deux\n");
| 
|     return 0;
| }
| ```
| 
| ```text
| 256 est une puissance de deux
| 48 n'est pas une puissance de deux
| ```