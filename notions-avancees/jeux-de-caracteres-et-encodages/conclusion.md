### En résumé

1. La norme définit deux jeux de caractères : le jeu de caractère source, utilisé en interne par le compilateur, vers lequel vos fichiers sources sont convertis et le jeu de caractère d'exécution, utilisé par votre système, vers lequel la conversion finale aura lieu.
1. Mise à part les caractères garantis par la norme, les caractères supportés par les jeux de caractères source et d'exécution sont indéterminés.
1. Le type `wchar_t` et les fonctions de conversion associées permettent de construire des chaînes de caractères larges à partir de chaîne simple, ce qui est particulièrement utile lorsque le jeu employé par le système encode les caractères sur un nombre variable de multiplets (comme l'ISO-2022 ou l'UTF-8).
1. Ces fonctions de conversions disposent d'un était interne qui doit être réinitialisé après une erreur ou avant chaque changement de données à traiter.
1. La fonction `setlocale()` permet de modifier la localisation de certaines fonctions de la bibliothèque standard.