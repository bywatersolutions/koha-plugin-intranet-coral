package Koha::Plugin::Com::BibLibre::IntranetCoral::WebServices::Coral;
use C4::Context;
use Modern::Perl;
use HTTP::Request::Common;
use Data::Dumper;
use LWP::UserAgent;
use JSON;

sub getResource {
    my $identifier = shift;
    return unless $identifier;
    my $url = shift;
    return _doGet("resources/?identifier=$identifier", $url);
}

sub getLicenses {
    my $resourceID = shift;
    return unless $resourceID;
    my $url = shift;
    return _doGet("resources/$resourceID/licenses", $url);
}

sub getPackages {
    my $resourceID = shift;
    return unless $resourceID;
    my $url = shift;
    return _doGet("resources/$resourceID/packages", $url);
}

sub getTitles {
    my $resourceID = shift;
    return unless $resourceID;
    my $url = shift;
    return _doGet("resources/$resourceID/titles", $url);
}


sub _doGet {
   my $query = shift;
   my $url = shift;
   my $request = HTTP::Request->new(
        GET => $url . $query,
        HTTP::Headers->new("Accept" => "application/json"),   
                            );
    my $ua = LWP::UserAgent->new;
    my $response = $ua->request($request);
    if ($response->is_success) {
        #print $response->decoded_content;
        return decode_json($response->decoded_content);
    }
    return -1;

}
return 1;
