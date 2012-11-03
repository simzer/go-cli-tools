#!/usr/bin/perl

$nummax = (defined $ARGV[2]) ? $ARGV[2] : 999999;
open SGF, $ARGV[0];
$sgf = join('',<SGF>);
close SGF;

for ($i = 0; $i < 19; $i++) {
  for ($j = 0; $j < 19; $j++) {
    $table[$i][$j] = 0;
  }
}

$num = 0;
while(($sgf =~ s/([BW])\[(\w)(\w)\]//) && ($num < $nummax)) {
  $weight = ($nummax - $num) < 1 ? ($nummax - $num)**2 * 127 : 127;
  $i = ord($2) - ord('a');
  $j = ord($3) - ord('a');
  $c = ($1 eq 'B') ? $weight : -$weight;
  $table[$i][$j] = $c;
  $num++;
}

open DAT, ">$ARGV[1]";
for ($i = 0; $i < 19; $i++) {
  for ($j = 0; $j < 19; $j++) {
    print DAT pack("c", $table[$i][$j]);    
  }
}
close DAT;