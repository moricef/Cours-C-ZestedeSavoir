Une fonction à nombre variable d'arguments est, comme son nom l'indique, une fonction capable de recevoir et de manipuler un nombre variable d'arguments, mais en plus, et cela son nom ne le spécifie pas, potentiellement de types différents.

Une telle fonction se définit en employant comme *dernier* paramètre une suite de trois points appelée une ellipse indiquant que des arguments supplémentaires peuvent être transmis.

```c
void affiche_suite(int n, ...);
```

Le prototype ci-dessus déclare une fonction recevant un `int` et, éventuellement, un nombre indéterminé d'autres arguments. La partie précédant l'ellipse décrit donc les paramètres attendus par la fonction et qui, comme pour n'importe quelle autre fonction, *doivent* lui être transmis.

[[erreur]]
| L'ellipse ne peut être placée qu'à la fin de la liste des paramètres.

Une fois définie, la fonction peut être appelée en lui fournissant zéro ou plusieurs arguments supplémentaires.

```c
affiche_suite(10, 20);
affiche_suite(10, 20, 30, 40, 50, 60, 70, 80, 90, 100);
affiche_suite(10);
```

[[attention]]
| Comme pour les pointeurs génériques de fonction, le nombre et le types des arguments est inconnu du compilateur (c'est d'ailleurs bien le but de la manœuvre). Dès lors, les même règles de promotion s'appliquent ainsi que les problèmes qui y sont inhérent, notamment la problématique des pointeurs nuls. N'employer donc pas la macroconstante `NULL` pour fournir un pointeur nul comme argument optionnel.