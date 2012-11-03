#!/usr/bin/perl
use strict;

my @table;

sub clear()
{
  for (my $i = 0; $i < 19*19; $i++) {
    $table[$i] = 0;
  }  
}

sub save($)
{
  open DAT, ">$_[0]";
  for (my $i = 0; $i < 19*19; $i++) {
    print DAT pack("c", $table[$i]);    
  }
  close DAT;
}

sub load($)
{
  open DAT, "$_[0]";
  for (my $i = 0; $i < 19*19; $i++) {
    my $a;
    read(DAT, $a, 1);
    $table[$i] = unpack("c", $a);
  }
  close DAT;
}

# MAIN

if($ARGV[0] eq 'reset') { save("gOK.dat"); exit(); }

my %res;

my $max = 0.0;
my $min = 0.0;
for(my $i = 0; $i < 19*19; $i++)
{
  load("gOK.dat");
  $table[$ARGV[0] + $ARGV[1]*19] = 127;
  if ($table[$i] == 0) {
    $table[$i] = -127;
    save("g.dat");
    $res{$i} = `./g`;
    if (($res{$i}) > $max) { $max = ($res{$i}); }
    if (($res{$i}) < $min) { $min = ($res{$i}); }
  } else {
    $res{$i} = 0;
  }
}

open RES, ">res.pgm";
print RES "P2\n19 19\n255";
for(my $i = 0; $i < 19*19; $i++)
{
  if ($i % 19 == 0) { print RES "\n"; };
  my $c = int(255 * ($res{$i}-$max+0.05*($max-$min))/(0.05*($max-$min)));
  if ($c < 0) { $c = 0; }
  print RES "$c ";
}
print RES "\n";
close RES;


my @sorted = sort {$res{$b} <=> $res{$a}} keys %res;
for (@sorted) {
}

load("gOK.dat");
$table[$ARGV[0] + $ARGV[1]*19] = 127;
my $rnd = rand(5);
my $move = @sorted[$rnd];
$table[$move] = -127;
print (($move%19)."-".int($move/19).", ");

save("gOK.dat");
save("g.dat");
`./g`;
`convert g.ppm -resize 2000% g.png && display g.png &`;
`convert res.pgm -resize 2000% res.png && display res.png &`;



