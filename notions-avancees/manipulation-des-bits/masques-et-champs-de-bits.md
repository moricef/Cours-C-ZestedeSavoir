# Les masques

Une des utilisations fréquentes des opérateurs de manipulations des *bits* est l'emploi de **masques**. Un masque est un ensemble de *bits* appliqué à un second ensemble *de même taille* lors d'une opération de manipulation des *bits* (plus précisément, uniquement les opérations `&`, `|` et `^`) en vue soit de sélectionner un sous-ensemble, soit de modifier un sous-ensemble.

## Modifier la valeur d'un bit

### Mise à zéro

Cette définition doit probablement vous paraître quelque peu abstraite, aussi, prenons un exemple.

```c
unsigned short n;
```

Nous disposons d'une variable `n` de type `unsigned short` (que nous supposerons composées de deux octets pour nos exemples) et souhaiterions mettre le *bit* de poids fort à zéro.

Une solution consiste à appliquer les opérateurs de manipulation des *bits* afin d'obtenir la valeur voulue. Étant donné que nous désirons mettre un *bit* à zéro, nous pouvons déjà abandonné l'opérateur `|` au vu de sa table de vérité. Également, l'opérateur `^` ne convient pas tout à fait puisqu'il inverserait la valeur du *bit* au lieu de la mettre à zéro. Il nous reste donc l'opérateur `&`.

Avec cet opérateur, il nous est possible d'utiliser une valeur qui nous donnera le bon résultat. Cette valeur, de même taille que celle de la variable `n`, est précisément un masque qui va « cacher », « masquer » une partie de la valeur.

```c
#include <stdio.h>
#include <stdlib.h>


int main(void)
{
	unsigned short n;

	if (scanf("%hx", &n) != 1)
	{
		perror("scanf");
		return EXIT_FAILURE;
	}

	printf("%X\n", n & 0x7FFF);
	return 0;
}
```

```text
8FFF
FFF

7F
7F
```

Comme vous le voyez, l'opérateur `&` peut être utilisé pour sélectionner une partie de la valeur de `n` en mettant à un les *bits* que nous souhaitons garder (en l'occurrence tous sauf le *bit* de poids fort) et les autres à zéro.

### Mise à un

À l'inverse, les opérateurs de manipulation des *bits* peuvent être employés pour mettre un ou plusieurs *bits* à un. Dans ce cas, c'est l'opérateur `&` qui ne convient pas au vu de sa table de vérité.

Si nous reprenons notre exemple précédent et que nous souhaitons modifier la valeur de la variable `n` de sorte de mettre à un le *bit* de signe, nous pouvons procéder comme suit.

```c
#include <stdio.h>
#include <stdlib.h>


int main(void)
{
	unsigned short n;

	if (scanf("%hx", &n) != 1)
	{
		perror("scanf");
		return EXIT_FAILURE;
	}

	printf("%X\n", n | 0x8000);
	return 0;
}
```

```text
FFF
8FFF

7F
807F
```

Comme vous le voyez, l'opérateur `|` peut être utilisé de la même manière dans ce cas ci à l'aide d'un masque dont les *bits* qui doivent être mis à un sont... à un.

# Les champs de bits

## Mise en situation

Une autre utilisation des opérateurs de manipulation des *bits* est le compactage de données entières.

Imaginons que nous souhaitions stocker la date courante sous la forme de trois entiers : l'année, le mois et le jour. La première solution qui vous viendra à l'esprit sera probablement de recourir à une structure, par exemple comme celle ci-dessous, ce qui est un bon réflexe.

```c
struct date {
	unsigned char jour;
	unsigned char mois;
	unsigned short annee;
};
```

Toutefois, nous gaspillons finalement de la mémoire avec ce système. En effet, techniquement, nous aurions besoin de 12 *bits* pour stocker l'année (afin d'avoir un peu de marge jusque l'an 4095 :p ), 4 pour le mois et 5 pour le jour, ce qui nous fait un total de 21 *bits* contre 32 pour notre structure (à supposer que le type  `short` fasse deux octets et le type `char` un octet), sans compter les multiplets de bourrage (revoyez le chapitre sur les structures si cela ne vous dit rien ;) ).

Ceci n'est pas gênant dans la plupart des cas, mais cela peut le devenir si la mémoire disponible vient à manquer ou si cette structure est amenée à être créée un grand nombre de fois.

Avec les opérateurs de manipulations des *bits*, il nous est possible de stocker ces trois champs dans un tableau de trois `unsigned char` afin d'économiser de la place.

