use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'whatever-backend',
    AUTHOR              => q{Flavio Poletti <flavio@polettix.it>},
    VERSION             => '0.1',
    ABSTRACT            => 'Whatever I Like / Backend',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Log::Log4perl::Tiny' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'whatever-*' },
);
