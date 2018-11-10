Dans la pratique, les énumérations servent essentiellement à fournir des informations supplémentaires via le typage, par exemple pour les retours d'erreurs. En effet, le plus souvent, les fonctions retournent un entier pour préciser si leur exécution s'est bien déroulée. Toutefois, indiquer un retour de type `int` ne fourni pas énormément d'information. Un type énuméré prend alors tout son sens.

La fonction `vider_tampon()` du dernier T.P. s'y prêterait par exemple bien.

```c
enum erreur { E_OK, E_ERR };


static enum erreur vider_tampon(FILE *fp)
{
    int c;

    do
        c = fgetc(fp);
    while (c != '\n' && c != EOF);

    return ferror(fp) ? E_ERR : E_OK;
}
```

De cette manière, il est plus clair à la lecture que la fonction retourne le statut de son exécution.

Dans la même idée, il est possible d'utiliser un type énuméré pour la fonction `statut_jeu()` (également employée dans la correction du dernier T.P.) afin de décrire plus amplement son type de retour.

```c
enum statut { STATUT_OK, STATUT_GAGNE, STATUT_EGALITE };


static enum statut statut_jeu(struct position *pos, char jeton)
{
    if (grille_complete())
        return STATUT_EGALITE;
    else if (calcule_nb_jetons_depuis(pos, jeton) >= 4)
        return STATUT_GAGNE;

    return STATUT_OK;
}
```

Dans un autre registre, un type enuméré peut être utilisé pour contenir des drapeaux. Par exemple, la fonction `traitement()` présentée dans le chapitre relatif aux opérateurs de manipulation des *bits* peut être réecrite comme suit.

```c
enum drapeau {
	PAIR = 0x00,
	PUISSANCE = 0x01,
	PREMIER = 0x02
};


void traitement(int nombre, enum drapeau drapeaux)
{
    if (drapeaux & PAIR) /* Si le nombre est pair */
    {
        /* ... */
    }
    if (drapeaux & PUISSANCE) /* Si le nombre est une puissance de deux */
    {
        /*... */
    }
    if (drapeaux & PREMIER) /* Si le nombre est premier */
    {
        /*... */
    }
}
```