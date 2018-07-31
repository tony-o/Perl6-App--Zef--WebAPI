class App::Zef::WebAPI::Model::CURI {
    # return all available dist meta data
    method available {
        my @available = $*REPO.repo-chain\
            .grep({ $_ ~~ CompUnit::Repository::Installable })\
            .map({ $_.installed.grep(*.defined).map(*.meta.hash).Slip })\
            .grep({ $_.defined });

        return @available;
    }

    method candidates(:$name, :$auth, :$api, :ver(:$version)) {
        my &find-candidates := -> $cur, $cu-spec {
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

            my $matching-dists := $cur.installed.grep(*.defined).grep: {
                my @names = (.meta<name>, .meta<provides>.keys.Slip).unique;
                my @files = (.meta<provides>.values.map(*.&parse-value).Slip, .meta<files>.hash.keys.Slip);
                my &name-matcher := { (@names.Slip, @files.Slip).first(*.starts-with($^a)) }

                so &name-matcher($cu-spec.short-name)
                    and ($_.meta<auth> // '') ~~ $cu-spec.auth-matcher
                    and Version.new($_.meta<version> // 0) ~~ $version-matcher
                    and Version.new($_.meta<api> // 0) ~~ $api-matcher
            }

            $matching-dists.list;
        }

        my $cur-spec = CompUnit::DependencySpecification.new(
            short-name      => $name,
            auth-matcher    => $auth    // True,
            api-matcher     => $api     // True,
            version-matcher => $version // True,
        );

        my @candidates =
            grep { .value.values },
            map  { $_.name => find-candidates($_, $cur-spec).map(*.meta.hash).cache },
            grep { $_ ~~ CompUnit::Repository::Installable },
            $*REPO.repo-chain;

        return @candidates;
    }
}