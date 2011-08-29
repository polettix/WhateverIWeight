package DotCloudStuff;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );
use Exporter qw( import );
use DotCloud::Environment;

our @EXPORT_OK = (
   qw<
     get_sqldb_handle
     get_nosqldb_handle
     >
);

# Module implementation here
my $dcenv = DotCloud::Environment->new(backtrack => 1);

sub get_sqldb_handle {
   my ($host, $port, $user, $pass) = $dcenv->service_vars(
      service => 'sqldb',
      list    => [qw< host port login password >]
   );
   require DBI;
   my $dbh = DBI->connect(
      "dbi:mysql:host=$host;port=$port;database=whatever",
      $user, $pass, {RaiseError => 1},
   );
   return $dbh;
} ## end sub get_sqldb_handle

sub get_nosqldb_handle {
   my ($host, $port, $pass) = $dcenv->service_vars(
      service => 'nosqldb',
      list    => [qw< host port password >]
   );
   require Redis;
   my $redis = Redis->new(server => "$host:$port");
   $redis->auth($pass);
   return $redis;
} ## end sub get_nosqldb_handle

1;
__END__

