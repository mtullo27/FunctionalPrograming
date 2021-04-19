#!/bin/sh

#run from dir for a specific implementation language

#uses json-diff jd <https://github.com/josephburnett/jd> to avoid
#problems with key ordering.

EXTRAS=$HOME/cs471/projects/prj1/extras

for f in example fact simple devel1;
do
    ./scan.sh < $EXTRAS/$f.tl > $f-toks.json
    jd $EXTRAS/$f-toks.json $f-toks.json
    ./parse.sh < $EXTRAS/$f.tl > $f-asts.json
    jd $EXTRAS/$f-asts.json $f-asts.json
done

   

