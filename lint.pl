#!/usr/bin/env perl -w

use strict;
use File::Spec::Functions qw/curdir/;
use File::Basename qw/dirname/;


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

sub getLinters {
  my %linters;
  my $progDir = dirname($0);
  open my $cfgFh, '<', "$progDir/lint.conf" or die $!;
  while (<$cfgFh>) {
    chomp;
    next if /^#/;
    my ($ext, $cmd) = split ' ', $_, 2;
    $linters{$ext} = sub {
      system( $cmd . $_[0] );
    };
  }
  close $cfgFh;
  return \%linters;
}

my $linters = getLinters();
while (<>) {
  chomp;
  my $file = $_;
  my $ext = getExtension($file);
  # might be useful to use magic on some files to determine what they are.
  if ( $ext and $linters->{$ext} ) {
    warn "checking $file...\n";
    $linters->{$ext}->($file);
  }
}


