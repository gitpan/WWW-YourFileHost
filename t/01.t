#!/usr/bin/perl

use strict;
use warnings;
use WWW::YourFileHost;
use Test::More tests => 4;

my $url = "http://www.yourfilehost.com/media.php?cat=video&file=guns_dont_kill_people.flv";

my $res = WWW::YourFileHost->new( url => $url );
isa_ok $res, 'WWW::YourFileHost';

my $checksum = 'a5f6dd20981c6b3a69e949b289613b07';
like $res->photo,    qr/$checksum\.jpg$/, 'photo';
like $res->video_id, qr/$checksum\.flv/, 'video_id';
is $res->embed,      $url;

