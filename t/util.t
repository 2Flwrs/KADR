#!/usr/bin/env perl

use common::sense;
use FindBin;
use Test::More tests => 21;

use lib "$FindBin::RealBin/../lib";
use App::KADR::Util qw(:pathname_filter shortest strip_import_params short_lang);

is pathname_filter('/?"<>|:*!\\'), '∕?"<>|:*!\\', 'unix pathname filter';
is pathname_filter_windows('/?"<>|:*!\\'), '∕？”⟨⟩❘∶＊!⧵', 'windows pathname filter';

is shortest(qw(ab c)), 'c', 'shortest argument returned';
is shortest(qw(a b c)), 'a', 'argument order preserved';
is shortest(undef), undef, 'undef returns safely';
is shortest(qw(a b), undef), undef, 'undef is shortest';

ok !defined shortest(), 'undefined if no args';
is shortest('a'), 'a', 'one arg okay';

{
	my $args = [1, '-foo', 'a', '-bar', 'b', {}];
	my $param = strip_import_params($args, 'bar');
	is_deeply $param, {bar => 'b'},
		'strip_import_params should remove correct argument';
	is_deeply $args, [1, '-foo', 'a', {}],
		'strip_import_params should ignore unknown args';

	$param = strip_import_params($args, 'baz');
	is_deeply $param, undef,
		'strip_import_params should return undef';
	is_deeply $args, [1, '-foo', 'a', {}],
		'strip_import_params should ignore unknown args';
}


is short_lang("english"), "eng", "short_lang - simple case";
is short_lang("english'swedish"), "eng+", "short_lang - two";
is short_lang("english",
              prefered=>{"english" => "E"}),
    "E", "short_lang - pref, simple case";
is short_lang("english'swedish",
              prefered=>{"english" => "E"}),
    "E+", "short_lang - pref, extra";
is short_lang("english'swedish",
              prefered=>{"english" => "E", "swedish" => "S"}),
    "E,S", "short_lang - pref, two";
is short_lang("english'other'swedish",
              prefered=>{"english" => "E", "swedish" => "S"}),
    "E,S+", "short_lang - pref, two, extra";
is short_lang("english/other/swedish",
              prefered=>{"english" => "E", "swedish" => "S"},
              split => "/",
              join => ";",
              more => "*",
              min_res => 5,
              other_len=>2 ),
    "E;S;ot", "short_lang - all params 1";
is short_lang("english/other/japanese",
              prefered=>{"english" => "E", "swedish" => "S"},
              split => "/",
              join => ";",
              more => "*",
              min_res => 2,
              other_len=>2 ),
    "E;ot*", "short_lang - all params 2";
is short_lang("english/other/swedish",
              prefered=>{"english" => "E", "swedish" => "S"},
              split => "/",
              join => ";",
              more => "*",
              min_res => 1,
              other_len=>2 ),
    "E;S*", "short_lang - all params 3";
