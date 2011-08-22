package whatever;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Dancer;
our $VERSION = '0.1';

get '/' => sub {
   return 'Hello, world!';
};

1;
__END__

