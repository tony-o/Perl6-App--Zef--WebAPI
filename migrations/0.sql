create table if not exists distributions (
    id          SERIAL         NOT NULL PRIMARY KEY,
    name        varchar( 255 ) NOT NULL,
    version     varchar( 255 ),
    auth        varchar( 255 ),
    api         varchar( 255 ),
    meta        jsonb          NOT NULL
);

insert into distributions (name,auth,api,version,meta) values ('Foo','github:ugexe','1','1.2.0','{ "perl" : "6.*", "name" : "Foo", "version" : "1.2.0", "auth" : "github:ugexe", "description" : "Test for installation of same named dists", "depends" : [], "provides" : { "Foo" : "lib/Foo.pm6" },"source-url" : "git://github.com/ugexe/Perl6-Foo.git"}');
	