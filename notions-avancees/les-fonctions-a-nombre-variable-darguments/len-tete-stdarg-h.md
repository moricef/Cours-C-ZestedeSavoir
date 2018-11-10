Une fois le prototype de la fonction déterminé, encore faut-il pouvoir manipuler ces arguments supplémentaires au sein de sa définition.Pour ce faire, la bibliothèque standard nous fourni trois macrofonctions : `va_start()`, `va_arg()` et `va_end()` définie dans l'ent-tête `<stdarg.h>`. Ces trois macrofonctions attendent comme premier argument une variable de type `va_list` définit dans le même en-tête.

Afin d'illustrer leur fonctionnement, nous vous proposons directement un exemple mettant en œuvre une fonction `affiche_suite()` qui reçoit comme premier paramètre le nombre d'entiers qui vont lui être transmis et les affiche ensuite tous, un par ligne.

```c
#include <stdarg.h>
#include <stdio.h>


void affiche_suite(int nb, ...)
{
    va_list ap;

    va_start(ap, nb);

    while (nb > 0)
    {
        int n;

        n = va_arg(ap, int);
        printf("%d.\n", n);
        --nb;
    }

    va_end(ap);
}


int main(void)
{
    affiche_suite(10, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100);
    return 0;
}
```

```text
10.
20.
30.
40.
50.
60.
70.
80.
90.
100.
```

La macrofonction `va_start` initialise le parcours des paramètres optionnels. Elle attend deux arguments : une variable de type `va_list` et le nom du dernier paramètre obligatoire de la fonction courante (dans notre cas `nb`). Il est impératif de l'appeler avant toute opération sur les paramètres optionnels.

La marcofonction `va_arg()` retourne le paramètre optionnel suivant en considérant celui-ci comme de type `type`. Elle attend deux arguments : une variable de type `va_list` précédemment initialisée par la macrofonction `va_start()` et le type du paramètre optionnel suivant.

Enfin, la fonction `va_end()` met fin au parcours des arguments optionnels. Elle doit *toujours* être appelée après un appel à la macrofonction `va_start()`.

[[erreur]]
| La macrofonction `va_arg()` n'effectue *aucune* vérification ! Cela signifie que si vous renseigner un type qui ne correspond pas au paramètre optionnel suivant ou si vous tentez de récupérer un paramètre optionnel qui n'existe pas, vous allez au devant de comportements indéfinis.

Étant donné cet état de fait, il est impératif de pouvoir déterminer le nombre d'arguments optionnels envoyé à la fonction. Dans notre cas, nous avons opté pour l'emploi d'un paramètre obligatoire indiquant le nombre d'arguments optionnels envoyés.

[[question]]
| Mais ?! Et si l'utilisateur de la fonction se plante en ne précisant pas le bon nombre ou le bon type d'arguments ?

*Eh* bien... C'est foutu. :-°  
Il s'agit là d'une lacune similaire à celle des pointeurs « génériques » de fonction : étant donné que le type et le nombre des arguments optionnels est inconnu, le compilateur ne peut effectuer aucune vérification ou conversion.