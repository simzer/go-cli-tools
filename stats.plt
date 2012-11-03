#!/usr/bin/gnuplot -persist
set terminal pngcairo  enhanced size 800,480
set output 'stats.png'
set title "Go learning Curve (KGS user: simzer+yals)"
set key left bottom
set key nobox outside below font  "Helvetica,8"
set border lw 0.5
set style fill transparent solid 0.5 noborder
set object 1 rect from screen 0, 0, 0 to screen 1, 1, 0 behind 
set object 1 rect fc  rgbcolor "#FFFFF8"  fillstyle solid 1.0  border -1
set ytics font "Helvetica,8";
set grid mytics
set grid ytics lt 1 lc rgb("#DDAAAA") lw 0.5
#set log y
#set xtics rotate by 90;
set xtics nomirror
set grid xtics
set xtics font "Helvetica,8";
#set xtics out offset 0.4,-0.6;
#set yrange [40:18];
set yrange [40:13];
#set yrange [40:4];
#set xrange [0:143];
#set xrange [0:293];
set xrange [0:365];
#set xrange [0:730];
a=0.0055;
x0=-23;
kju0  = 13
lcf(x) = 12 - 42*exp((x0-x)*a)
fit lcf(x) "fit.csv" using 1:(-$4) via a, x0
plot \
  "stats.csv" using 1:(kju0+$4):(sqrt(5*$3)) w circles fs transparent solid 0.25 lc rgb("#FFFF00") title "match number", \
  kju0-lcf(x) title "learning curve\n(estimation f(x)=max-exp(-x))" lc rgb("#FFBB00"), \
  "ranks.lst" using (0*$1):1:yticlabel(2) w l notitle lw 0 lc "black", \
  "dates.lst" using 1:(0*$1):xticlabel(2) w l notitle lw 0
 