Une définition de type permet, comme son nom l'indique, de définir un type, c'est-à-dire d'en produire un nouveau ou, plus précisément, de créer un *alias* (un synonyme si vous préférez) d'un type existant. Une définition de type est identique à une déclaration de variable, si ce n'est que celle-ci doit être précédée du mot-clé `typedef` (pour *type definition*) et que l'identificateur ainsi choisi désignera un type et non une variable.

Ainsi, le code ci-dessous défini un nouveau type `entier` qui sera un *alias* pour le type `int`.

```c
typedef int entier;
```

Le synonyme ainsi créé peut être utilisé au même endroit que n'importe quel autre type.

```c
#include <stdio.h>

typedef int entier;


entier main(void)
{
    entier a = 10;

    printf("%d.\n", a);
    return 0;
}
```

[[question]]
| D'accord, mais cela me sert à quoi de créer un synonyme pour un type existant ? :euh:

Les définitions de type permettent en premier lieu de raccourcir certaines écritures, notamment afin de s'affranchir des mots-clés `struct`, `union` et `enum` (bien que, ceci constitue une pertes d'information aux yeux de certains).

```c
#include <stdio.h>

struct position
{
    int lgn;
    int col;
};

typedef struct position position;


int main(void)
{
    position pos;

    pos.lgn = 1;
    pos.col = 1;
    printf("%d, %d.\n", pos.lgn, pos.col);
    return 0;
}
```

Notez qu'une définition de type étant une délaration, il est parfaitement possible de combiner la définition de la structure et la définition de type (comme pour une variable, finalement).

```c
typedef struct position
{
    int lgn;
    int col;
} position;
```

Également, dans le même sens que ce qui a été dit au sujet des énumérations, une définition de type peut être employée pour donner plus d'informations via le typage. C'est une manière de désigner plus finement le contenu d'un type en ne se contentant pas d'une information plus générale comme « un entier » ou « un flottant ».

Par exemple, nous aurions pu définir un type `ligne` et un type `colonne` afin de donner plus d'information sur le contenu de nos variables.

```c
typedef short ligne;
typedef short colonne;

struct position
{
    ligne lgn;
    colonne col;
};
```

De même, les définitions de type sont couramment utilisée afin de créer des asbstractions. Nous en avons vu un exemple avec l'en-tête `<time.h>` qui défini le type `time_t`. Celui-ci permet de ne pas devoir modifier la fonction `time()` et son utilisation suivant le type qui est sous-jacent. Peu importe que `time_t` soit un entier ou un flottant, la fonction `time()` s'utilise de la même manière.

Enfin, les définitions de type permettent de résoudre quelques points de syntaxe tordus.