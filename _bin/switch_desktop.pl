#!/usr/bin/env perl

use strict;
use warnings;

my ($dir_string, $num, $wrap) = @ARGV;

# configuration variables
# set any or all of them
# values will be guessed if not set

my $num_rows = 0;
my $num_desktops_per_row = 0;

$dir_string ||= 'right'; # move right if not specified
$num ||= 1; # move by 1 workspace if not specified
$wrap = 1 unless (defined $wrap); # wrap around 

my $debug = 0;



# get state from window manager

my $desktops = `wmctrl -d`;
chomp $desktops;
my $num_desktops = @{[split("\n", $desktops)]};
my $current_desktop = ($desktops =~ /^(\d+)\s+\*/m) ? $1 : 0;

print "Number of desktops: $num_desktops\nCurrent desktop: $current_desktop\n" if ($debug);

# guess configuration variables

$num_rows = 1 + int(($num_desktops - 1) / $num_desktops_per_row) if ($num_desktops_per_row);
my $tmp = int(sqrt($num_desktops));
until ($num_rows > 0) {
  $num_rows = $tmp unless ($num_desktops % $tmp);
  $tmp--;
}
$num_desktops_per_row ||= 1 + int(($num_desktops - 1) / $num_rows);

print "Number of rows: $num_rows\nNumber of cols: $num_desktops_per_row\n" if ($debug);

# actual code

my $current_row = int($current_desktop / $num_desktops_per_row);
my $current_col = $current_desktop % $num_desktops_per_row;

print "Current row: $current_row\nCurrent col: $current_col\n" if ($debug);

my $new_row = $current_row;
my $new_col = $current_col;
$new_row += $num if ($dir_string =~ /^down/i);
$new_row -= $num if ($dir_string =~ /^up/i);
$new_col += $num if ($dir_string =~ /^right/i);
$new_col -= $num if ($dir_string =~ /^left/i);

my $tmp_num_rows = $num_rows;
my $tmp_num_cols = $num_desktops_per_row;
$tmp_num_rows-- if ($current_col > (($num_desktops - 1) % $num_desktops_per_row));
$tmp_num_cols = ($num_desktops % $num_desktops_per_row) || $num_desktops_per_row if ($current_row == $num_rows - 1);

if ($wrap) {
  $new_col = ($tmp_num_cols + ($new_col % $tmp_num_cols)) % $tmp_num_cols;
  $new_row = ($tmp_num_rows + ($new_row % $tmp_num_rows)) % $tmp_num_rows;
} else {
  $new_col = 0 if ($new_col < 0);
  $new_col = $tmp_num_cols - 1 if ($new_col >= $tmp_num_cols);
  $new_row = 0 if ($new_row < 0);
  $new_row = $tmp_num_rows - 1 if ($new_row >= $tmp_num_rows);
}

print "New row: $new_row\nNew col: $new_col\n" if ($debug);

# set the new desktop

my $new_desktop = $new_row * $num_desktops_per_row + $new_col;
system('wmctrl', '-s', $new_desktop) unless ($debug);

print "New desktop: $new_desktop\n" if ($debug);
