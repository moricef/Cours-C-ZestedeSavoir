### En résumé

1. Une fonction à nombre variable d'arguments est capable de recevoir et de manipuler une suite indéterminée d'arguments optionnels de types potentiellement différents.
1. L'ellipse ne peut être placée qu'à la fin de la liste des paramètres et doit impérativement être précédée d'un paramètre non optionnel.
1. La macrofonction `va_arg()` n'effectue *aucune* vérification, il est donc impératif de contrôler le nombre et le types des arguments reçus, par exemple à l'aide d'une chaîne de formats ou d'un paramètre décrivant le nombre d'arguments transmis.