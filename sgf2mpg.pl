#!/usr/bin/perl
$i = 0;
$t = 0;
$sgf = $ARGV[0];
$mpg = $ARVG[1];
$tmax= $ARGV[2];
`rm /tmp/*sgf2mpg*`;
print ("Rendering frames\n");
while ($t <= $tmax)
{
  print("Time: $t/$tmax\n");
  $stamp = sprintf("%08d", $i);
  `./sgf2png.pl $sgf /tmp/tmp_sgf2mpg.png $t`; 
  `composite -compose screen /tmp/tmp_sgf2mpg.png goban.png /tmp/sgf2mpg$stamp.png`;
  $i++;
  $t += 0.02;
}
print ("Rendering video\n");
`mencoder mf:///tmp/sgf2mpg*.png -mf fps=25:type=png -ovc lavc -lavcopts vcodec=mpeg4 -oac copy -o $mpg`;
#`ffmpeg -f image2 -i /tmp/sgf2mpg%d.png $mpg`;