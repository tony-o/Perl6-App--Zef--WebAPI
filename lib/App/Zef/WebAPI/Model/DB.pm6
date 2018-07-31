use DB::Pg;

class App::Zef::WebAPI::Model::DB {
    # return all available dist meta data
    method available {
        my @available = self!pg.query('select * from distributions').hashes;
        return @available.map(*.<meta>);
    }

    method candidates(:$name, :$auth, :$api, :ver(:$version)) {
        my &find-candidates := -> @dists, $cu-spec {
            my $version-matcher = ($cu-spec.version-matcher ~~ Bool)
                ?? $cu-spec.version-matcher
                !! Version.new($cu-spec.version-matcher);
            my $api-matcher = ($cu-spec.api-matcher ~~ Bool)
                ?? $cu-spec.api-matcher
                !! Version.new($cu-spec.api-matcher);

            my sub parse-value($str-or-kv) {
                do given $str-or-kv {
                    when Str  { $_ }
                    when Hash { $_.keys[0] }
                    when Pair { $_.key     }
                }
            }

            my $matching-dists := @dists.grep(*.defined).grep: {
                my @names = (.<meta><name>, .<meta><provides>.keys.Slip).unique;
                my @files = (.<meta><provides>.values.map(*.&parse-value).Slip, .<meta><files>.hash.keys.Slip);
                my &name-matcher := { (@names.Slip, @files.Slip).first(*.starts-with($^a)) }

                so &name-matcher($cu-spec.short-name)
                    and ($_.<meta><auth> // '') ~~ $cu-spec.auth-matcher
                    and Version.new($_.<meta><version> // 0) ~~ $version-matcher
                    and Version.new($_.<meta><api> // 0) ~~ $api-matcher
            }

            $matching-dists.list;
        }

        my $cur-spec = CompUnit::DependencySpecification.new(
            short-name      => $name,
            auth-matcher    => $auth    // True,
            api-matcher     => $api     // True,
            version-matcher => $version // True,
        );

        my @dists = $auth
            ?? self!pg.query('select * from distributions where name = $1', $name).hashes
            !! self!pg.query('select * from distributions where name = $1 AND auth = $2', $name, $auth).hashes;

        my @candidates = find-candidates(@dists, $cur-spec).map(*.<meta>).cache;

        return @candidates;
    }

    method install(:$meta) {
        self!pg.query: 'insert into distributions (name, auth, api, version, meta) values ($1, $2, $3, $4, $5)',
            $meta<name>,
            $meta<auth>,
            $meta<api>,
            $meta<version>,
            $meta;
    }

    method !pg {
        state $pg = DB::Pg.new:
            converters => <DateTime JSON>,
            conninfo   => join " ",
                ("dbname=$_" with %*ENV<DB_NAME>),
                ("host=$_" with %*ENV<DB_HOST>),
                ("user=$_" with %*ENV<DB_USER>),
                ("password=$_" with %*ENV<DB_PASSWORD>)
            ;
    }
}