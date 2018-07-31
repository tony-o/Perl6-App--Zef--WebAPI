use v6;
use App::Zef::WebAPI;
use App::Zef::WebAPI::Model::DB;

use Cro::HTTP::Test;


test-service App::Zef::WebAPI.new(models => [App::Zef::WebAPI::Model::DB.new]).application(), {
    test get('/available'),
        status => 200,
        content-type => 'application/json',
        #json => { :total(0), :data([]) },
    ;

    test-given '/candidates', {
        test post(json => { :name<DoesNotExists>, }),
            status => 200,
            #json => { :total(0), :data([]) },
        ;

        test post(json => { :name<Foo>, :version<1.2.0>, :auth<github:ugexe> }),
            status => 200,
            #json => { :total(1), :data([{ :name<Cro::OpenAPI::RoutesFromDefinition> }]) }
        ;
    }
}