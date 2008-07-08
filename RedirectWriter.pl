#!/usr/bin/perl

use lib qw( /home/swheeler/local/lib/perl5 );

use strict;
use DBI;
use Encode;
use URI::Escape;

our $database;

sub connectToDatabase
{
  my $name = "related_wikipedia";
  my $hostname = "localhost";
  my $port = "3306";
  my $username = "scott";
  my $password = "";

  # my $hostname = "mysql.directededge.com";
  # my $username = "bungipedia";
  # my $password = "boingboing";

  my $dsn = "DBI:mysql:database=$name;host=$hostname;port=$port;mysql_enable_utf8=1";
  $database = DBI->connect($dsn, $username, $password) or die("Could not connect!");
}

sub lastId
{
  my $handle = $database->prepare("select max(id) from pages");
  $handle->execute();
  my @values = $handle->fetchrow_array();
  return $values[0];
}

sub writeDisambigs
{
  open(DISAMBIGS,  "<:utf8", "disambigs.txt") || die("Could not open disambigs file.");

  binmode(DISAMBIGS, "<:utf8");

  my $id = lastId() + 1;
  my $count = 0;

  while(my $line = <DISAMBIGS>)
  {
    chomp($line);
    $line = uri_unescape($line);
    $database->do("insert into pages values( ?, ? )", undef, ($id++, $line));

    if(++$count % 1000 == 0)
    {
      print "$count disambigs processed.\n";
    }
  }
}

sub writeRedirects
{
  open(REDIRECTS,  "<:utf8", "redirects.txt") || die("Could not open redirects file.");

  binmode(REDIRECTS, "<:utf8");

  my $count = 0;

  while(my $line = <REDIRECTS>)
  {
    Encode::_utf8_on($line);

    chomp($line);
    my @names = split('\|', $line, 2);
    my $source = uri_unescape($names[0]);
    my $target = uri_unescape($names[1]);

    my $handle = $database->prepare("select id from pages where name = ? collate utf8_bin");

    $handle->execute($target);

    my @values = $handle->fetchrow_array();

    if(@values > 0)
    {
      $database->do("insert into redirects values( ?, ? )", undef, ($source, $values[0]));
    }
    else
    {
      print "Could not find \"$target\"\n";
    }

    if(++$count % 1000 == 0)
    {
      print "$count redirects processed.\n";
    }
  }
}

binmode(STDOUT, "<:utf8");

connectToDatabase();
writeDisambigs();
writeRedirects();