```c
#include <stdio.h>
#include <stdlib.h>


static void modifie_jour(unsigned char *date, unsigned jour)
{
	/* Nous stockons le jour (cinq bits). */
	date[0] |= jour;
}


static void modifie_mois(unsigned char *date, unsigned mois)
{
	/* Nous ajoutons les trois premiers bits du mois après ceux du jour. */
	date[0] |= (mois & 0x07) << 5;
	/* Puis le bit restant dans le second octet. */
	date[1] |= (mois >> 3);
}


static void modifie_annee(unsigned char *date, unsigned annee)
{
	/* Nous ajoutons sept bits de l'année après le dernier bit du mois. */
	date[1] |= (annee & 0x7F) << 1;
	/* Et ensuite les cinq restants. */
	date[2] |= (annee) >> 7;
}


static unsigned calcule_jour(unsigned char *date)
{
	return date[0] & 0x1F;
}


static unsigned calcule_mois(unsigned char *date)
{
	return (date[0] >> 5) | ((date[1] & 0x1) << 3);
}


static unsigned calcule_annee(unsigned char *date)
{
	return (date[1] >> 1) | (date[2] << 7);
}


int
main(void)
{ 
	unsigned char date[3] = { 0 }; /* Initialisation à zéro. */
	unsigned jour, mois, annee;

	printf("Entrez une date au format jj/mm/aaaa : ");

	if (scanf("%u/%u/%u", &jour, &mois, &annee) != 3) {
		perror("fscanf");
		return EXIT_FAILURE;
	}

	modifie_jour(date, jour);
	modifie_mois(date, mois);
	modifie_annee(date, annee);
	printf("Le %u/%u/%u\n", calcule_jour(date), calcule_mois(date), calcule_annee(date));
	return 0;
}
```

```text
Entrez une date au format jj/mm/aaaa : 31/12/2042
Le 31/12/2042
```

Cet exemple amène quelques explications. ^^  
Une fois les trois valeurs récupérées, il nous les compacter dans le tableau d'`unsigned char` :

1. Pour le jour, c'est assez simple, nous incorporons ses cinq *bits* à l'aide de l'opérateur `|` (les trois éléments du tableau étant à zéro au début, cela ne pose pas de problème).
2. Pour le mois, seuls trois *bits* étant encore disponibles, il va nous falloir répartir ceux-ci sur deux éléments du tableau. Tout d'abord, nous sélectionnons les trois premiers *bits* à l'aide du masque `0x07`, nous les décalons ensuite de cinq *bits* vers la gauche (afin de ne pas écraser les cinq *bits* du jour) et, enfin, nous les ajoutons à l'aide de l'opérateur `|`. Le dernier *bit* est lui stocké dans le second élément et est sélectionné à l'aide d'un décalage vers la droite afin d'éliminer les trois premiers *bits* (qui ont déjà été traité).
3. Pour l'année, nous utilisons la même technique que pour le mois : nous sélectionnons les sept premiers *bits* à l'aide du masque `0x7F`, les décalons d'un *bit* vers la gauche en vue de ne pas écraser le *bit* du mois et les intégrons avec l'opérateur `|`. Les cinq *bits* restants sont ensuite insérer en recourant préalablement à un décalage de sept *bit* vers la droite.

## Présentation

Comme vous le voyez, si nous gagnons effectivement de la place en mémoire, nous y perdons en temps de calcul et, plus important, notre code est nettement plus complexe. C'est la raison pour laquelle cette méthode n'est employée que dans le cas de contraintes particulières.

Bien entendu, nous pourrions recourir à des fonctions ou à des macrofonctions pour simplifier la lecture du code, toutefois, nous ne ferions que reporter la difficulté de compréhension sur ces dernières. Heureusement, en vue de simplifier ce type d'écritures, le langage C met à notre disposition les **champs de _bits_**.

Un champ de *bits* est une structure *composée exclusivement* de champs de type `int` ou `unsigned int` dont la taille en *bits* de chacun est précisée. Cette taille *ne peut être* supérieure à la taille en *bits* du type `int`. L'exemple ci-dessous défini une structure composée de trois champs de *bits*, `a`, `b` et `c` de respectivement un, deux et trois *bits*.

```c
struct champ_de_bits
{
    unsigned a : 1;
    unsigned b : 2;
    unsigned c : 3;
};
```

Ainsi, notre exemple précédent peut être réécrit comme ceci.

```c
#include <stdio.h>
#include <stdlib.h>


struct date {
	unsigned jour : 5;
	unsigned mois : 4;
	unsigned annee : 12;
};


int
main(void)
{ 
	struct date date;
	unsigned jour, mois, annee;

	printf("Entrez une date au format jj/mm/aaaa : ");

	if (scanf("%u/%u/%u", &jour, &mois, &annee) != 3) {
		perror("fscanf");
		return EXIT_FAILURE;
	}

	date.jour = jour;
	date.mois = mois;
	date.annee = annee;

	printf("Le %u/%u/%u\n", date.jour, date.mois, date.annee);
	return 0;
}
```

[[erreur]]
| Les champs de *bits* ne disposent pas d'une adresse et ne peuvent en conséquence se voir appliquer l'opérateur d'adressage. Par ailleurs, nous vous conseillons de ne les employer que pour stocker des nombres non signés, le support des nombres signés n'étant pas garanti par la norme.

Si vous avez poussé la curiosité jusqu'à vérifier la taille de cette structure, il y a de forte chance pour que celle-ci équivaille à celle du type `int`. En fait, il s'agit de la méthode la plus courante pour conserver les champs de *bits* : ils sont stockés dans des suites de `int`. Dès lors, si vous souhaitez économiser de la place, faites en sorte que les données à stocker coïncident le plus possible avec la taille d'un ou plusieurs objets de type `int`.

[[attention]]
| Gardez à l'esprit que le compactage de données et les champs de *bits* répondent à des besoins particulier et complexifient votre code. Dès lors, ne les utilisez que lorsque cela semble réellement se justifier.