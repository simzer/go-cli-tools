#!/usr/bin/perl
`wget -O data.html http://senseis.xmp.net/?KGSRankHistogram%2FData`;
`html2text -o data.txt data.html`;

open DAT, 'data.txt';
$max = 0;
while (<DAT>)
{
  @cells = split /_*\|/;
  if (exists $cells[1] && $cells[1] =~ /^(\d+)$/ && $1 < 40) {
    $data[$1]=$cells[8];
    $name[$1]=$cells[2];
    $sum += $cells[8];
    if ($cells[8] > $max) { $max = $cells[8]; };
  }
}
close DAT;

open CSV, '>data.csv';
$accu = 0;
$i = 0;
for(@data) {
  $i++;
  $accu += $_;
  print CSV (41-$i)."\t".(100*$_/$sum)."\t".(100 - 100 * $accu/$sum)."\t".$name[$i]."\t\n";
}
close CSV;

$mykju = 13.5;
$me = 41 - (31 - $mykju);
$max = 100*$max/$sum;

open GPLT, "| gnuplot -persist";
print GPLT <<GPLT;
set terminal pngcairo  enhanced font "arial,12" size 800,480
set output 'kgshist.png'
set title "KGS histogram (2010. april 13)"
set style fill  transparent solid 0.50 noborder
set logscale x
set logscale x2
set format x ""
set format x2 ""
set key left top
set object 1 rect from screen 0, 0, 0 to screen 1, 1, 0 behind 
set object 1 rect fc  rgbcolor "#DDDDEE"  fillstyle solid 1.0  border -1
set ylabel "players better than you [%]"
set y2label "players at level [%]"
set style fill transparent solid 0.1 border
set style arrow 7 nohead ls 0
set arrow from 1,0 to 1,100 as 7
set arrow from 2,0 to 2,100 as 7
set arrow from 3,0 to 3,100 as 7
set arrow from 4,0 to 4,100 as 7
set arrow from 5,0 to 5,100 as 7
set arrow from 6,0 to 6,100 as 7
set arrow from 10,0 to 10,100 as 7
set arrow from 10,0 to 10,100 as 7
set arrow from 20,0 to 20,100 as 7
set arrow from 30,0 to 30,100 as 7
set arrow from 40,0 to 40,100 as 7
set label 1 "1d" at 10,50 center
set label 2 "10k" at 20,50 center
set label 3 "20k" at 30,50 center
set label 4 "30k" at 40,50 center
set label 5 "5d" at 6,50 center
set label 6 "6d" at 5,50 center
set label 7 "7d" at 4,50 center
set label 8 "8d" at 3,50 center
set label 9 "9d" at 2,50 center
#set arrow from $me,0 to $me,100 as 7
#set label 10 "me" at $me,50 center
set xrange [1.9:42];
set x2range [1.9:42];
set yrange [-3:103];
set y2range [(-0.03*$max):(1.03*$max)];
set ytics nomirror
set y2tics
plot 'data.csv' using 1:3 axes x1y1 title 'players better than you' with filledcurves x1 lc rgbcolor "#000088", \\
     'data.csv' using 1:2:xticlabels("") axes x2y2 title 'players at level' with filledcurves x1 lc rgbcolor "#880000" 
GPLT
close GPLT;

`display kgshist.png`;