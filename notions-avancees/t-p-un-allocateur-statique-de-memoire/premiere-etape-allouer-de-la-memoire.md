Pour commencer, vous allez devoir construire une fonction `static_malloc()` dont le prototype sera le suivant.

```c
void *static_malloc(size_t taille);
```

À la lumière de la fonction `malloc()`, celle-ci reçoit une taille en multiplet et retourne un pointeur vers un bloc de mémoire d'au moins la taille demandée ou un pointeur nul s'il n'y a plus de mémoire disponible.

# Mémoire statique

Afin de réaliser ses allocations, la fonction `static_malloc()` ira piocher dans un bloc de mémoire statique. Celui-ci consistera simplement en un tableau de `char` de classe de stockage statique d'une taille prédéterminée. Pour cet exercice, nous partirons avec un bloc de un mébimultiplets, soit 1.048.576 multiplets (1024 × 1024).

```c
static char mem[1048576UL];
```

## Alignement

Toutefois, retourner un bloc de `char` de la taille demandée ne suffit pas. En effet, si nous allouons par exemple treize multiplets, disons pour une chaîne de caractères, puis quatre multiplets pour un `int`, nous allons retourner une adresse qui ne respecte potentiellement pas l'alignement requis par le type `int`. Étant donné que la fonction `static_malloc()` ne connaît pas les contraintes d'alignements que doit respecter l'objet qui sera stocké dans le bloc qu'elle fourni, elle doit retourner un bloc respectant les contraintes les plus strictes. Dit autrement, la taille de chaque bloc devra être un multiple de l'alignement le plus rigoureux.

Cet alignement peut être connu à l'aide d'une union comprenant les types les plus contraignants et de la macrofonction `offsetof()`, comme précisé dans le chapitre sur les unions.

```c
union align
{
    long e;
    long double f;
    void *p;
};
```

Mais... ce n'est pas tout ! Le tableau alloué statiquement doit lui aussi être aligné suivant l'alignement le plus sévère. En effet, si celui-ci commence à une adresse non multiple de cet alignement, notre stratégie précédente tombe à l'eau. Pour ce faire, il nous suffit d'inclure le tableau dans une union avec comme autre membre l'union décrite ci-dessus.

```c
union reserve
{
    union align align
    char mem[1048576UL]
};

static union reserve reserve;
```

Avec ceci, vous devriez pouvoir réaliser la fonction `static_malloc()` sans encombre.  
*Hop* *hop* ! Au travail ! :)