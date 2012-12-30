#!/usr/bin/perl

use IO::Handle;

$|++;

open my( $log ), ">", "mirrorgo.log";
$log->autoflush(1);

sub warning {
  my ($id, $comment) = @_;
  warn($comment."\n"); 
  print "? $comment\n\n";
  print $log "? $comment\n\n"; 
}

sub response {
  my ($id, $comment) = @_;
  print "= $comment\n\n";   
  print $log "= $comment\n\n";
}

sub processMove {
  my %cols = qw(A 1 B 2 C 3 D 4 E 5 F 6 G 7 H 8 J 9 K 10 
                L 11 M 12 N 13 O 14 P 15 Q 16 R 17 S 18 T 19);
  my ($move) = @_;
  if($move =~ /(\w)(\d+)/i) {
    my $row = $2;
    my $col = $cols{uc($1)};
    print $log "Move: $move = $col ($1), $row\n";
    return($col, $row);
  } else {
    warning("","can not process move: $move\n");
    return(0,0);
  }
}

sub genMove {
  my @cols = qw(X A B C D E F G H J K L M N O P Q R S T);
  my ($col,$row) = @_;
  print $log "$col,$row\n";
  return("$cols[$col]$row");  
}

sub cleartable {
  my ($table) = @_;
  for (my $col = 1; $col <=19; $col++) {
    for (my $row = 1; $row <=19; $row++) {
      $table->[$col][$row] = 0;
    }
  }
}

my $boardsize = 19;
my $move = "";
my $row = -1;
my $col = -1;
my $table;

cleartable($table);
while(<STDIN>)
{
  print $log $_;
  if(/(?:\d+\s+)*(\w+)(.*)/i)
  {
    my ($command, $args) = ($1, $2);
    if      ($command eq "list_commands") {
      response($id,"name\nversion\nquit\nlist_commands\nboardsize\nclear_board\nplay\ngenmove");
    } elsif ($command eq "name") {
      response($id,"mirrorgo");
    } elsif ($command eq "version") {
      response($id,"0.0.1");
    } elsif ($command eq "quit") {
      exit(0);
    } elsif ($command eq "boardsize") {
      if($args =~ /\s*(\d+)\s*/i) { 
        $boardsize = $1; 
        response($id,"");
      } else { warning($id,"boardsize not recognized."); }
    } elsif ($command eq "clear_board") {
      cleartable($table);
      response($id,"");
      $move = "";
    } elsif ($command eq "play") {
      if($args =~ /\s*(B|W|black|white)\s+(\w\d+|pass|resign)\s*/i) { $move = $2; }
      else { warning($id,"play syntax not recognized."); }      
      response($id,"");
    } elsif ($command eq "genmove") {
      if($move eq "pass") { response($id,"pass"); }
      elsif($move eq "resign") { response($id,"pass"); }
      elsif($move eq "") { response($id,"k10"); }
      else {
        ($col,$row) = processMove($move);
        $table->[$col][$row] = 1;
        if (($row == 10) && ($col == 10)) { response($id,"pass"); }
        else {
          $col = 20 - $col;
          $row = 20 - $row;
          if ($table->[$col][$row] == 1) { response($id,"pass"); }
          else {
            $table->[$col][$row] = 1;
            response($id,genMove($col, $row)); 
          }            
        }              
      }       
    } else {
      warning($id, "unknown command: $command"); 
    }
  } else {
    die("unknown input command format:\n$_\n");
  }
  print $log "waiting for new command\n";
}

close $log