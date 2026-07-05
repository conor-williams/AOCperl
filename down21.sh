set -xv
year=2015
while [ $year != 2025 ]; do
    cd ALL.$year
    aocdl -day 21 -year $year -output year${year}_day21.i1.txt -force
    aocdl -day 22 -year $year -output year${year}_day22.i1.txt -force
    aocdl -day 23 -year $year -output year${year}_day23.i1.txt -force
    aocdl -day 24 -year $year -output year${year}_day24.i1.txt -force
    aocdl -day 25 -year $year -output year${year}_day25.i1.txt -force
    year=$((year+1))
    cd ..
done
