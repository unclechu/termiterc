#!/usr/bin/env perl
use v5.10; use strict; use warnings; use autodie qw(:all);
die 'unexpected arguments count' if scalar(@ARGV) != 1;
use Env qw<HOME>;
use Cwd qw(abs_path);
use IPC::System::Simple qw<runx capturex>;

my $__dirname = abs_path './';
my $config_dir = "$HOME/.config/termite/";

if ($ARGV[0] eq 'symlinks') {

  my $lnk = sub {runx qw<ln -s -->, ("$__dirname/$_[0]"), $_[1] ? ($_[1]) : ()};

  runx 'mkdir', '-p', '--', $config_dir;
  chdir $config_dir;

  &$lnk('config');
  &$lnk('config', 'config-dark');
  &$lnk('config-light');

} elsif ($ARGV[0] eq 'clean') {

  my $rmlnk = sub {$_ = "$config_dir/$_[0]"; unlink $_ if -l $_};

  &$rmlnk('config');
  &$rmlnk('config-dark');
  &$rmlnk('config-light');

} else {
  die "unknown argument: '$ARGV[0]'";
}

# vim: et ts=2 sts=2 sw=2 cc=81 tw=80 :
