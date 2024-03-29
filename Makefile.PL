use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'WWW::TubeUpdates',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/WWW/TubeUpdates.pm',
    ABSTRACT_FROM => 'lib/WWW/TubeUpdates.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'WWW-TubeUpdates-*' },
    PREREQ_PM     => {
        'Test::More'  => 0,
        'Test::Warn'  => 0,
        'Readonly'    => '1.03',
        'Moose'       => '2.0006',
        'HTTP::Request'    => '1.40',
        'LWP::UserAgent'   => '2.33',
        'namespace::clean' => '0.20',
        'MooseX::Params::Validate'     => '0.16',
        'Moose::Util::TypeConstraints' => '2.0006',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);