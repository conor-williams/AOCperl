set -xv
f1=.tmp1.`date`
sed '1,$ s/p_ans/pl_ans/' output.answers.log.txt > "$f1"
mv "$f1" output.answers.log.txt
