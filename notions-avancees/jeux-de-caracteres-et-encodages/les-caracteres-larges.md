# Mise en situation

Si nous devons tâcher de respecter la norme en n'employant pas de caractères en dehors de ceux garantis, cela n'est pas vrai pour les utilisateurs de nos programmes qui, eux, ne se gêneront pas pour utiliser ceux supportés par leur système (c'est d'ailleurs bien là l'intérêt de choisir la langue de son système).

Or, jusqu'à présent, nous sommes toujours partis du principe que les caractères entrés tenaient sur un seul `char`, ce qui n'est pas toujours vrai, comme vous avez pu le voir au travers du cours de Maëlan.

En fait, il s'agit du comportement *par défaut* des fonctions de la bibliothèque standard. Chaque `char` est supposé représenter un caractère et une chaîne de caractères est censée n'être qu'une suite de `char` finie par un zéro.

Il est possible de s'en rendre compte à l'aide du code suivant.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(void)
{
	char chaine[255];
	char *nl;

	if (fgets(chaine, sizeof chaine, stdin) == NULL)
	{
		perror("fgets");
		return EXIT_FAILURE;
	}

	nl = strchr(chaine, '\n');

	if (nl != NULL)
		*nl = '\0';

	printf("Longueur : %u\n", (unsigned)strlen(chaine));
	return 0;
}
```

```text
Bonjour   
Longueur : 7

Élégament trouvé
Longueur : 19
```

Comme vous le voyez, la taille de la chaîne « Élégament trouvé » n'est pas celle attendue dans notre cas (notre exemple emploie l'UTF-8 comme encodage) car ce sont les multiplets (les `char`, donc) qui ont été comptés et non les caractères. La bonne réponse aurait dû être 16.

# Les caractères larges

Afin de résoudre ce problème, la norme C89 a introduit les **caractères larges**. Pour ce faire, un nouveau type a été introduit : le type `wchar_t` (pour _**w**ide **c**haracter_), défini dans l'en-tête `<stddef.h>`. Celui-ci n'est rien d'autre qu'un type entier (signé ou non signé) capable de représenter le point de code le plus élevé supporté par le système.

L'objectif recherché est de traduire une chaîne de caractères classique recourant à un encodage avec un nombre variable de multiplets (comme l'UTF-8 ou l'ISO-2022) vers une chaîne de caractères larges dont chacun représentera exactement un caractère. Dans le cas de chaînes de caractères en UTF-8 par exemple, celles-ci seront le plus souvent converties en UTF-16 ou en UTF-32.

À cet effet, plusieurs fonctions de conversions sont mises à notre disposition et sont définies dans l'en-tête `<stdlib.h>`. Toutefois, aucune fonction de traitement de ces chaînes n'est fournie, c'est-à-dire que celles-ci doivent être manipulées « à la main » (il n'y a donc par exemple pas de fonction du type `strlen()` qui manipule une chaîne de `wchar_t`).

[[information]]
| En vérité, les normes suivantes du langage C (à commencer par un amendement adopté en 1994) ont ajouté des fonctions de traitements des chaînes de caractères larges ainsi que d'autres fonctions de conversions dites « réentrantes » (c'est-à-dire qui peuvent être appelées simultanément par plusieurs fils d'exécutions ou *threads* en anglais). Toutefois, nous ne les aborderons pas dans ce cours, d'une part parce que celui-ci se fonde sur la norme C89 et, d'autre part, parce que leur présentation mériterait plusieurs chapitres à elle seule.

## Les fonctions mbtowc et wctomb

```c
int mbtowc(wchar_t *destination, const char *chaine, size_t max);
int wctomb(char *destination, wchar_t source);
```

La fonction `mbtowc()` (pour _**m**ulti**b**yte character **to** **w**ide **c**haracter_) convertit une suite de multiplets en un caractère large (qu'elle stocke dans l'objet référencé par `destination`) en lisant au plus `max` multiplets depuis la chaîne `source`. Elle retourne le nombre de multiplets utilisés pour produire le caractère large ou `-1` en cas d'erreur.

La fonction `wctomb()` (pour _**w**ide **c**haracter **to** **m**ulti**b**yte character_) effectue l'opération inverse : elle convertit le caractère large `source` en une suite de multiplets qui sera stockée dans le tableau `destination`. Elle retourne le nombre de multiplets produits en cas de succès et `-1` en cas d'erreur.

### La fonction mbtowc

L'exemple ci-dessous lit une ligne depuis l'entrée standard et convertit la première suite de multiplets représentant un caractère en un caractère large.

```c
#include <locale.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(void)
{
	char chaine[255];
	wchar_t wc;
	char *nl;
	int n;

	if (setlocale(LC_CTYPE, "") == NULL)
	{
		perror("setlocale");
		return EXIT_FAILURE;
	}
	if (fgets(chaine, sizeof chaine, stdin) == NULL)
	{
		perror("fgets");
		return EXIT_FAILURE;
	}

	nl = strchr(chaine, '\n');

	if (nl != NULL)
		*nl = '\0';

	n = mbtowc(&wc, chaine, MB_CUR_MAX);

	if (n <= 0)
	{
		perror("mbtowc");
		return EXIT_FAILURE;
	}


	printf("%d multiplet(s) a(ont) été lu pour produire la valeur %u.\n", \
	n, (unsigned)wc);
	return 0;
}
```

```text
Élégamment trouvé
2 multiplet(s) a(ont) été lu pour produire la valeur 201.

ASCII
1 multiplet(s) a(ont) été lu pour produire la valeur 65.
```

[[information]]
| Les résultats obtenus dépendent bien entendu du jeu de caractères utilisé par votre système. Si ce dernier n'emploie pas l'Unicode ou n'utilise pas l'UTF-8 comme encodage, la sortie du programme peut être différente.

Comme vous le voyez, étant donné que notre système emploie de l'UTF-8, deux multiplets ont été lus depuis la chaîne `chaine` pour construire la valeur du caractère `É`, soit 201 (qui correspond à son point de code dans le jeu de caractères Unicode). Le caractère `A` étant quant à lui représenté sur un seul multiplet en UTF-8, la lecture d'un seul suffit pour obtenir sa valeur, à savoir `65`.

L'en-tête `<locale.h>` a été ajouté en vue d'utiliser la fonction `setlocale()` dont nous parlerons dans la prochaine section. Sachez pour l'instant qu'elle doit être appelée *avant* d'utiliser les fonctions de conversions.

`MB_CUR_MAX` est une macro (elle est éfinie dans l'en-tête `<stdlib.h>`) dont la valeur est déterminée par la *locale* courante (nous y reviendrons lorsque nous aborderons la fonction `setlocale()`) et correspond au nombre maximum de multiplets nécessaires pour construire un caractère large *dans la* locale *actuelle*.

### La fonction wctomb

Comme nous vous l'avons dit, la fonction `wctomb()` effectue l'exact inverse de la fonction `mbtowc()`. L'exemple suivant tente de convertir le caractère large `É` en la suite de multiplets correspondante.

```c
#include <limits.h>
#include <locale.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>


int main(void)
{
	char tab[MB_LEN_MAX];
	int i;
	int n;

	if (setlocale(LC_CTYPE, "") == NULL)
	{
		perror("setlocale");
		return EXIT_FAILURE;
	}

	n = wctomb(tab, L'É');

	if (n <= 0)
	{
		perror("wctomb");
		return EXIT_FAILURE;
	}

	for (i = 0; i < n; ++i)
		printf("%x ", (unsigned char)tab[i]);

	putchar('\n');
	return 0;
}
```

```text
c3 89
```

Ici, nous essayons de convertir le caractère large `É` (notez qu'une constante de type caractère large peut être définie en la faisant précédé de la lettre `l` ou `L`) en une suite de multiplets qui sera stockée dans le tableau `tab`.

La taille du tableau `tab` a été fixée à `MB_LEN_MAX`, une macroconstante définie dans l'en-tête `<limits.h>` correspondant à la plus grande suite de multiplets pouvant représenter un caractère sur le système. Notez bien la différence avec la macro `MB_CUR_MAX` qui se limite à la *locale* courante. Par ailleurs, la valeur de `MB_CUR_MAX` dépendant des appels à la fonction `setlocale()`, elle ne peut être utilisée pour déterminer la taille d'un tableau lors de sa définition.

Une fois la conversion effectuée, nous affichons la valeur des différents multiplets en hexadécimal (remarquez la conversion en `unsigned char` afin d'éviter l'affichage de nombres négatifs).

[[attention]]
| Dans le cas où vous insérez une constante de type caractère large dans votre code source comme `L'É'`, les mêmes restrictions s'appliquent que pour les caractères simples : si le caractère en question ne fait pas partie du jeu de caractères source ou d'exécution, le résultat n'est pas déterminé par la norme. Une telle pratique est donc à proscrire également, pour les mêmes motifs que précédemment.

## Convertir une chaîne complète

Bien entendu, ces deux fonctions peuvent être utilisées en combinaison avec une boucle en vue de convertir une chaîne de caractères entière (c'est même là tout l'intérêt de la chose).

```c
#include <locale.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(void)
{
	char mbs[255];
	wchar_t wcs[255];
	char *nl;
	char *pc;
	int n;
	int i;

	if (setlocale(LC_CTYPE, "") == NULL)
	{
		perror("setlocale");
		return EXIT_FAILURE;
	}
	if (fgets(mbs, sizeof mbs, stdin) == NULL)
	{
		perror("fgets");
		return EXIT_FAILURE;
	}

	nl = strchr(mbs, '\n');

	if (nl != NULL)
		*nl = '\0';

	pc = mbs;

	for (i = 0; (n = mbtowc(&wcs[i], pc, MB_CUR_MAX)) > 0; ++i)
	{
		if (*pc == '\0')
			break;

		pc += n;
	}

	if (*pc != '\0')
	{
		perror("mbtowc");
		return EXIT_FAILURE;
	}

	for (i = 0; wcs[i] != L'\0'; ++i)
		printf("%u ", (unsigned)wcs[i]);

	putchar('\n');
	return 0;
}
```

```text
Élégament trouvé                   
201 108 233 103 97 109 101 110 116 32 116 114 111 117 118 233 
```

Comme vous le voyez, nous appelons la fonction `mbtowc()` tant que celle-ci ne rencontre pas une erreur ou que nous ne rencontrons pas le caractère de fin de chaîne (ce dernier devant également être converti, cette seconde condition est placée au sein de la boucle). Ensuite, suivant le nombre de multiplets lus par `mbtowc()`, nous augmentons la valeur du pointeur `pc` afin de référencer les prochains caractères à lire. À la sortie de la boucle, nous vérifions que le pointeur `pc` pointe bien vers le caractère nul sans quoi cela signifie que la fonction `mbtowc()` a rencontré une erreur. Enfin, nous parcourons la chaînes large `wcs` pour afficher les différents points de code des caractères la composant.

[[information]]
| Notez que comme la comparaison `wcs[i] != L'\0'` porte sur le caractère large `wcs[i]`, nous avons fait du second opérande un caractère large également. Le caractère nul étant garanti de faire partie du jeu de caractères d'exécution, cela ne pose pas de problèmes.

## Les fonction mbstowcs et wcstombs

```c
size_t mbstowcs(wchar_t *destination, char *source, size_t max);
size_t wcstombs(char *destination, wchar_t *source, size_t max);
```

C'est chouette de pouvoir employer des boucles, mais cela reste assez fastidieux... Heureusement pour nous, il existe des fonctions qui se chargent de le faire pour nous. ^^  
Les fonctions `mbstowcs()` et `wcstombs()` convertissent une chaîne de caractères vers une chaîne de caractères larges et inversement. Elles stockent les `max` premiers caractères produits dans la chaîne `destination`.

Les deux fonctions retournent le nombre de caractères convertis (hors caractère nul final) ou `(size_t)-1` en cas d'erreurs.

Ci-dessous, un exemple de conversion recourant à la fonction `mbstowcs()` qui nous permet de rendre notre programme initial correct. Notez que nous avons dû réaliser notre propre version de `strlen()` afin de calculer la longueur de la chaîne de caractères larges obtenues.

```c
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>


static size_t
wchar_len(wchar_t *wcs)
{
	size_t i = 0;

	while (wcs[i] != L'\0')
		++i;

	return i;
}


int main(void)
{
	wchar_t wcs[255];
	char mbs[255];
	char *nl;

	if (setlocale(LC_CTYPE, "") == NULL)
	{
		perror("setlocale");
		return EXIT_FAILURE;
	}
	if (fgets(mbs, sizeof mbs, stdin) == NULL)
	{
		perror("fgets");
		return EXIT_FAILURE;
	}

	nl = strchr(mbs, '\n');

	if (nl != NULL)
		*nl = '\0';

	if (mbstowcs(wcs, mbs, sizeof mbs) == (size_t)-1)
	{
		perror("mbstowcs");
		return EXIT_FAILURE;
	}

	printf("Nombre de multiplets : %u\n", (unsigned)strlen(mbs));
	printf("Nombre de caractères : %u\n", (unsigned)wchar_len(wcs));
	return 0;
}
```

```text
Élégament trouvé
Nombre de multiplets : 19
Nombre de caractères : 16
```

## La fonction mblen

```c
int mblen(char *chaine, size_t max);
```

La fonction `mblen()` lit au plus `max` multiplets de la chaîne `chaine`. Si ceux-ci forment un caractère large valide, elle retourne le nombre de multiplets qui seront utilisés pour le composer. Dans le cas contraire, elle retourne soit `0` (si le premier caractère est le caractère nul) ou `-1` (la suite de multiplets ne correspond pas à un caractère large).

```c
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>


int
main(void)
{
	int n;

	if (setlocale(LC_CTYPE, "") == NULL)
	{
		perror("setlocale");
		return EXIT_FAILURE;
	}

	n = mblen("Élégamment trouvé", MB_CUR_MAX);

	if (n > 0)
		printf("Le prochain caractère large sera composé de %d multiplet(s).\n", n);

	return 0;
}
```

```text
Le prochain caractère large sera composé de 2 multiplet(s).
```

# Des fonctions dans tous leurs états

Il est important de vous préciser une chose en rapport avec ces fonctions : elles disposent d'un **état** interne. En vérité, ceci est essentiellement important dans le cas où vous utilisez un jeu de caractères avec état comme l'ISO-2022-JP. Dans un tel cas, les fonctions de conversions doivent mémoriser la dernière séquence d'échappement afin d'effectuer correctement leur travail, ce qu'elles réalisent à l'aide de variables internes. Or, si une erreur est rencontrée ou si une autre suite de multiplets leur est donnée en cours de route, le résultat risque de s'en trouver compromis.

Dès lors, il est nécessaire de réinitialiser cet état interne après la rencontre d'une erreur ou lors d'un changement de données à traiter. Cela se réalise très simplement en fournissant comme argument une chaîne nulle à l'une des fonctions `mbtowc()`, `wctomb()` ou `mblen()`. Dans un tel cas, l'état interne est remis à zéro et une valeur nulle est retournée si le jeu de caractères courant n'utilise pas d'état et un nombre strictement positif sinon.