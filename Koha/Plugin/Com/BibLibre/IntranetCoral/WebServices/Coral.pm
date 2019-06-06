package Koha::Plugin::Com::BibLibre::IntranetCoral::WebServices::Coral;
use C4::Context;
use Modern::Perl;
use HTTP::Request::Common;
use Data::Dumper;
use LWP::UserAgent;
use JSON;

use constant URL => C4::Context->preference('CoralURL') . "resources/api/";

sub getResource {
    my $identifier = shift;
    return unless $identifier;
    return _doGet("resources/?identifier=$identifier");
}

sub getLicenses {
    my $resourceID = shift;
    return unless $resourceID;
    return _doGet("resources/$resourceID/licenses");
}

sub getPackages {
    my $resourceID = shift;
    return unless $resourceID;
    return _doGet("resources/$resourceID/packages");
}

sub getTitles {
    my $resourceID = shift;
    return unless $resourceID;
    return _doGet("resources/$resourceID/titles");
}


sub _doGet {
   my $query = shift;
   my $request = HTTP::Request->new(
        GET => URL . $query,
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
