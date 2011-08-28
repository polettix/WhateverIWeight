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
        'JSON' => '2.53',
        'JSON::XS' => '2.32',
        'YAML' => '0.73',
        'YAML::XS' => '0.35',
        'File::Slurp' => 0,
        'Redis' => '1.904',
        'DBI' => 0,
        'DBD::mysql' => 0,
        'Mail::Sender' => 0,
        'Text::CSV_XS' => 0,
        'Try::Tiny' => 0,
        'DotCloud::Environment' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'whatever-*' },
);
