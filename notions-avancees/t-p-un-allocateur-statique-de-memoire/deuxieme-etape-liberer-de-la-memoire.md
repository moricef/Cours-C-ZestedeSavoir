Pouvoir allouer de la mémoire, c'est bien, mais pouvoir en libérer, ce serait mieux. Parce que pour le moment, dès que l'on arrive à la fin du tableau, que la mémoire précédemment allouée soit encore utilisée ou non, c'est grillé. :-°

Toutefois, pour mettre en place un système de libération de la mémoire, il va nous falloir changer un peu de tactique.

# Ajout d'un en-tête

Tout d'abord, si nous voulons libérer des blocs puis les réutiliser, il nous faut conserver d'une manière ou d'une autre leur taille. En effet, sans cette information, il nous sera impossible de les réaffecter.

Pour ce faire, il nous est possible d'ajouter un en-tête lors de l'allocation d'un bloc, autrement dit un objet (par exemple un entier de type `size_t`) qui précédera le bloc alloué et contiendra la taille du bloc.

```text
+---------+-----------------+
| En-tête |   Bloc alloué   |
+---------+-----------------+
```

Ainsi, lors de l'allocation, il nous suffit de transmettre à l'utilisateur le bloc alloué sans son en-tête à l'aide d'une expression du type `(char *)ptr + sizeof (size_t)` et, à l'inverse, lorsque l'utilisateur souhaite libérer un bloc, de le récupérer à l'aide d'une expression comme `(char *)ptr - sizeof (size_t)`. Notez que cette technique nous coûte un peu plus de mémoire puisqu'il est nécessaire d'allouer le bloc *et* l'en-tête.

# Les listes chaînées

Mais, ce n'est pas tout. Pour pouvoir retrouver un bloc libéré, il nous faut également un moyen pour les conserver et en parcourir la liste. Afin d'atteindre cet objectif, nous allons employer une structure de donnée appelée une **liste chaînée**. Celle-ci consiste simplement en une structure comprenant des données ainsi qu'un pointeur vers une structure du même type.

```c
struct list
{
    struct list *suivante;
};
```

Ainsi, il est possible de créer des *chaines* de structure, chaque maillon de la chaîne référencant le suivant. L'idée pour notre allocateur va être de conserver une liste des blocs libérés, liste qu'il parcourera en vue de rechercher un bloc de taille suffisante *avant* d'allouer de la mémoire provenant de la réserve. De cette manière, il nous sera possible de réutiliser de la mémoire précédemment allouée avant d'aller puiser dans la réserve.

Nous aurons donc a priori besoin d'une liste comprenant une référence vers le bloc libéré et une référence vers le bloc suivant (il ne nous est pas nécessaire d'employer un membre pour la taille du bloc puisque l'en-tête la contient).

```c
struct bloc
{
    void *p;
    struct bloc *suivant;
};
```

## Le serpent qui se mange la queue

Cependant, avec une telle technique, nous risquons d'entrer dans un cercle vicieux. En effet, imaginons qu'un utilisateur libère un bloc de 64 multiplets. Pour l'ajouter à la liste des blocs libérés, nous avons besoin d'espace pour stocker une structure `bloc`, nous allons donc allouer un peu de mémoire. De plus, si par la suite ce bloc est réutilisé, la structure `bloc` ne nous est plus utile, sauf que si nous la libérons, nous allons devoir allouer une autre structure `bloc` pour référencé... une structure `bloc` (à moins que la structure ne s'autoréférence). Voilà qui n'est pas très optimal.

À la place, il nous est possible de recourir à une autre stratégie : inclure la structure `bloc` dans l'en-tête ou, plus précisémment, son champ `suivant`, la référence vers le bloc n'étant plus nécessaire dans ce cas. Autrement dit, notre en-tête sera le suivant.

```c
struct bloc
{
    size_t taille;
    struct bloc *suivant;
};
```

Lors de la libération du bloc, il nous suffit d'employer le champ `suivant` de l'en-tête pour ajouter le bloc à la liste des blocs libres.

```text
       En-tête                                          En-tête
<------------------->                            <------------------->
+---------+---------+-----------------+          +---------+---------+-----------------+
| Taille  | Suivant |   Bloc alloué   |          | Taille  | Suivant |   Bloc alloué   |
+---------+---------+-----------------+          +---------+---------+-----------------+
               +                                 ^
               |                                 |
               +---------------------------------+
```

[[attention]]
| Étant donné que l'en-tête précède le bloc alloué, il est impératif que sa taille soit « arrondie » de sorte que les données qui seront stockées dans le bloc respectent l'alignement le plus strict.

Avec ceci, vous devriez pouvoir réaliser une fonction `static_free()` et modifier la fonction `static_malloc()` en conséquence. ;)