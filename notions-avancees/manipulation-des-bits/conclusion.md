### En résumé

1. Le C fourni six opérateurs de manipulaton des *bits* ;
2. Ces derniers travaillant directement sur la représentation des entiers, il est *impératif* d'éviter d'obtenir des représentations potentiellement invalide dans le cas des entiers signés ;
3. L'utilisation de masques permet de sélectionner ou modifier une portion d'un nombre entier ;
4. Les champs de *bits* permettent de stocker des entiers de taille arbitraire, mais doivent *toujours* avoir une taille inférieure à celle du type `int`. Par ailleurs, ils n'ont pas d'adresse et ne supportent pas forcément le stockage d'entiers signés ;
5. Les drapeaux constituent une solution élégante pour stocker des états binaires (« vrai » ou « faux »).