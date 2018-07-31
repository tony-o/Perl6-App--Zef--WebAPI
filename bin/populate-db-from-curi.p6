#!/usr/bin/env perl6
use Cro::HTTP::Client;

#| Populate the DB model using the CURI model indirectly via the api
sub MAIN(:$host = 'localhost', :$port = 3000) {
    my $available = await Cro::HTTP::Client.get("http://$host:$port/available");
    my $dists     = await $available.body;

    for $dists<data>.list -> $dist {
        my $installed = await Cro::HTTP::Client.post("http://$host:$port/install", content-type => 'application/json', body => $dist.hash);
        note "Installed {.<name>}" with await $installed.body;
    }
}
