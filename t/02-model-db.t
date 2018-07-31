use v6;
use App::Zef::WebAPI::Model::DB;

use Test;
plan 1;

todo 'App::Zef::WebAPI::Model::DB functionality NYI';
ok App::Zef::WebAPI::Model::DB.available.first({ .<name> eq 'CORE' }), 'Found core distribution modules';

done-testing;
