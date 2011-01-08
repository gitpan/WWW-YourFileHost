#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Cookies;
use WWW::YourFileHost;
use Test::More tests => 3;

my $url = "http://www.yourfilehost.com/media.php?cat=video&file=kitty_birthday_card.flv";
my $ua = LWP::UserAgent->new( agent => "Mozilla/5.0 (Windows; U; Windows NT 5.0; ja; rv:1.9) Gecko/2008052906 Firefox/3.0", show_progress => 1, cookie_jar => {} );

my $res = WWW::YourFileHost->new( url => $url, ua => $ua );
isa_ok $res, 'WWW::YourFileHost';

my $checksum = '9c557d375a926e1a6002177c7da34dd4';
like $res->photo,    qr/$checksum\.jpg$/, 'photo';
like $res->video_id, qr/$checksum\.flv/,  'video_id';
diag($url);
diag($res->video_id);
diag($res->swf);
