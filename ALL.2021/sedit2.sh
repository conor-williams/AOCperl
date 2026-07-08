set -xv
for i in *.pl
do
    echo $i

    sed '1,$ s/p_ans/pl_ans/' $i > $i.out
    mv $i.out $i
done
