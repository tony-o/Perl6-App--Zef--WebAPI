use v6;
use App::Zef::WebAPI;
use App::Zef::WebAPI::Model::CURI;

use Test;
plan 1;


subtest 'basic' => {
	my $model = App::Zef::WebAPI::Model::CURI.new;
	ok $model.available.first({ .<name> eq 'CORE' }), 'Found core distribution modules';
	ok $model.candidates(:name<Cro::OpenAPI::RoutesFromDefinition>).elems, 'Found a matching candidate for one of our dependencies';
}


done-testing;
