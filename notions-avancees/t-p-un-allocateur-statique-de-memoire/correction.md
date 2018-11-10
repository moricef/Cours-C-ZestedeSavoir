[[secret]]
|```c
| #include <assert.h>
| #include <stddef.h>
| #include <stdio.h>
| 
| #define MEM_SIZE (1024UL * 1024UL)
| #define ALIGNEMENT(type) (offsetof(struct { char c; type t; }, t))
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
| static union reserve reserve;
| 
| static size_t calcule_multiple_align(size_t);
| static void *static_malloc(size_t);
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
| 
|     if (MEM_SIZE - alloue < taille)
|     {
|         fprintf(stderr, "Il n'y a plus assez de mémoire disponible.\n");
|         return NULL;
|     }
| 
|     ret = &reserve.mem[alloue];
|     alloue += taille;
|     return ret;
| }
|```

La fonction `calcule_multiple_align()` détermine le plus petit multiple de l'alignement maximal égal ou supérieur à `a`. Celle-ci nous permet d'« arrondir » la taille demandée de sorte que les blocs alloués soit toujours correctement alignés.

La macrofonction `ALIGNEMENT()` calcule l'alignement d'un type donné en recourant à la macrofonction `offsetof()` comme expliqué précédemment.

La fonction `static_malloc()` utilise une variable statique : `alloue` qui représente la quantité de mémoire déjà allouée. Dans le cas où la taille demandée (arrondie au multiple de l'alignement qui lui est égal ou supérieur) n'est pas disponible, un pointeur nul est retourné. Sinon, la variable `alloue` est mise à jour et un pointeur vers la position courante du tableau `reserve.mem` est retourné.

Notez que nous avons utilisé une assertion afin d'éviter qu'une taille nulle ne soit fournie.