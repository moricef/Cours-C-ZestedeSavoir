[[secret]]
| ```c
| #include <assert.h>
| #include <stddef.h>
| #include <stdio.h>
| #include <stdlib.h>
| 
| #define MEM_SIZE (1024UL * 1024UL)
| #define ALIGNEMENT(type) (offsetof(struct { char c; type t; }, t))
| #define TAILLE_EN_TETE (offsetof(struct { struct bloc b; union align u; }, u))
| 
| union align
| {
|     long e;
|     long double f;
|     void *p;
| };
| 
| union reserve
| {
|     union align align;
|     char mem[MEM_SIZE];
| };
| 
| struct bloc
| {
|     size_t taille;
|     struct bloc *suivant;
| };
| 
| 
| static union reserve reserve;
| static struct bloc *libre;
| 
| static void bloc_init(struct bloc *, size_t);
| static size_t calcule_multiple_align(size_t);
| static struct bloc *recherche_bloc_libre(size_t);
| static void static_free(void *);
| static void *static_malloc(size_t);
| 
| 
| static void bloc_init(struct bloc *b, size_t taille)
| {
|     /*
|      * Initialise les membres d'une structure `bloc`.
|      */
| 
|     b->taille = taille;
|     b->suivant = NULL;
| }
| 
| 
| static size_t calcule_multiple_align(size_t a)
| {
|     /*
|      * Calcule le plus petit multiple de l'alignement maximal égal ou supérieur à `a`.
|      */
| 
|     static size_t align_max = ALIGNEMENT(union align);
|     size_t multiple = a / align_max;
| 
|     return ((a % align_max == 0) ? multiple : multiple + 1) * align_max;
| }
| 
| 
| static struct bloc *recherche_bloc_libre(size_t taille)
| {
|     /*
|      * Recherche un bloc libre ou une suite de bloc libres dont la taille
|      * est au moins égale à `taille`.
|      */
| 
|     struct bloc *bloc = libre;
|     struct bloc *precedent = NULL;
|     struct bloc *ret = NULL;
| 
|     while (bloc != NULL)
|     {
|         if (bloc->taille >= taille)
|         {
|             if (precedent != NULL)
|                 precedent->suivant = bloc->suivant;
|             else
|                 libre = bloc->suivant;
| 
|             ret = bloc;
|             break;
|         }
| 
|         precedent = bloc;
|         bloc = bloc->suivant;
|     }
| 
|     return ret;
| }
| 
| 
| static void *static_malloc(size_t taille)
| {
|     /*
|      * Alloue un bloc de mémoire au moins de taille `taille`.
|      */
| 
|     static size_t alloue = 0UL;
|     void *ret;
| 
|     assert(taille > 0);
|     taille = calcule_multiple_align(taille);
|     ret = recherche_bloc_libre(taille);
| 
|     if (ret == NULL)
|     {
|         if (MEM_SIZE - alloue < TAILLE_EN_TETE + taille)
|         {
|             fprintf(stderr, "Il n'y a plus assez de mémoire disponible.\n");
|             return NULL;
|         }
| 
|         ret = &reserve.mem[alloue];
|         alloue += TAILLE_EN_TETE + taille;
|         bloc_init(ret, taille);
|     }
| 
|     return (char *)ret + TAILLE_EN_TETE;
| }
| 
| 
| static void static_free(void *ptr)
| {
|     /*
|      * Ajoute le bloc fourni à la liste des blocs libres.
|      */
| 
|     struct bloc *bloc = libre;
|     struct bloc *nouveau;
|
|     if (ptr == NULL)
|          return;
| 
|     nouveau = (struct bloc *)((char *)ptr - TAILLE_EN_TETE);
| 
|     while (bloc != NULL && bloc->suivant != NULL)
|         bloc = bloc->suivant;
| 
|     if (bloc == NULL)
|         libre = nouveau;
|     else
|         bloc->suivant = nouveau;
| }
| ```

Désormais, la fonction `static_malloc()` fait d'abord appel à la fonction `recherche_bloc_libre()` *avant* d'allouer de la mémoire de la réserve. Comme son nom l'indique, cette fonction parcours la liste des blocs libres à la recherche d'un bloc d'une taille égale ou supérieure à celle demandée. Cette liste est matérialisée par la variable globale `libre` qui est un pointeur sur une structure de type `bloc`. Cette variable correspond au premier maillon de la liste et est employée pour initialiser le parcours.

Si aucun bloc libre n'est trouvé, alors la fonction `static_malloc()` pioche dans la réserve un bloc de la taille demandée augmentée de la taille de l'en-tête. Ces deux tailles sont « arrondies » au multiple égal ou directement supérieur de l'alignement le plus contraignant. Étant donné que la taille de l'en-tête est fixe, nous avons représenté sa taille « arrondie » à l'aide de la macroconstante `TAILLE_EN_TETE` et de la macrofonction `offsetof()`. Une fois le tout alloué, l'en-tête est « retiré » en ajoutant la taille de l'en-tête au pointeur référencant la mémoire allouée et le bloc demandé est retourné.

La fonction `static_free()` se rend à la fin de la liste et y ajoute le bloc qui lui est fourni en argument. Pour ce faire, elle « récupère » l'en-tête en soustrayant la taille de l'en-tête au pointeur fourni en argument. Notez également que cette fonction n'effectue aucune opération dans le cas où un pointeur nul lui est fourni (tout comme la fonction `free()` standard), ce qui peut être intéressant pour simplifier la gestion d'erreur dans certains cas.