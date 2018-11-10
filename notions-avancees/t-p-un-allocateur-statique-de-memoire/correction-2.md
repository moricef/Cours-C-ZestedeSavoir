[[secret]]
|```c
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
| struct suite
| {
|     struct bloc *precedent;
|     struct bloc *premier;
|     struct bloc *dernier;
|     size_t taille;
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
|     struct suite suite = { 0 };
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
|         else if (suite.dernier != NULL && (char *)suite.dernier + TAILLE_EN_TETE \
|         + suite.dernier->taille == (char *)bloc)
|         {
|             suite.dernier = bloc;
|             suite.taille += TAILLE_EN_TETE + bloc->taille;
|         }
|         else
|         {
|             suite.precedent = precedent;
|             suite.premier = bloc;
|             suite.dernier = bloc;
|             suite.taille = bloc->taille;
|         }
| 
|         if (suite.taille >= taille)
|         {
|             if (suite.precedent != NULL)
|                 suite.precedent->suivant = suite.dernier->suivant;
|             else
|                 libre = suite.dernier->suivant;
| 
|             suite.premier->taille = suite.taille;
|             ret = suite.premier;
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
|     struct bloc *precedent = NULL;
|     struct bloc *nouveau;
| 
|     if (ptr == NULL)
|          return;
|
|     nouveau = (struct bloc *)((char *)ptr - TAILLE_EN_TETE);
| 
|     while (bloc != NULL)
|     {
|         if (bloc < nouveau)
|         {
|             if (precedent != NULL)
|                 precedent->suivant = nouveau;
|             else
|                 libre = nouveau;
|                 
| 
|             nouveau->suivant = bloc;
|             break;
|         }
| 
|         precedent = bloc;
|         bloc = bloc->suivant;
|     }
| 
|     if (bloc == NULL)
|         libre = nouveau;
| }
|```

La fonction `static_free()` a été aménagée afin que les adresses des différents blocs soient triées par ordre croissant. Si le nouveau bloc libéré a une adresse inférieur à un autre bloc, il est placé avant lui, sinon il est placé à la fin de la liste.

Quant à la fonction `recherche_bloc_libre()`, elle emploie désormais une structure `suite` qui comprend un pointeur vers le bloc précédent le début de la suite (champ `precedent`), un pointeur vers le premier bloc de la suite (champ `premier`), un pointeur vers le dernier bloc de la suite (champ `dernier`) et la taille totale de la suite (champ `taille`).

Dans le cas où cette structure n'a pas encore été modifiée ou que le dernier bloc de la suite n'est pas adjacent à celui qui le suit, le premier et le dernier blocs de la suite deviennent le bloc courant, la taille est réinitialisée à la taille du bloc courant et le bloc précédent la suite est... celui qui précède le bloc courant (ou un pointeur nul s'il n'y en a pas).

Si la suite atteint une taille suffisante, alors les blocs la composant sont fusionnés et le nouveau bloc ainsi construit est retourné.