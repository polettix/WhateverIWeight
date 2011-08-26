package whatever;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Dancer;
use Dancer::Plugin::FlashNote qw( flash );
our $VERSION = '0.1';

get '/' => sub {
   template 'index';
};

1;
__END__

