package WWW::YourFileHost;

use warnings;
use strict;
use Carp;
use URI;
use Web::Scraper;
use URI::Escape;
use LWP::UserAgent;
use CGI;
use HTTP::Cookies;

our $VERSION = '0.05';

sub new {
    my ( $class, %opt ) = @_;
    my $self = bless {%opt}, $class;
    $self->{ua} = LWP::UserAgent->new unless $self->{ua};
    if ( $self->{url} ) {
        $self->_scrape;
        $self->_get_info;
    }
    $self->_get_info if $self->{id};
    croak "url or id param is requred" unless $self->{_query};
    $self;
}

sub _scrape {
    my $self = shift;
    my $url  = $self->{url};
    croak "url is not yourfilehost link"
      unless $url =~ m!yourfilehost.com/media.php\?!;

    my $s = scraper {
        process
          '//object[@id="objectPlayer"]' => process '//param[@name="movie"]',
          'value'                        => '@value';
    };

    $s->user_agent($self->{ua});
    my $res = $s->scrape( URI->new($url) );
    croak "video information is not found" unless $res->{value};
    $self->{swf} = $res->{value};
    $self->{swf} =~ m/&video=(.*?)&/;
    $self->{api_url} = uri_unescape($1);
}

sub _get_info {
    my $self    = shift;
    my $api_url = $self->{api_url}
      || "http://www.yourfilehost.com/video-embed.php?vidlink=&cid="
      . $self->{id};
    my $ua  = $self->{ua}; #LWP::UserAgent->new();
    my $res = $ua->get($api_url);
    croak "can't get yourfilehost page" unless $res->is_success;
    my $query = CGI->new( $res->content );
    $self->{_query} = $query;
}

sub photo {
    my $self = shift;
    return $self->{_query}->param("photo");
}

sub video_id {
    my $self = shift;
    return $self->{_query}->param("video_id");
}

sub embed {
    my $self = shift;
    return $self->{_query}->param("embed");
}

sub id {
    my $self = shift;
    my $id;
    $id = $1 if $self->{_query}->param("photo") =~ m!.*/(.*?).jpg!;
    return $id;
}

sub swf {
    my $self = shift;
    return $self->{swf};
}

1;

__END__

=head1 NAME

WWW::YourFileHost - Get video informations from YourFileHost

=head1 SYNOPSIS

    use LWP::UserAgent;
    use WWW::YourFileHost;
    use Perl6::Say;

    my $url = "http://www.yourfilehost.com/media.php?cat=video&file=hoge.wmv";
    my $ua  = LWP::UserAgent->new( agent => "WWW::YourFileHost" );
    $ua->cookie_jar( HTTP::Cookies->new );
    my $yourfilehost = WWW::YourFileHost->new( url => $url , ua => $ua );
    say $yourfilehost->photo;
    say $yourfilehost->video_id;
    say $yourfilehost->embed;


=head1 AUTHOR

Yusuke Wada  C<< <yusuke@kamawada.com> >>

=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
