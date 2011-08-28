package whatever;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Dancer;
use Dancer::Plugin::FlashNote qw( flash );
our $VERSION = '0.1';
use Try::Tiny;
use Time::Local qw( timelocal );

use DotCloudStuff qw< get_nosqldb_handle >;


get '/' => sub {
   my %p;
   session(username => params->{username}) if params->{username};
   if (session('username')) {
      $p{weights} = get_weights_of(session('username'));
      my $last_weight = $p{weights}[-1][1];
      my @range = map {
         my $weight10 = $last_weight * 10 + $_;
         my $class = $weight10 % 5 ? 'tick'
            : $weight10 % 10 ? 'half-kilo'
            :                  'int-weight';
         {
            weight => $weight10 / 10,
            class  => $class,
         };
      } -12 .. 12;
      $p{chooser} = \@range;
   }
   $p{users} = get_users();
   template 'index', \%p;
};

get '/show/:username' => sub {
   session(username => params->{username});
   redirect '/';
};

post '/record' => sub {
   my ($username, $date, $weight) = map { params->{$_} }
      qw< username date weight >;
   $date ||= '';
   $date =~ s/\A\s+|\s+\z//gmxs;
   $date = epoch2date(time()) if ! length($date) || lc($date) eq 'now';
   $date .= ' 08:00:00' unless $date =~ /\s/gmxs;
   session(username => $username);
   try {
      record_weight($username, $date, $weight);
      flash "weight recorded for $username";
   }
   catch {
      flash "weight not recorded, an error occurred: $_";
   };
   redirect '/';
};

post '/export' => sub {
   my $username = params->{username};
   session(username => $username);
   my $email  = params->{email};
   session(email => $email);
   my $redis = get_nosqldb_handle();
   $redis->rpush('exports', to_json({
      username => $username,
      email => $email,
   }));
   my $redis = get_nosqldb_handle();
   $redis->publish('exports', 'whatever');
   flash "recorded export request for $username to $email";
   redirect '/';
};

sub record_weight {
   my ($username, $datetime, $weight) = @_;
   $username =~ /\A[\w.-]+\z/mxs or die "invalid username $username\n";
   $weight = int($weight * 1000);

   my $redis = get_nosqldb_handle();
   $redis->multi();

   $datetime =~ s{\A\s+|\s+\z}{}gmxs;
   my $epoch = date2epoch($datetime);
   if ($epoch > time() - 32 * 24 * 3600) {
      # save only if sufficiently recent
      my ($date) = split /\s+/, $datetime;
      (my $score = $date) =~ s/\D//gmxs;
      $redis->set("weight:$username:$date", $weight);
      $redis->set("tstamp:$username:$date", $datetime);
      $redis->zadd("user:$username:dates", $score, $date);
      $redis->sadd("users", $username);
   }

   # push to backend
   $redis->rpush('new-weights', to_json({
      username => $username,
      weight   => $weight,
      epoch    => $epoch,
   }));
   $redis->publish('new-weights', 'whatever');

   $redis->exec();
   return;
}

sub date2epoch {
   my ($datetime) = @_;
   my ($year, $month, $mday, $hour, $min, $sec) =
      $datetime =~ m{
         \A
         (\d{4}) [/-] (\d{1,2}) [/-] (\d{1,2})
         \s+
         (\d{1,2}) : (\d{1,2}) : (\d{1,2})
         \z
      }mxs or die "invalid date format $datetime\n";
   return timelocal($sec, $min, $hour, $mday, $month - 1, $year - 1900);
}

sub get_weights_of {
   my ($username) = @_;
   my $redis = get_nosqldb_handle();
   my @retval = map {
      [
         $redis->get("tstamp:$username:$_")
            => sprintf '%.1f', $redis->get("weight:$username:$_") / 1000
      ]
   } $redis->zrangebyscore("user:$username:dates", '-inf', '+inf');
   return \@retval;
}

sub epoch2date {
   my ($sec, $min, $hour, $mday, $mon, $year) = localtime($_[0]);
   return sprintf '%04d-%02d-%02d %02d:%02d:%02d',
      $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
}

sub get_users {
   my $redis = get_nosqldb_handle();
   return [ $redis->smembers('users') ];
}

1;
__END__

