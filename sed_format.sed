1,103d
s/uxe9/e/g
s/uxe8/e/g
s/uxee/i/g
s/uxea/e/g
s/uxe0/a/g
s/\\label/\r\\label/g
s/\\subsection/\\subsubsection/g
s/\\section/\\subsection/g
s/Shaded/C/g
s/verbatim/C/g
s/{\]}{\]} \\textbar{}/box}/g
s/{\[}{\[}/\\begin{/g
s/texttt/mybox/g
/^\\begin{Highlighting}/,/^\\end{Highlighting}/d
#s/\\begin{C}/\\begin{C}\n\r/g
s/informationbox/infobox/g
/\\tightlist/d
#s/\\begin{.*}/\\begin{.*}\r/g
s/\\begin{longtable}\[\]{@{}.*@{}}/\\begin{table}\r\\centering\r\\rowcolors{1}{}{gris-clair-tab}\r\\begin{tabular}{|l|l|}\\hline/g
s/\\toprule/\\rowcolor{gris-tab-entete}\\bf /g
/\\begin{minipage}/d
s/\\strut/\&/g
s/\\end{minipage}//g
s/\\bottomrule/\\end{tabular}/g
s/\\end{longtable}/\\end{table}/g
s/\\tabularnewline/\\tabularnewline\\hline/g
/\midrule/d
/\endhead/d
s/\\begin{secret{\]}{\]}/\\\begin{C}\n\r\\end{C}/g
#s/\\#/\r\n\r\n\\subsection{}\r\n\\label{}/g
/\\textbar{}\\mybox/d
s/\\href/\\MYhref/g