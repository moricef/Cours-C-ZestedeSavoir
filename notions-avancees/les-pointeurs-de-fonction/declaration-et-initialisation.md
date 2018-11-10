Jusqu'à maintenant, nous avons manipulé des pointeurs sur objet, c'est-à-dire des adresses vers des zones mémoires contenant des *données* (des entiers, des flottants, des structures, etc.). Toutefois, il est également possible de référencer des *instructions* et ceci est réalisé en C à l'aide des pointeurs de fonction.

Un pointeur de fonction se définit à l'aide d'une syntaxe mélangeant celle des pointeurs sur tableau et celles des prototypes de fonction. Sans plus attendre, voici ci-dessous la définition d'un pointeur sur une fonction retournant un `int` et attendant un `int` comme argument.

```c
int (*pf)(int);
```

Comme vous le voyez, il est nécessaire, tout comme les pointeurs sur tableau, d'entourer le symbole `*` et l'identificateur de parenthèses, ici afin d'éviter que cette déclaration ne soit vue comme un prototype et non comme un pointeur de fonction. Autre particularité : le type de retour, le nombre d'arguments et leur type doivent également être spécifiés.

# Initialisation

[[question]]
| Ok... Et je lui affecte comment l'adresse d'une fonction, moi, à ce machin ? D'ailleurs, elles ont une adresse, les fonctions ? :euh:

Oui et comme d'habitude, cela est réalisé à l'aide de l'opérateur `&`. ^^  
En fait, dans le cas des fonctions, il n'est pas obligatoire de recourir à cet opérateur, ainsi, les deux syntaxes suivantes sont correctes.

```c
int (*pf)(int);

pf = &fonction;
pf = fonction;
```

Ceci est dû, à l'image des tableaux, à une conversion implicite : sauf s'il est l'opérande de l'opérateur `&`, un identificateur de fonction est converti en un pointeur sur cette fonction. L'utilisation de l'opérateur `&` est donc facultative, mais elle a le mérite de clarifier un peu les choses. Pour cette raison, nous utiliserons cette syntaxe dans la suite de ce cours.