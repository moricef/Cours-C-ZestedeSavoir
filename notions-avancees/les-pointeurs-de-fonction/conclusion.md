### En résumé

1. Un pointeur de fonction permet de stocker une référence vers une fonction ;
1. Il n'est pas nécessaire d'employer l'opérateur `&` pour obtenir l'adresse d'une fonction ;
1. Le déréférencement n'est pas obligatoire lors de l'utilisation d'un pointeur de fonction ;
1. Une fonction employant un pointeur vers une autre fonction reçu en argument est appelée une fonction de rappel (*callback function* en anglais) ;
1. Le recours à une structure permet d'éviter les problèmes de définitions récursives ;
1. Il est possible d'utiliser un pointeur « générique » de fonction en ne fournissant aucune information quant aux arguments lors de sa définition ;
1. Un pointeur « générique » de fonction peut être converti vers ou depuis n'importe quel autre type de pointeur de fonction du moment que le type de retour reste identique ;
1. Lors de l'utilisation d'un pointeur « générique » de fonction, les arguments transmis sont promus, mais aucune conversion implicite n'est réalisée par le compilateur ;
1. Lors de l'utilisation d'un pointeur « générique » de fonction, un pointeur nul ne peut être fourni qu'à l'aide d'une conversion explicite.