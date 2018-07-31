use Cro::OpenAPI::RoutesFromDefinition;
use Cro::HTTP::Router;

class App::Zef::WebAPI {
    has @.models;

    method application {
        openapi %?RESOURCES<openapi.json>.IO, {
            operation 'available', -> {
                my @dists = @!models.map(*.available.Slip).grep(*.defined);

                my %response = %( total => +@dists, data => @dists );
                content 'application/json', %response;
            }

            operation 'candidates', -> {
                request-body -> (*%_) {
                    my @dists = @!models.map(*.candidates(|%_).Slip).grep(*.defined);

                    my %response = %( total => +@dists, data => @dists );
                    content 'application/json', %response;
                }
            }

            operation 'install', -> {
                request-body -> (*%_) {
                    my @dists = @!models.grep(*.^can('install')).map(*.install(:meta(%_)).Slip).grep(*.defined);

                    my %response = %( total => +@dists, data => @dists );
                    content 'application/json', %response;
                }
            }
        }
    }
}