package WWW::YourFileHost;

use warnings;
use strict;
use Carp;
use URI;
use Web::Scraper;
use URI::Escape;
use LWP::UserAgent;
use CGI;

our $VERSION = '0.02';

sub new {
    my ( $class, %opt ) = @_;
    my $self = bless {%opt}, $class;
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

    my $res = $s->scrape( URI->new($url) );
    croak "video information is not found" unless $res->{value};
    $res->{value} =~ m/&video=(.*?)&/;
    $self->{api_url} = uri_unescape($1);
}

sub _get_info {
    my $self    = shift;
    my $api_url = $self->{api_url}
      || "http://www.yourfilehost.com/video-embed.php?vidlink=&cid="
      . $self->{id};
    my $ua  = LWP::UserAgent->new();
    my $res = $ua->get($api_url);
    croak "" unless $res->is_success;
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

1;

__END__

=head1 NAME

WWW::YourFileHost - Get video informations from YourFileHost

=head1 SYNOPSIS

    use WWW::YourFileHost;

    my $url = 
      "http://www.yourfilehost.com/media.php?cat=video&file=hoge.wmv";
    my $yourfilehost = WWW::YourFileHost->new( url => $url );
      # or my $yourfilehost = WWW::YourFileHost->new( id => $id );
    print $yourfilehost->photo . "\n";
    print $yourfilehost->video_id . "\n";
    print $yourfilehost->embed . "\n";


=head1 AUTHOR

Yusuke Wada  C<< <yusuke@kamawada.com> >>

=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut