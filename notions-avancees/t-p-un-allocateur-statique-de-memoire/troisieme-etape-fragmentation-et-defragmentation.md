Bien, notre allocateur recycle à présent les blocs qu'il a précédemment alloués, c'est une bonne chose. Toutefois, un problème subsiste : la fragmentation de la mémoire allouée, autrement dit sa division en une multitude de petits blocs.

S'il s'agit d'un effet partiellement voulu (nous allouons par petits blocs pour préserver la réserve), il peut avoir des conséquences fâcheuses non désirées. En effet, imaginez que nous ayons alloué toute la mémoire sous forme de blocs de 16, 32 et 64 multiplets, si même tous ces blocs sont libres, notre allocateur retournera un pointeur nul dans le cas d'une demande de par exemple 80 multiplets... Voilà qui est plutôt gênant.

Une solution consiste à défragmenter la liste des blocs libres, c'est-à-dire fusionner plusieurs blocs pour en reconstruire d'autre avec une taille plus importante. Dans notre cas, nous allons mettre en œuvre ce système lors de la recherche d'un bloc libre : désormais, nous allons regarder si un bloc est d'une taille suffisante *ou* si *plusieurs* blocs, une fois fusionnés, seront de taille suffisante.

# Fusion de blocs

Toutefois, une fusion de blocs n'est possible que si ceux-ci sont adjacents, c'est-à-dire s'ils se suivent en mémoire. Plus précisémment, l'adresse suivant le premier bloc à fusionner doit être celle de début du second (autrement dit `(char *)ptr_bloc1 + taille_bloc1 == (char *)ptr_bloc2`).

Néanmoins, il ne nous est pas possible de vérifier cela facilement si notre liste de blocs libres n'est pas un minimum triée. En effet, sans tri, il nous serait nécessaire de parcourir toute la liste à la recherche d'éventuels blocs adjacents au premier, puis, de faire de même pour le deuxième et ainsi de suite, ce qui n'est pas particulièrement efficace.

À la place, il nous est possible de trier notre liste par adresses croissantes (ou décroissantes, le résultat sera le même) de sorte que si un bloc n'est pas adjacent au suivant, la recherche peut être immédiatement arrêtée pour ce bloc ainsi que tous ceux qui lui étaient adjacents. Ce tri peut être réalisé simplement lors de l'insertion d'un nouveau bloc libre en placant celui-ci correctement dans la liste à l'aide de comparaisons : s'il a une adresse inférieure à celle d'un élément de la liste, il est placé avant cet élément, sinon, le parcours continue.

En effet, deux pointeurs peuvent tout à fait être comparés du moment que ceux-ci référencent un même objet ou un même aggrégat (c'est notre cas ici puisqu'ils référenceront tous des éléments du tableau `mem` de l'union `reserve`) et qu'ils sont du même type (une conversion explicite vers le type pointeur sur `char` sera donc nécessaire comme explicité auparavant).

[[information]]
| N'oubliez pas que si deux ou plusieurs blocs sont fusionnés, il n'y a plus besoin que d'un seul en-tête, les autres peuvent donc être comptés comme de la mémoire utilisable.