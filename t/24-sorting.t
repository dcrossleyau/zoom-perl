# $Id: 24-sorting.t,v 1.1 2005-11-04 17:08:20 mike Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 24-sorting.t'
#
#   ###	At present, this test fails: see comment to "14-sorting.t"

use strict;
use warnings;
use Test::More tests => 27;
use MARC::Record;

BEGIN { use_ok('ZOOM') };

my $host = "indexdata.com/gils";
my $conn;
eval { $conn = new ZOOM::Connection($host, 0) };
ok(!$@, "connection to '$host'");

my $qstr = '@attr 1=4 map';
my $query = new ZOOM::Query::PQF($qstr);
eval { $query->sortby("1=4 <i") };
ok(!$@, "sort specification accepted");
my $rs;
eval { $rs = $conn->search($query) };
ok(!$@, "search for '$qstr'");
my $n = $rs->size();
ok($n == 5, "found $n records (expected 5)");

$rs->option(preferredRecordSyntax => "usmarc");
my $previous = "";		# Sorts before all legitimate titles
foreach my $i (1 .. $n) {
    my $rec = $rs->record($i-1);
    ok(defined $rec, "got record $i of $n");
    my $raw = $rec->raw();
    my $marc = new_from_usmarc MARC::Record($raw);
    my $title = $marc->title();
    ok($title ge $previous, "title '$title' ge previous '$previous'");
    $previous = $title;
}

# Now reverse the order of sorting
$rs->sort("dummy", "1=4 >i");
### There's no way to check for success, as this is a void function

$previous = "z";		# Sorts after all legitimate titles
foreach my $i (1 .. $n) {
    my $rec = $rs->record($i-1);
    ok(defined $rec, "got record $i of $n");
    my $raw = $rec->raw();
    my $marc = new_from_usmarc MARC::Record($raw);
    my $title = $marc->title();
    ok($title le $previous, "title '$title' le previous '$previous'");
    $previous = $title;
}

$rs->destroy();
ok(1, "destroyed result-set");
$conn->destroy();
ok(1, "destroyed connection");