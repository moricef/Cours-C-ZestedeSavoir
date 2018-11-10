Vous le savez, le type `void` est employé en C pour produire un pointeur générique qui peut se voir assigner n'importe quel type de pointeur et être converti vers n'importe quel type de pointeurs. Cette définition est toutefois incomplète car il doit en fait être précisé que cela ne fonctionne que pour des pointeurs sur des *objets*. Le code ci-dessous est donc incorrect.

```c
int (*pf)(int);
void *p;

pf = p; /* Faux. */
p = pf; /* Faux également. */
```

Pareillement, une conversion explicite d'un pointeur sur un objet vers ou depuis un pointeur sur fonction est interdite (ou, plus précisément, son résultat est indéterminé). Ceci exclut donc l'utilisation de l'indicateur `p` de la fonction `printf()` pour afficher un pointeur de fonction.

```c
printf("%p.\n", (void *)pf); /* Faux. */
```

Toutefois, les pointeurs de fonction disposent de leur propre pointeur « générique ». Nous utilisons ici les guillemets car il ne l'est pas tout à fait puisqu'il peut notamment être utilisé à l'inverse d'un pointeur sur `void`. Un pointeur « générique » de fonction se déclare comme un pointeur de fonction, mais en ne spécifiant que le type de retour.

```c
int (*pf)();
```

Un tel pointeur peut se voir assigner n'importe quel pointeur sur fonction du moment que le type de retour de celui-ci est identique au sien. Inversement, ce pointeur « générique » peut être affecté à un autre pointeur sous la même condition. Dans notre cas, le type de retour doit donc être `int`.

```c
int (*f)(int, int);
int (*g)(char, char, double);
void (*h)(void);
int (*pf)();

pf = f; /* Ok. */
pf = g; /* Ok. */
pf = h; /* Faux car le type de retour de `h` est `void`. */
f = pf; /* Ok. */
```

[[attention]]
| Il existe cependant une exception supplémentaire : une fonction à nombre variables d'arguments ne peut pas être affectée à un tel pointeur, même si le type de retour est identique. Nous verrons bientôt de quoi il s'agit, mais pour l'heure, sachez que les fonctions de la famille de `printf()` et de `scanf()` sont concernées par cette règle.

# La promotion des arguments

[[question]]
| *Hé* là, minute papillon ! Il se passe quoi si j'utilise le pointeur `pf` avec une fonction qui attend normalement des arguments ?

Excellente question ! :)

Vous vous en doutez : les arguments peuvent toujours être envoyé à la fonction référencée. Cependant, il y a une subtilité. Étant donné qu'un pointeur « générique » de fonction ne fournit aucune information quant aux arguments, le compilateur ne peut pas convertir ceux-ci vers le type attendu par la fonction. Ainsi, si vous fournissez un `int` et que la fonction attend un `char`, le `int` ne sera pas converti vers le type `char` par le compilateur.

Toutefois, dans un tel cas, plusieurs conversions implicites sont appliquées afin de limiter les types possibles (on parle de « promotion des arguments ») :

1. Un argument de type entier de rang inférieur ou égal à celui du type `int` (soit `char` et `short` le plus souvent) est converti vers le type `int` (ou `unsigned int` si le type `int` ne peut pas représenter toutes les valeurs du type d'origine).
2. Un argument de type `float` et converti vers le type `double`.

[[erreur]]
| Ceci signifie qu'une fonction appelée à l'aide d'un pointeur « générique » de fonction ne pourra *jamais* recevoir des arguments de type `char`, `short` ou `float`.

Illustration.

```c
#include <stdio.h>


static float triple(float f)
{
    return 3.F * f;
}


static short quadruple(short n)
{
    return 4 * n;
}


int main(void)
{
    float (*pt)() = &triple;
    short (*pq)() = &quadruple;

    printf("triple = %f.\n", (*pt)(3.F)); /* Faux. */
    printf("quadruple = %d.\n", (*pq)(2)); /* Faux. */
    return 0;
}
```

# Les pointeurs nuls

L'absence de conversions par le compilateur dans le cas où aucune information n'est fournie par rapport aux arguments pose un problème particulier dans le cas des pointeurs nuls et tout spécialement lors de l'usage de la macroconstante `NULL`.

Rappelez-vous : un pointeur nul est construit en convertissant, soit explicitement, soit implicitement, zéro (entier) vers un type pointeur. Or, étant donné que le compilateur n'effectuera aucune conversion implicite dans notre cas, nous ne pouvons compter que sur les conversions explicites.

Et c'est ici que le bât blesse : la macroconstante `NULL` a deux valeurs possibles : `(void *)0` ou `0`, le choix étant laissé aux différents systèmes. La première ne pose pas de problème, mais la seconde en pose un plutôt gênant : c'est un `int` qui sera passé comme argument et non un pointeur nul.

Dès lors, lorsque vous employez un pointeur « générique » de fonction, vous *devez* recourir à une conversion explicite si vous souhaitez produire un pointeur nul.

```c
static void affiche(char *chaine)
{
    if (chaine != NULL)
        puts(chaine);
}

/* ... */

void (*pf)() = &affiche;

(*pf)(NULL); /* Faux. */
(*pf)(0); /* Faux. */
(*pf)((char*)0); /* Ok. */
```