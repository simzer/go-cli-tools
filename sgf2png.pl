#!/usr/bin/perl
$sgf = $ARGV[0];
$dat = '/tmp/sgf2png_temp.dat';
$ppm = '/tmp/sgf2png_temp.ppm';
$png = $ARGV[1];
`rm /tmp/sgf2png*`;
`./sgf2dat.pl $sgf $dat $ARGV[2]`;
`./dat2ppm $dat $ppm`;
`convert $ppm -transpose -resize 2000% $png`;




