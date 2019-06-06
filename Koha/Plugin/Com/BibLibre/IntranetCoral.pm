package Koha::Plugin::Com::BibLibre::IntranetCoral;
use Koha::Plugin::Com::BibLibre::IntranetCoral::WebServices::Coral;
use base qw(Koha::Plugins::Base);
use C4::Biblio;
use Data::Dumper;

our $VERSION = "0.1";

our $metadata = {
    name            => 'Intranet Coral Plugin',
    author          => 'Matthias Meusburger',
    date_authored   => '2019-06-05',
    date_updated    => "2019-06-05",
    minimum_version => '19.05.00.000',
    maximum_version => undef,
    version         => $VERSION,
    description     => 'This plugin displays informations from CORAL ERM in intranet biblio details'
};

sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    $self->{cgi} = CGI->new();

    return $self;
}

sub intranet_catalog_biblio_tab {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};
    my $biblionumber = $cgi->param('biblionumber');
    return unless $biblionumber;

    my $coralURL = $self->retrieve_data('coralURL');
    return unless $coralURL;
    $coralURL .= "/resources/api/";

    my $record = GetMarcBiblio({ biblionumber => $biblionumber });

    return unless $record;

    my $marcflavour  = C4::Context->preference("marcflavour");

    my $marcisbnsarray   = GetMarcISBN( $record, $marcflavour );

    my @tabs;
    my $tab = {};

    my $template = $self->get_template({ file => 'intranet-coral.tt' });

    # Coral resource info
    if (@$marcisbnsarray) {
        my $coralResources = Koha::Plugin::Com::BibLibre::IntranetCoral::WebServices::Coral::getResource(@$marcisbnsarray[0], $coralURL);
        my $coralResource;
        my $coralLicences;
        my $coralPackages;
        my $coralTitles;
        if ($coralResources != -1) {
            foreach (@$coralResources[0]) {
                $coralLicences = Koha::Plugin::Com::BibLibre::IntranetCoral::WebServices::Coral::getLicenses($_->{'resourceID'}, $coralURL);
                $coralTitles = Koha::Plugin::Com::BibLibre::IntranetCoral::WebServices::Coral::getTitles($_->{'resourceID'}, $coralURL);
                $coralPackages = Koha::Plugin::Com::BibLibre::IntranetCoral::WebServices::Coral::getPackages($_->{'resourceID'}, $coralURL);
                $coralResource = $_;
            }
        }
        if ($coralResource) {
            $template->param('coralResource' => $coralResource);
            $template->param('coralLicenses' => $coralLicences) if ($coralLicences);
            $template->param('coralPackages' => $coralPackages) if ($coralPackages);
            $template->param('coralTitles' => $coralTitles) if ($coralTitles);
        }
    }


    $tab->{'content'} = $template->output();
    $tab->{'title'} = "Coral";

    push @tabs, $tab;
    return @tabs;
}

sub configure {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    unless ( $cgi->param('save') ) {
        my $template = $self->get_template({ file => 'configure.tt' });

        ## Grab the values we already have for our settings, if any exist
        $template->param(
            coralURL => $self->retrieve_data('coralURL'),
        );

        $self->output_html( $template->output() );
    }
    else {
        $self->store_data(
            {
                coralURL => $cgi->param('coralURL'),
            }
        );
        $self->go_home();
    }
}
