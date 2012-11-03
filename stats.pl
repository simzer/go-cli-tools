#!/usr/bin/perl
use Time::Local;

@users = ('simzer', 'yals');
$year0 = 2011;
$month0 = 8;
$year1 = 2012;
$month1 = 3;
`mkdir -p pages`;
for $user (@users) {
  for($year = $year0; $year <= $year1; $year++) {
    for ($month = (($year == $year0) ? $month0 : 1);
         $month <= (($year == $year1) ? $month1 : 12);
         $month++) {
      unless(-e "pages/$user-statistics-$year-$month.txt") 
      {
        $cmd = <<CMD;
wget -O pages/$user-statistics-$year-$month.html "http://www.gokgs.com/gameArchives.jsp?user=$user&year=$year&month=$month"
html2text -width 200 -o pages/$user-statistics-$year-$month.txt pages/$user-statistics-$year-$month.html
sleep 2
CMD
        print($cmd);
        print `$cmd`;
      }
      push @content, `cat pages/$user-statistics-$year-$month.txt`;
    }
  }
  for (@content) {
    if(/^
       (Yes|No)\s+
       (\w+)_\[(\d+)([kdp]*)(\?*)\]\s+
       (\w+)_\[(\d+)([kdp]*)(\?*)\]\s+
       (\d+[^\d]+\d+)\s+
       (H\d)*
       (\d+)\/(\d+)\/(\d+)\s+
       (\d+):(\d+)\s+(AM|PM)\s+
       (\w+)\s+
       ([W|B])\+(\w+)
       /x) {
      ($Viewable, $W, $WRank, $WR2, $WR3,$B, $BRank, $BR2, $BR3, $Size, $Handi,
       $month, $day, $year, $hour, $min, $ampm, 
       $Type, $Winner, $Result) =
      ($1,$2,$3,$4,$5,$6,$7,$8,$9,
       $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20);
      $myrank = ($W eq $user) ? $WRank : $BRank;
      if ($Size =~ /^19/) {
        $key = (2000+$year)*10000+$month*100+$day;
        $stat->{$key}->{lost}+=0;
        $stat->{$key}->{win}+=0;
        $stat->{$key}->{ranksum} += $myrank;
        $stat->{$key}->{cnt}++;
        if (${$Winner} eq $user) {
          $stat->{$key}->{win}++;
        } else {
          $stat->{$key}->{lost}++;      
        }
      }
    }    
  }
}

$lost = 0;
$win  = 0;
open FIT, ">fit.csv";
open STAT, ">stats.csv";
for (sort(keys(%{$stat}))) {
  if ($stat->{$_}->{win} == 0 && $win == 0) {
    $lost += $stat->{$_}->{lost};
    next;
  }
  if ($stat->{$_}->{lost} == 0 && $lost == 0) {
    $win += $stat->{$_}->{win};
    next;
  }
  $lost += $stat->{$_}->{lost};
  $win += $stat->{$_}->{win};
  $all = $lost+$win;
  $actrank = $stat->{$_}->{ranksum}/$stat->{$_}->{cnt};
  $prob = $win / $all;
  $estrank = (1/0.6)*(log(-exp(0.6*$actrank)*($prob-1)/$prob));
  $day = $_%100;
  $month = (int($_/100)%100);
  $year = int($_/10000);
  $date = timelocal(0,0,0,$day,$month-1,$year);
  $date -= timelocal(0,0,0,10,8-1,2011);
  $date = int($date / 24 / 60 / 60);
  for ($i = 0; $i < $all; $i++) {
    print FIT ($date."\t"."$month.$day\t".$all."\t".$estrank."\n");
  }
  print STAT ($date."\t"."$month.$day\t".$all."\t".$estrank."\n");
  $lost = 0;
  $win  = 0;
}
close FIT;
close STAT;

`gnuplot stats.plt -persist`;