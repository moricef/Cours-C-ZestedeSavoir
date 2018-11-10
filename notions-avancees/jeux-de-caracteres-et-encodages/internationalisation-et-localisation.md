Cela est resté finalement assez discret jusqu'à ce chapitre, mais en y regardant de plus près, les programmes que nous avons réalisés sont en fait destinés à un environnement anglophone. En effet, prenez par exemple les entrées : si nous souhaitons fournir un nombre flottant à notre programme, nous devons utiliser le point comme séparateur entre la partie entière et décimale. Or, dans certains pays, on pourrait vouloir utiliser la virgule à la place. Cela nous paraît moins étrange étant donné que les constantes flottantes sont écrites de cette manière en C, mais il n'en va pas de même pour nos utilisateurs.

Ce qu'il faudrait finalement, c'est que nos programmes puissent s'adapter aux usages, coutumes et langues de notre utilisateur, ce que nous avons entrevu dans la section précédente.

# L'internationalisation

L'**internationalisation** (parfois abrégée « i18n ») est un procédé par lequel un programme est rendu capable de s'adapter aux préférences linguistiques et régionales d'un utilisateur.

# La localisation

La **localisation** (parfois abrégée « l10n ») est une opération par laquelle un programme internationalisé se voit fournir les informations nécessaires pour s'adapter aux préférences linguistiques et régionales d'un utilisateur.

# La fonction setlocale

De manière générale, les programmes que nous avons conçus jusqu'ici étaient déjà partiellement internationalisés, car la bibliothèque standard du langage C l'est dans une certaine mesure. Toutefois, nous n'avons jamais recouru à un processus de localisation pour que ceux-ci s'adaptent à nos usages. Nous vous le donnons en mille : la localisation en C s'effectue à l'aide de... la fonction `setlocale()`.

```c
char *setlocale(int categorie, char *localisation);
```

Cette fonction attends deux arguments : une catégorie et la localisation qui doit être employée pour cette catégorie.

## Les catégories

La bibliothèque standard du C divise la localisation en plusieurs catégories, plus précisément cinq :

1. La catégorie `LC_COLLATE` qui modifie le comportement des fonctions `strcoll()` et `strxfrm()` ;
1. La catégorie `LC_CTYPE` qui adapte le comportement des fonctions de conversions que nous venons de voir, ainsi que les fonctions de l'en-tête `<ctype.h>` ;
1. La catégorie `LC_MONETARY` qui influence le comportement de la fonction `localeconv()` ;
1. La catégorie `LC_NUMERIC` qui altère le comportement des fonctions `*printf()` et `*scanf()` ainsi que des fonctions de conversions des chaînes de caractères (`atof()`, `strtod()`, etc.) en ce qui concerne les nombres flottants ;
1. La catégorie `LC_TIME` qui change le comportement de la fonction `strftime()`.

Enfin, la catégorie `LC_ALL` (qui n'en est pas vraiment une) représente toutes les catégories en même temps. Nous ne attarderons toutefois que sur `LC_CTYPE` et `LC_NUMERIC` dans cette section, les fonctions affectées par les autres catégories n'ayant pas été présentées à ce stade.

## Les localisations

La bibliothèque standard prévoit deux localisations possibles :

1. La localisation `"C"` qui correspond à celle par défaut. Celle-ci utilise les usages anglophones et part du principe que les caractères employés se limitent à ceux garantis par la norme et qu'ils sont tous représentés sur un multiplet ;
2. La localisation `""` (une chaîne vide) qui correspond à celle utilisée par votre système.

Il est également possible de fournir un pointeur nul comme localisation, auquel cas la localisation actuelle est retournée.

```c
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>


int main(void)
{
	char *s;

	s = setlocale(LC_ALL, NULL);
	puts(s);

	if (setlocale(LC_ALL, "") == NULL)
	{
		perror("setlocale");
		return EXIT_FAILURE;
	}

	s = setlocale(LC_ALL, NULL);
	puts(s);
	return 0;
}
```

```text
C
fr_BE.UTF-8
```

Comme vous le voyez, la localisation de départ est bien `C`.

[[information]]
| La forme que prend la localisation dépend de votre système. Sous unixoïdes et dans notre exemple, elle prend la forme de la langue en minuscule (au format [ISO 639](https://fr.wikipedia.org/wiki/ISO_639)) suivie d'un tiret bas et du pays en majuscule (au format [ISO 3166-1](https://fr.wikipedia.org/wiki/ISO_3166)) et, éventuellement, terminée par un point et par l'encodage utilisé.

# Exemple

Nous avons déjà eu l'occasion d'expérimenter la modification de la localisation de la catégorie `LC_CTYPE`. Ainsi, nous avons pu préciser aux fonctions de conversion que la traduction devait s'opérer depuis et vers le jeu de caractères d'exécution complet et non uniquement le sous-ensemble défini par la norme.

L'exemple ci-dessous modifie la localisation de la catégorie `LC_NUMERIC` pour que les fonctions `scanf()` et `printf()` adaptent leur gestion et affichage des nombres flottants.

```c
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>


int main(void)
{
	double f;

	if (setlocale(LC_NUMERIC, "") == NULL)
	{
		perror("setlocale");
		return EXIT_FAILURE;
	}

	printf("Veuillez entrer un nombre flottant : ");

	if (scanf("%lf", &f) != 1)
	{
		perror("scanf");
		return EXIT_FAILURE;
	}

	printf("Vous avez entré : %f.\n", f);
	return 0;
}
```

```text
Veuillez entrer un nombre flottant : 45,5
Vous avez entré : 45,500000.

Veuillez entrer un nombre flottant : 45.5
Vous avez entré : 45,000000.
```

Comme vous le voyez, après l'appel à `setlocale()`, seule la virgule est considérée comme séparateur de la partie entière et de la partie décimale.