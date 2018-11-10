Étant donné leur singularité, les unions sont rarement employées. Leur principal intérêt est de réduire l'espace mémoire utilisé là où une structure ne le permet pas.

Par exemple, imaginez que vous souhaitiez construire une structure pouvant accueillir plusieurs types possibles, par exemple des entiers et des flottants. Vous aurez besoin de trois champs : un indiquant quel type est stocké dans la structure et deux permettant de stocker soit un entier soit un flottant.

```c
struct nombre
{
    unsigned entier : 1;
    unsigned flottant : 1;
    int e;
    double f;
};
```

Toutefois, vous gaspiller ici de la mémoire puisque seul un des deux objets sera stockés. Une union est ici la bienvenue afin d'économiser de la mémoire.

```c
struct nombre
{
    unsigned entier : 1;
    unsigned flottant : 1;
    union
    {
        int e;
        double f;
    } u;
};
```

Le code suivant illustre l'utilisation de cette construction.

```c
#include <stdio.h>

struct nombre
{
    unsigned entier : 1;
    unsigned flottant : 1;
    union
    {
        int e;
        double f;
    } u;
};


static void affiche_nombre(struct nombre n)
{
    if (n.entier)
        printf("%d\n", n.u.e);
    else if (n.flottant)
        printf("%f\n", n.u.f);
}


int main(void)
{
    struct nombre a = { 0 };
    struct nombre b = { 0 };

    a.entier = 1;
    a.u.e = 10;
    b.flottant = 1;
    b.u.f = 10.56;

    affiche_nombre(a);
    affiche_nombre(b);
    return 0;
}
```

```text
10
10.560000
```

Une autre utilisation fréquente des unions est de permettre de modifier l'alignement d'un objet ou, plus précisément, d'augmenter l'alignement d'un objet. En fait, il s'agit d'une des conséquences de l'union : étant donné qu'elle doit pouvoir stocker n'importe lequel de ses membres, son alignement doit être le plus élevé parmi celui de ses membres.

[[information]]
| Pour rappel, l'alignement d'un type peut être connu à l'aide de la macrofonction `offsetof()` et d'un type structure de la forme `struct { char c; type x; }`.

Ainsi, si nous souhaitons aligner un objet de type `int` de la même manière qu'un objet de type `double`, il nous suffit de construire une union qui comprendra les deux types. Le code suivant vérifie ce qui vient d'être dit.

```c
#include <stddef.h>
#include <stdio.h>

union nombre
{
    int e;
    double f;
};


int main(void)
{
    printf("int : %u\n", (unsigned)offsetof(struct { char c; int n; }, n));
    printf("union nombre : %u\n", (unsigned)offsetof(struct { char c; union nombre n; }, n));
    return 0;
}
```

```text
int : 4
union nombre : 8
```

Dans la même veine, il est ainsi possible de connaître l'alignement le plus strict parmi les types natifs en construisant une union comportant les types les plus contraignants, à savoir : le type `long`, le type `long double` et le type `void *`.

```c
#include <stddef.h>
#include <stdio.h>

union align
{
    long e;
    long double f;
    void *p;
};


int main(void)
{
    printf("union align : %u\n", (unsigned)offsetof(struct { char c; union align n; }, n));
    return 0;
}
```

```text
union align : 16
```

Comme pour l'exemple précédent, cette technique peut être utilisée pour imposer l'alignement le plus strict à un objet ayant une contraine d'alignement plus faible. Gardez bien ceci en mémoire, nous y reviendrons lors du T.P. final. ;)