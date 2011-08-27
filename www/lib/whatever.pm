package whatever;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Dancer;
use Dancer::Plugin::FlashNote qw( flash );
our $VERSION = '0.1';

use DotCloudStuff qw< get_nosqldb_handle >;

$redis = get_nosqldb_handle();

get '/' => sub {
   my %p;
   session(username => params->{username}) if params->{username};
   $p{weights} = get_weights_of(session('username'))
      if session('username');
   $p{users} = get_users();
   template 'index', \%p;
};

get '/show/:username' => sub {
   session(username => params->{username});
   redirect '/';
};

post '/record' => sub {

};

sub get_weights_of {
   
}

sub get_users {
   return [ $redis->smembers('users') ];
}

1;
__END__

