package DotCloudStuff;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );
use Exporter qw( import );

our @EXPORT_OK = (
   qw<
     get_dotcloud_config
     get_sqldb_handle
     get_nosqldb_handle
     >
);

# Module implementation here
my %config;

sub get_dotcloud_config {
   my $filename = shift || '/home/dotcloud/environment.json';
   if (!scalar keys %config) {
      require JSON;
      my $text = do { local (@ARGV, $/) = ($filename); <>; };
      %config = %{JSON::from_json($text)};
   }
   return %config if wantarray();
   return { %config };
} ## end sub get_dotcloud_config

sub get_sqldb_handle {
   my %config = get_dotcloud_config();
   my ($username, $password, $hostname, $port) = map {
      $config{'DOTCLOUD_SQLDB_MYSQL_' . $_}
   } qw< LOGIN PASSWORD HOST PORT >;
   require DBI;
   my $dbh = DBI->connect(
      "dbi:mysql:host=$hostname;port=$port;database=whatever",
      $username, $password,
      { RaiseError => 1},
   );
   return $dbh;
}

sub get_nosqldb_handle {
   my %config = get_dotcloud_config();
   my ($password, $hostname, $port) = map {
      $config{'DOTCLOUD_NOSQLDB_REDIS_' . $_}
   } qw< PASSWORD HOST PORT >;
   require Redis;
   my $redis = Redis->new(server => "$hostname:$port");
   $redis->auth($password);
   return $redis;
}

1;
__END__

