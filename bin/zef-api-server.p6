#!/usr/bin/env perl6
use App::Zef::WebAPI;
use App::Zef::WebAPI::Model::CURI;
use App::Zef::WebAPI::Model::DB;

use Cro::HTTP::Server;
use Cro::HTTP::Log::File;

sub MAIN(:$host = 'localhost', :$port = 3000) {
    my $api = App::Zef::WebAPI.new:
        models => [
            App::Zef::WebAPI::Model::CURI.new,
            App::Zef::WebAPI::Model::DB.new,
        ];

    my $server = Cro::HTTP::Server.new(
        host         => $host,
        port         => $port,
        body-parsers => [Cro::HTTP::BodyParser::JSON.new],
        application  => $api.application,
        after => [
            Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
        ],
    );

    $server.start;
    say "Listening at http://$host:$port";

    react {
        whenever signal(SIGINT) {
            $server.stop;
            exit;
        }
    }
}
