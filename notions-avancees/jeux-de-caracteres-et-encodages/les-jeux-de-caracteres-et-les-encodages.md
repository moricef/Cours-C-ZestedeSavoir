# Introduction

[[information]]
| Avant de poursuivre ce chapitre, nous vous invitons à lire au moins les deux premiers chapitres du [cours de Maëlan sur les encodages](https://zestedesavoir.com/tutoriels/1114/comprendre-les-encodages/). Ceux-ci constitueront une base solide sur laquelle nous nous appuierons dans la suite.

# Ce que dit la norme

Maintenant que les notions de jeux de caractères et d'encodages vous sont connues, voyons comment celles-ci s'agencent en C. La norme définit deux jeux de caractères[^jeux] :

1. Le jeu de caractères source qui, comme son nom ne l'indique pas, correspond au jeu de caractères vers lequel votre fichier source va être converti. Il ne s'agit donc pas de l'encodage de votre fichier source (que vous déterminez à l'aide de votre éditeur de texte), mais d'un encodage interne au compilateur.
2. Le jeu de caractères d'exécution qui correspond à celui utilisé par votre système (il est par exemple utilisé par votre console) vers lequel votre programme sera finalement traduit. Ce dernier dépend de la *locale* employée (nous y reviendrons un peu plus tard dans ce chapitre).

[[information]]
| Autrement dit, il y a possiblement deux conversions lors de la compilation : une qui a lieu du jeu de caractères de vos fichiers sources vers le jeu employé en interne par le compilateur et une depuis le jeu de caractères du compilateur vers celui du système.

# Caractères garantis

La norme précise que ces deux jeux comprennent au minimum les caractères suivants.

```text
A  B  C  D  E  F  G  H  I  J  K  L  M
N  O  P  Q  R  S  T  U  V  W  X  Y  Z
a  b  c  d  e  f  g  h  i  j  k  l  m
n  o  p  q  r  s  t  u  v  w  x  y  z
0  1  2  3  4  5  6  7  8  9
!  "  #  %  &  '  (  )  *  +  ,  -  .  /  :
;  <  =  >  ?  [  \  ]  ^  _  {  |  }  ~
```

À ceux-ci s'ajoutent l'espace, les tabulations horizontales et verticales et le saut de page.

Il est également précisé que les points de codes des dix chiffres (`'0'`, `'1'`, `'2'`, `'3'`, `'4'`, `'5'`, `'6'`, `'7'`, `'8'` et `'9'`) doivent se suivre de manière croissante.

## Jeu de caractère source

De plus, le jeu de caractères source doit comprendre un ou plusieurs caractères permettant d'indiquer la fin d'une ligne de texte.

## Jeu de caractère d'exécution

Enfin, le jeu de caractères d'exécution doit comprendre le caractère nul, le caractère d'appel, l'espacement arrière, le retour chariot et le saut de ligne.

[[question]]
| Certes, mais encore ?  
| C'est super cette description détaillée, mais ça m'apporte quoi de savoir ça ? J'en fais quoi, moi, de vos deux jeux ?

Pour résumer, la norme nous décrit ici les caractères qui peuvent être employés dans vos fichiers sources et les caractères que votre système doit supporter au minimum.

Ceci est impératif pour assurer d'une part la compilation de vos programmes et la bonne exécution de ceux-ci. En effet, imaginer par exemple que le compilateur utilise en interne un jeu de caractères ne comprenant pas le caractère `p`, vous serez bien ennuyer ensuite pour faire appel à `printf()`... De même, il serait fort gênant que votre console ne sache pas afficher les retours à la ligne.

Toutefois, cela a également une seconde conséquence : si vous utilisez un autre caractère que ceux énumérés ci-dessus (par exemple un « e » accent, un caractère cyrillique ou un idéogramme japonais), la norme ne vous garantit pas d'une part que la compilation réussisse (la conversion du jeu utilisé par vos fichiers sources vers celui du compilateur pourrait par exemple échouer) et, d'autre part, que ceux-ci seront supportés par votre système (si ce n'est pas le cas, cela se traduira le plus souvent par un affichage chaotique).

Aussi, dans un soucis de portabilité, il est nécessaire de se contenter le plus souvent de ces derniers, ce qui exclut donc l'emploi (ou à tout le moins l'emploi correct) de la plupart des langues du monde à l'exception de l'anglais et du latin. :-°

[[information]]
| 1. Cette restriction doit toutefois être relativisée puisque la plupart des compilateurs utilisent l'UTF-8 en interne, de même que les systèmes d'exploitations modernes. De plus, cette restriction n'a pas d'objet pour les commentaires puisque ceux-ci sont ignorés lors de la compilation.
| 2. Par ailleurs, sachez qu'il existe pas mal de solutions permettant de contourner cette limitation. À ce sujet, si cela vous intéresse, nous vous recommendons [GNU gettext](https://www.gnu.org/software/gettext/manual/html_node/index.html) qui est une solution libre et gratuite très utilisée sous GNU/Linux et *BSD.

[[attention]]
| Les plus attentifs (ou fourbes, c'est selon :p ) d'entre-vous se rappelerons sans doute que plusieurs des codes présentés dans ce cours comportent des caractères accentués et... oui, nous n'avons pas respecté la norme sur ce point. Mais bon, un exemple n'est-il pas plus agréable avec ? :ange:

[^jeux]: Programming Language C, X3J11/88-090, § 2.2.1, Character sets