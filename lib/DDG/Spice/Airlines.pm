package DDG::Spice::Airlines;

use DDG::Spice;
use Data::Dumper;

spice to => 'http://www.duckduckgo.com/flights.js?airline=$1&flightno=$2';
spice from => '(.*?)/(.*)';

triggers query_lc => qr/^(\d+)\s*(.*?)(?:[ ]air.*|)$/i;

handle query_lc => sub {
    #block words unless they're the first word and only if separated by space (excludes TAP-Air)
    # grammar - apostrophes specifically: 'chuck's regional charter'
    # air, express, airlines, airways, aviation, regional, service, cargo, transport, aircraft, ventures, charter, international, world 
    my %airlines = ();
    open(IN, "</usr/local/ddg/sources/flightstats/airlines.txt");
    while (my $line = <IN>) {
      chomp($line);
      my @line = split(/,/, $line);

      $line[1] =~ s/\s+air.*$//i;
      $airlines{lc $line[1]} = $line[0]; #American (Airlines <- regex removed) => AA
      $airlines{lc $line[0]} = $line[0]; #AA => AA
    }
    close(IN);

    if(exists $airlines{$2}) {
        my $airline = $airlines{$2};
        my $flightno = $1;
        return $airline, $flightno;
    }
    return;
};

1;