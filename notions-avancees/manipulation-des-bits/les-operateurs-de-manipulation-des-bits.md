# Présentation

Le langage C définit six opérateurs permettant de manipuler les *bits* :

* l'opérateur « et » : `&` ;
* l'opérateur « ou inclusif » : `|` ;
* l'opérateur « ou exclusif » : `^` ;
* l'opérateur de négation ou de complément : `~` ;
* l'opérateur de décalage à droite : `>>` ;
* l'opérateur de décalage à gauche : `<<`.

[[erreur]]
| Veillez à ne pas confondre les opérateurs de manipulations des *bits* « et » (`&`) et « ou inclusif » (`|`) avec leurs homologues « et » (`&&`) et « ou » (`||`) logiques. Il s'agit d'opérateurs totalement différent au même titre que les opérateurs d'affectation (`=`) et d'égalité (`==`). De même, l'opérateur de manipulations des *bits* « et » (`&`) n'a pas de rapport avec l'opérateur d'adressage (`&`), ce dernier n'utilisant qu'un opérande.

[[attention]]
| Notez que tous ces opérateurs travaillent uniquement sur des *entiers*.
|
| Si néanmoins vous souhaitez modifier la représentation d'un type flottant (ce que nous vous déconseillons), vous pouvez accéder à ses *bits* à l'aide d'un pointeur sur `unsigned char` (revoyez [le chapitre sur l'allocation dynamique](https://zestedesavoir.com/tutoriels/755/le-langage-c-1/1043_aggregats-memoire-et-fichiers/4285_lallocation-dynamique/#1-14293_la-notion-dobjet) si cela ne vous dit rien).

# Les opérateurs « et », « ou inclusif » et « ou exclusif »

Chacun de ces trois opérateurs attend deux opérandes entiers et produit un nouvel entier en appliquant une table de vérité à chaque paire de *bits* formée à partir des *bits* des deux nombres de départs. Plus précisémment :

- L'opérateur « et » (`&`) donnera 1 si les deux *bits* de la paire sont à 1 ;
- L'opérateur « ou inclusif » (`|`) donnera 1 si *au moins* un des deux *bits* de la paire est à 1 ;
- L'opérateur « ou exclusif » (`^`) donnera 1 si *un seul* des deux *bits* de la paire est à 1.

Ceci est résumé dans le tableau ci-dessous, donnant le résultat des trois opérateurs pour chaque paires de *bits* possibles.

| *Bit* 1 | *Bit* 2 | Opérateur « et » | Opérateur « ou inclusif » | Opérateur « ou exclusif » |
| ------- | ------- | ---------------- | ------------------------- | ------------------------- |
| 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 1 | 1 |
| 1 | 1 | 1 | 1 | 0 |

L'exemple ci-dessous utilise ces trois opérateurs. Comme vous le voyez, les *bits* des deux opérandes sont pris un à un pour former des paires et chacune d'elle se voit appliquer la table de vérité correspondante afin de produire un nouveau nombre entier.

```c
#include <stdio.h>


int main(void)
{
    int a = 0x63; /* 0x63 == 99 == 0110 0011 */
    int b = 0x2A; /* 0x2A == 42 == 0010 1010 */

    /* 0110 0011 & 0010 1010 == 0010 0010 == 0x22 == 34 */
    printf("%2X\n", a & b);
    /* 0110 0011 | 0010 1010 == 0110 1011 == 0x6B == 107 */
    printf("%2X\n", a | b);
    /* 0110 0011 ^ 0010 1010 == 0100 1001 == 0x49 == 73 */
    printf("%2X\n", a ^ b);
    return 0;
}
```

```text
22
6B
49
```

# L'opérateur de négation ou de complément

L'opérateur de négation a un fonctionnement assez simple : il inverse les *bits* de son opérande (les uns deviennent des zéros et les zéros des uns).

```c
#include <stdio.h>


int
main(void)
{
    unsigned a = 0x7F; /* 0111 1111 */

    /* ~0111 1111 == 1000 0000 */
    printf("%2X\n", ~a);
    return 0;
}
```

```
FFFFFF80
```

[[attention]]
| Notez que *tous* les *bits* ont été inversés, d'où le nombre élevé que nous obtenons puisque les *bits* de poids forts ont été mis à un. Ceci nous permet par ailleurs de constater que, sur notre machine, il y a visiblement quatre octets qui sont utilisés pour représenter la valeur d'un objet de type `unsigned int`.

[[erreur]]
| N'oubliez pas que les représentations entières *signées* ont chacune une représentation qui est susceptible d'être invalide. Les opérateurs de manipulation des *bits* vous permettant de modifier directement la représentation, vous devez éviter d'obtenir ces dernières.

Ainsi, les exemples suivants sont susceptibles de produire des valeurs incorrectes (à supposer que la taille du type `int` soit de quatre octets sans *bits* de bourrages).

```c
/* Invalide en cas de représentation en complément à deux ou signe et magnitude */
int a = ~0x7FFFFFFF;
/* Idem */
int b = 0x00000000 | 0x80000000;
/* Invalide en cas de représentation en complément à un */
int c = ~0;
/* Idem */
int d = 0x11110000 ^ 0x00001111;
```

[[information]]
| Notez toutefois que les entiers *non signés*, eux, ne subissent pas ces restrictions. 

# Les opérateurs de décalage

Les opérateurs de décalage, comme leur nom l'indique, décalent la valeur des *bits* d'un objet d'une certaine quantité, soit vers la gauche (c'est-à-dire vers le *bit* de poids fort), soit vers la droite (autrement dit, vers le *bit* de poids faible). Ils attendent deux opérandes : le nombre dont les *bits* doivent être décalés et la grandeur du décalage.

