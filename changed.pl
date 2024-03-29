#!/usr/bin/env perl -w

#
# In a directory under either svn or git version control, print all the changed files
#

use strict;
use File::Spec::Functions qw/catfile curdir rootdir updir/;

sub getSvnChangedFiles {
  my ($dir) = @_;
  my @changedFiles = ();
  open my $fh, '-|', "svn --ignore-externals status $dir" or die $!;
  while (<$fh>) {
    chomp;
    next if /^\s*$/;
    debug($_);
    my ($status, $props, $locked, $history, $switched, $repolock, $treeconflict, $filename) = ($_ =~ /^(.)(.)(.)(.)(.)(.)(.)\s+(.*)/);
    debug("<$status><$filename>\n");
    if ( $status =~ /^[AMCR~]$/ ) {
      push @changedFiles, $filename; 
    }
  }
  close $fh or die $!;
  return @changedFiles;
}

sub getGitChangedFiles {
  my ($dir) = @_;
  my @changedFiles = ();
  open my $fh, '-|', "git status --porcelain $dir" or die $!;
  while (<$fh>) {
    chomp;
    next if /^\s*$/;
    my ($status, $filename) = split ' ', $_, 2;
    debug("<$status><$filename>\n");
    # don't show deleted files?
    push @changedFiles, $filename; 
  }
  close $fh or die $!;
  return @changedFiles;
} 

sub getChangedFiles {
  my ($dir) = @_;
  my @changedFiles = undef;
  if ( -e catfile($dir, ".svn") ) {
    debug( "svn!");
    @changedFiles = getSvnChangedFiles($dir);
  } elsif (selfOrAncestorContains($dir, '.git')) {
    debug( "git!");
    @changedFiles = getGitChangedFiles($dir);
  } else {
    die "The directory $dir doesn't seem to be under version control.";
  }
  return @changedFiles;
}

sub selfOrAncestorContains {
  my ($dir, $file) = @_;
  my $contains = 0;
  if (-e catfile($dir, $file) ) {
    $contains = 1;
  } else {
    if ($dir ne rootdir() and $dir ne '') {
      my $parentDir = updir($dir);
      $contains = selfOrAncestorContains($parentDir, $file);
    }
  }    
  return $contains;
}

sub debug {
  my ($s) = @_;
  if ( $ENV{'DEBUG'} ) {
    print $s;
  }
}



my $dir = curdir();
if ($ARGV[0]) {
  $dir = $ARGV[0];
  chdir $dir or die $!;
}


for my $file ( getChangedFiles($dir) ) {
  print "$file\n";
}
