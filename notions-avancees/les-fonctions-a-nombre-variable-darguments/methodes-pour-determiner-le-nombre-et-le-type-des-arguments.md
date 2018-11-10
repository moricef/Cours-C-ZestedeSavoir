De manière générale, il existe trois grandes méthodes pour gérer le nombre et le type des arguments optionnels.

# Les chaînes de formats

Cette méthode, vous la connaissez déjà, il s'agit de celle employée par les fonctions `printf()`, `scanf()` et consœurs. Elle consiste à décrire le nombre et le type des arguments à l'aide d'une chaîne de caractères comprenant des indicateurs.

# Les suites d'arguments de même type

La seconde solution ne peut être utilisée que si tous les arguments optionnels sont de même type. Elle consiste soit à indiquer le nombre d'arguments transmis, soit à utiliser un délimitateur. La fonction `affiche_suite()` recourt par exemple à un paramètre pour déterminer le nombre de paramètres optionnels qu'elle a reçu.

Un délimitateur pourrait par exemple être un pointeur nul dans le cas d'une fonction similaire affichant une suite de chaîne de caractères.

```c
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>


static void affiche_suite(char *chaine, ...)
{
    va_list ap;

    va_start(ap, chaine);

    do
    {
        puts(chaine);
        chaine = va_arg(ap, char *);
    } while(chaine != NULL);

    va_end(ap);
}


int main(void)
{
    affiche_suite("un", "deux", "trois", (char *)0);
    return 0;
}
```

```text
un
deux
trois
```

# Emploi d'un pivot

La dernière pratique consiste à recourir à un paramètre « pivot » qui fera varier le parcours des paramètres optionnels en fonction de sa valeur. Notez qu'un type énuméré se prête très bien pour ce genre de paramètre. Par exemple, la fonction suivante affiche un `int` ou un `double` suivant la valeur du paramètre `type`.

```c
#include <stdarg.h>
#include <stdio.h>

enum type { TYPE_INT, TYPE_DOUBLE };


static void affiche(enum type type, ...)
{
    va_list ap;

    va_start(ap, type);

    switch (type)
    {
    case TYPE_INT:
        printf("Un entier : %d.\n", va_arg(ap, int));
        break;

    case TYPE_DOUBLE:
        printf("Un flottant : %f.\n", va_arg(ap, double));
        break;
    }

    va_end(ap);
}


int main(void)
{
    affiche(TYPE_INT, 10);
    affiche(TYPE_DOUBLE, 3.14);
    return 0;
}
```

```text
Un entier : 10.
Un flottant : 3.140000.
```