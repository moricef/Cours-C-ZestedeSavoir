Une union est, à l'image d'une structure, un regroupement d'objet de type *différents*. La nuance, et elle est de taille, est qu'une union est un agrégat qui ne peut contenir qu'*un seul* de ses membres à la fois. Autrement dit, une union peut accueillir la valeur de n'importe lequel de ses membres, mais un seul à la fois.

Concernant la définition, elle est identique à celle d'une structure ci ce n'est que le mot-clé `union` est employé en lieu et place de `struct`.

```c
union type
{
    int entier;
    double flottant;
    void *pointeur;
    char lettre;
};
```

Le code ci-dessus défini une union `type` pouvant contenir un objet de type `int` ou de type `double` ou de type pointeur sur `void` ou de type `char`. Cette possiblité de ne stocker qu'un objet à la fois est traduite par le résultat de l'opérateur `sizeof`.

```c
#include <stdio.h>

union type
{
    int entier;
    double flottant;
    void *pointeur;
    char lettre;
};


int main(void)
{
    printf("%u.\n", sizeof (union type));
    return 0; 
}
```

```text
8.
```

Dans notre cas, la taille de l'union correspond à la taille du plus grand type stocké à savoir les types `void *` et `double` qui font huit octets. Ceci traduit bien l'impossiblité de stocker plusieurs objets à la fois.

[[information]]
| Notez que, comme les structures, les unions peuvent contenir des *bits* de bourrage, mais uniquement à leur fin.

Pour le surplus, une union s'utilise de la même manière qu'une structure et l'accès aux membres s'effectue à l'aide des opérateurs `.` et `->`.