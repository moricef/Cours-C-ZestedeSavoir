Une énumération se défini à l'aide du mot-clé `enum` suivi du nom de l'énumération et de ses membres.

```c
enum naturel { ZERO, UN, DEUX, TROIS, QUATRE, CINQ };
```

La particularité de cette définition est qu'elle crée en vérité deux choses : un type dit « énuméré » `enum naturel` et des constantes dites « énumérées » `ZERO`, `UN`, `DEUX`, etc. Le type énuméré ainsi produit peut être utilisé de la même manière que n'importe quel autre type. Quant aux constantes énumérées, il s'agit de constantes entières.

Certes me direz-vous, mais que valent ces constantes ? *Eh* bien, à défaut de préciser leur valeur, chaque constante énumérée se voit attribuer la valeur de celle qui la précède augmentée de un, sachant que la première constante est mise à zéro . Dans notre cas donc, la constante `ZERO` vaut zéro, la constante `UN` un et ainsi de suite jusque cinq.

L'exemple suivant illustre ce qui vient d'être dit.

```c
#include <stdio.h>

enum naturel { ZERO, UN, DEUX, TROIS, QUATRE, CINQ };


int main(void)
{
	enum naturel n = ZERO;

	printf("n = %d.\n", (int)n);
	printf("UN = %d.\n", UN);
	return 0;
}
```

```text
n = 0.
UN = 1.
```

[[information]]
| Notez qu'il n'est pas obligatoire de préciser un nom lors de la définition d'une énumération. Dans un tel cas, seules les constantes énumérées sont produites.
|
|```c
| enum { ZERO, UN, DEUX, TROIS, QUATRE, CINQ };
|```

Toutefois, il est possible de préciser la valeur de certaines constantes (voire de toutes les constantes) à l'aide d'une affectation.

```c
enum naturel { DIX = 10, ONZE, DOUZE, TREIZE, QUATORZE, QUINZE };
```

Dans un tel cas, la règle habituelle s'applique : les constantes sans valeur se voit attribuer celle de la constante précédente augmentée de un et celle dont la valeur est spécifiée sont initialisées avec celle-ci. Dans le cas ci-dessus, la constante `DIX` vaut donc dix, la constante `ONZE` onze et ainsi de suite jusque quinze. Notez que le code ci-dessous est parfaitement équivalent.

```c
enum naturel { DIX = 10, ONZE = 11, DOUZE = 12, TREIZE = 13, QUATORZE = 14, QUINZE = 15 };
```

## Types entiers sous-jacents

Vous aurez sans doute remarqué que, dans notre exemple, nous avons converti la variable `n` vers le type `int`. Cela tient au fait qu'un type enuméré est un type entier (ce qui est logique puisqu'il est censé stocker des constantes entières), mais que le type sous-jacent n'est pas déterminé (cela peut donc être `char`, `short`, `int` ou `long`) et dépend entre autre des valeurs devant être contenues. Ainsi, une conversion s'impose afin de pouvoir utiliser un format d'affichage correct.

Pour ce qui est des constantes énumérées, c'est plus simple : elles sont toujours de type `int`.

