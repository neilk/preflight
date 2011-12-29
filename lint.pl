#!/usr/bin/env perl -w

use strict;
use File::Spec::Functions qw/curdir/;

my %linter = (
  'php' => sub { 
    system( 'php -l ' . $_[0] );
  },
  'js' => sub { 
    system( 'jslint ' . $_[0] );
  },
  'pl' => sub { 
    system( 'perl -c ' . $_[0] );
  },
);

sub getExtension {
  my ($file) = @_;
  debug( "file = $file\n");
  $file =~ /\.(\w+)$/;
  return $1;
}

my $dir = curdir();
if ($ARGV[0]) {
  $dir = $ARGV[0];
  chdir $dir or die $!;
}

sub debug {
  my ($s) = @_;
  if ( $ENV{'DEBUG'} ) {
    print $s;
  }
}



while (<>) {
  chomp;
  my $file = $_;
  my $ext = getExtension($file);
  if ( $ext and $linter{$ext} ) {
    warn "checking $file...\n";
    $linter{$ext}->($file);
  }
}