[[erreur]]
| Un décalage ne peut être négatif ni être supérieur *ou égal* au nombre de *bits* composant l'objet décalé. Ainsi, si le type `int` utilise 32 *bits* (sans *bits* de bourrage), le décalage ne peut être plus grand que 31.

## L'opérateur de décalage à gauche

L'opérateur de décalage à gauche translate la valeur des *bits* vers le *bit* de poids forts. Les *bits* de poids faibles perdant leur valeur durant l'opération sont mis à zéro. Techniquement, l'opération de décalage à gauche revient à calculer la valeur de l'expression a × 2^y^.

```c
#include <stdio.h>


int
main(void)
{
    /* 0000 0001 << 2 == 0000 0100 */
    int a = 1 << 2;
    /* 0010 1010 << 2 == 1010 1000 */
    int b = 42 << 2;

    printf("a = %d, b = %d\n", a, b);
    return 0;
}
```

```text
a = 4, b = 168
```

[[erreur]]
| La première opérande ne peut être un nombre négatif.

[[attention]]
| L'opération de décalage à gauche revenant à effectuer une multiplication, celle-ci est soumise au risque de dépassement de capacité que nous verrons au chapitre suivant.

## L'opérateur de décalage à droite

L'opérateur de décalage à droite translate la valeur des *bits* vers le *bit* de poids faible. Dans le cas où la première opérande est un entier *non signé* ou un entier signé *positif*, les *bits* de poids forts perdant leur valeur durant l'opération sont mis à zéro. Si en revanche il s'agit d'un nombre signé *négatif*, les *bits* perdant leur valeur se voient mis à zéro ou un suivant la machine cible. Techniquement, l'opération de décalage à droite revient à calculer la valeur de l'expression a / 2^y^.

```c
#include <stdio.h>


int
main(void)
{
    /* 0001 0000 >> 2 == 0000 0100 */
    int a = 16 >> 2;
    /* 0010 1010 >> 2 == 0000 1010 */
    int b = 42 >> 2;

    printf("a = %d, b = %d\n", a, b);
    return 0;
}
```

```text
a = 4, b = 10
```

[[information]]
| Dans le cas où une valeur est translatée au-delà du *bit* de poids faible, elle est tout simplement perdue.

# Opérateurs combinés

Enfin, sachez que, comme pour les opérations arithmétiques usuelles, les opérateurs de manipulation des *bits* disposent d'opérateurs combinés réalisant une affectation et une opération.

+----------------------------------+----------------------------------+
| ->Opérateur combiné<-            | ->Équivalent à<-                 |
+==================================+==================================+
|->variable &= nombre<-            | ->variable = variable & nombre<- |
|->variable |= nombre<-            | ->variable = variable | nombre<- |
|->variable ^= nombre<-            | ->variable = variable ^ nombre<- |
|->variable <<= nombre<-           | ->variable = variable << nombre<-|
|->variable >>= nombre<-           | ->variable = variable >> nombre<-|
+----------------------------------+----------------------------------+