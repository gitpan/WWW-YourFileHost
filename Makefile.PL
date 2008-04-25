use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::YourFileHost',
    AUTHOR              => 'Yusuke Wada <yusuke@kamawada.com>',
    VERSION_FROM        => 'lib/WWW/YourFileHost.pm',
    ABSTRACT_FROM       => 'lib/WWW/YourFileHost.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'     => 0,
        'URI'            => 0,
        'Web::Scraper'   => 0,
        'URI::Escape'    => 0,
        'LWP::UserAgent' => 0,
        'CGI'            => 0,
      },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-YourFileHost-*' },
);
