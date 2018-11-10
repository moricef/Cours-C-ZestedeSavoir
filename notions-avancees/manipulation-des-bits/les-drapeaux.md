Une autre utilisation régulière des opérateurs de manipulation des *bits* consiste en la gestion des **drapeaux**. Un drapeau correspond en fait à un *bit* qui est soit « levé », soit « baissé » dans l'objectif d'indiquer si une situation est vraie ou fausse.

Supposons que nous souhaitions fournir à une fonction un nombre et plusieurs de ses propriétés, par exemple s'il est pair, s'il s'agit d'une puissance de deux et s'il est premier. Nous pourrions bien entendu lui fournir quatre paramètres, mais cela fait finalement beaucoup pour simplement fournir un nombre et, foncièrement, trois *bits*.

À la place, il nous est possible d'employer un entier dont trois *bits* seront utilisés pour représenter chaque condition. Par exemple, le premier indiquera si le nombre est pair, le second s'il s'agit d'une puissance de deux et le troisième s'il est premier.

```c
void traitement(int nombre, unsigned char drapeaux)
{
	if (drapeaux & 0x01) /* Si le nombre est pair */
	{
		/* ... */
	}
	if (drapeaux & 0x02) /* Si le nombre est une puissance de deux */
	{
		/*... */
	}
	if (drapeaux & 0x04) /* Si le nombre est premier */
	{
		/*... */
	}
}


int main(void)
{
	int nombre;
	unsigned char drapeaux;

	nombre = 2;
	drapeaux = 0x01 | 0x02; /* 0000 0011 */
	traitement(nombre, drapeaux);
	nombre = 17;
	drapeaux = 0x04; /* 0000 0100 */
	traitement(nombre, drapeaux);
	return 0;
}
```

Comme vous le voyez, nous utilisons l'opérateur `|` pour combiner plusieurs drapeaux et l'opérateur `&` pour déterminer si un drapeau est levé ou non.

[[information]]
| Notez que, chaque drapeau représentant un *bit*, ceux-ci correspondent toujours à des puissances de deux.

Voilà qui est plus efficace, mais en somme assez peu lisible... En effet, il serait bon de préciser dans notre code à quoi correspond chaque drapeaux. Pour ce faire, nous pouvons recourir au préprocesseur afin de clarifier un peu tout cela.

```c
#define PAIR		(1 << 0)
#define PUISSANCE	(1 << 1)
#define PREMIER		(1 << 2)


void traitement(int nombre, unsigned char drapeaux)
{
	if (drapeaux & PAIR) /* Si le nombre est pair */
	{
		/* ... */
	}
	if (drapeaux & PUISSANCE) /* Si le nombre est une puissance de deux */
	{
		/*... */
	}
	if (drapeaux & PREMIER) /* Si le nombre est premier */
	{
		/*... */
	}
}


int main(void)
{
	int nombre;
	unsigned char drapeaux;

	nombre = 2;
	drapeaux = PAIR | PUISSANCE; /* 0000 0011 */
	traitement(nombre, drapeaux);
	nombre = 17;
	drapeaux = PREMIER; /* 0000 0100 */
	traitement(nombre, drapeaux);
	return 0;
}
```

Voici qui est mieux. ^^

Pour terminer, remarquez qu'il s'agit d'un bon cas d'utilisation des champs de *bits*, chacun d'entre eux représentant alors un drapeau.

```c
struct propriete
{
	unsigned pair : 1;
	unsigned puissance : 1;
	unsigned premier : 1;
}


void traitement(int nombre, struct propriete prop)
{
	if (prop.pair) /* Si le nombre est pair */
	{
		/* ... */
	}
	if (prop.puissance) /* Si le nombre est une puissance de deux */
	{
		/*... */
	}
	if (prop.premier) /* Si le nombre est premier */
	{
		/*... */
	}
}


int main(void)
{
	int nombre;
	struct propriete prop = { 0 }; /* Initialisation à zéro. */

	nombre = 2;
	prop.pair = 1;
	prop.puissance = 1;
	traitement(nombre, prop);
	memset(&prop, 0, sizeof prop); /* Mise à zéro. */
	nombre = 17;
	drapeaux = PREMIER; /* 0000 0100 */
	traitement(nombre, drapeaux);
	return 0;
}
```