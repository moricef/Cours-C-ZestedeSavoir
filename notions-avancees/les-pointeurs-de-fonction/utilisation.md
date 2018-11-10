# Déréférencement

Un pointeur de fonction s'emploie de la même manière qu'un pointeur classique, si ce n'est que l'opérateur `*` et l'identificateur doivent à nouveau être entre parenthèses. Pour le reste, la liste des arguments suit l'expression déréférencée, comme pour un appel de fonction classique.

```c
#include <stdio.h>


static int triple(int a)
{
    return a * 3;
}


int main(void)
{
    int (*pt)(int) = &triple;

    printf("%d.\n", (*pt)(3));
    return 0;
}
```

```text
9.
```

Toutefois, particularité des fonctions oblige, sachez que le déréférencement n'*est pas nécessaire*. Ceci à cause de la conversion implicite expliquée précédemment : un identificateur de fonction est, sauf s'il est l'opérande de l'opérateur `&`, converti en un pointeur sur cette fonction. L'appel `triple(3)` cache donc en fait un pointeur de fonction qui, comme vous le voyez, n'est *pas* déréférencé.

[[question]]
| *Heu*... Mais pourquoi l'expression `(*pt)(3)` ne provoque-t-elle pas une erreur si c'est un pointeur de fonction qui est nécessaire lors d'un appel ?

Parce que la conversion implicite aura lieu juste après le déréférencement. :-°  
*Eh* oui, déréférencé un pointeur de fonction, c'est un peu reculer pour mieux sauter : nous obtenons une expression équivalente à un identificateur de fonction qui sera ensuite convertie en un pointeur de fonction. Les deux expressions suivantes sont donc équivalentes.

```c
triple(3);
(*pt)(3);
```

L'intérêt d'employer le déréférencement est purement syntaxique : cela permet de distinguer des appels effectuer via des pointeurs des appels de fonction classiques.

# Passage en argument

Comme n'importe quel pointeur, un pointeur de fonction peut être passé en argument d'une autre fonction (c'est d'ailleurs tout l'intérêt de ceux-ci, comme nous le verrons bientôt). Pour ce faire, il vous suffit d'employer la même syntaxe que pour une déclaration.

```c
#include <stdio.h>


static int triple(int a)
{
    return a * 3;
}


static int quadruple(int a)
{
    return a * 4;
}


static void affiche(int a, int (*pf)(int))
{
    printf("%d.\n", (*pf)(a));
}


int main(void)
{
    affiche(3, &triple);
    affiche(3, &quadruple);
    return 0;
}
```

```text
9.
12.
```

[[information]]
| La fonction `affiche()` ci-dessus est ce que l'on appelle une *fonction de rappel* (*callback function* en anglais), c'est-à-dire une fonction faisant appel à une autre à l'aide de l'adresse qui lui est fournie en argument.

# Retour de fonction

Dans l'autre sens, il est possible de retourner un pointeur de fonction à l'aide d'une syntaxe... un peu lourde. :-°

```c
#include <stddef.h>
#include <stdio.h>


static void affiche_pair(int a)
{
    printf("%d est pair.\n", a);
}


static void affiche_impair(int a)
{
    printf("%d est impair.\n", a);
}


static void (*affiche(int a))(int)
{
    if (a % 2 == 0)
        return &affiche_pair;
    else
        return &affiche_impair;
}
    


int main(void)
{
    void (*pf)(int);
    int a = 2;

    pf = affiche(a);
    (*pf)(a);
    return 0;
}
```

```text
2 est pair.
```

Comme pour une variable de type pointeur de fonction, le symbole `*` doit être entouré de parenthèses ainsi que l'identificateur qui le suit. Toutefois, lorsqu'il s'agit du type de retour d'une fonction, la liste des arguments doit également être placée entre ces parenthèses.

Dans cet exemple, la fonction `affiche()` attend un `int` et retourne un pointeur sur une fonction ne retournant rien et utilisant un argument de type `int`. Suivant si `a` est pair ou impair, la fonction `affiche()` retourne l'adresse de la fonction `affichage_pair()` ou `affichage_impair()` qui est recueillie par le pointeur `pf` de la fonction `main()`.