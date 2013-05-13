package App::KADR::Util;
# ABSTRACT: Utility functions for KADR

use common::sense;
use List::AllUtils qw(firstidx reduce);
use Params::Util qw(_STRING);
use Params::Check qw[check];
use Sub::Exporter -setup => {
	exports => [qw(pathname_filter pathname_filter_windows shortest
		strip_import_params _STRINGLIKE0 short_lang)],
	groups => {
		pathname_filter => [qw(pathname_filter pathname_filter_windows)],
	}
};

sub pathname_filter {
	$_[0] =~ tr{/}{∕}r;
}

sub pathname_filter_windows {
	# All non-described replacements are double-width
	# versions of the original characters.
	# ∕ U+2215 DIVISION SLASH
	# ⧵ U+29F5 REVERSE SOLIDUS OPERATOR
	# ” U+201D RIGHT DOUBLE QUOTATION MARK
	# ⟨ U+27E8 MATHEMATICAL LEFT ANGLE BRACKET
	# ⟩ U+27E9 MATHEMATICAL RIGHT ANGLE BRACKET
	# ❘ U+2758 LIGHT VERTICAL BAR
	$_[0] =~ tr{/\\?"<>|:*}{∕⧵？”⟨⟩❘∶＊}r;
}

sub shortest(@) {
	reduce { length $b < length $a ? $b : $a } @_
}

sub strip_import_params {
	my $args = shift;
	my %param_names = map { $_ => 1 } @_;

	my $i;
	my $params;
	while (++$i < @$args) {
		local $_ = $args->[$i];
		next if ref $_;
		my $name = s/^-//r;
		next unless delete $param_names{$name};

		$params->{$name} = $args->[ $i + 1 ];
		splice @$args, $i, 2;
	}
	
	$params;
}

# XXX: From Moose::Util, replace with Params::Util version once it gets moved.
sub _STRINGLIKE0 ($) {
	_STRING($_[0])
	|| (blessed $_[0] && overload::Method($_[0], q{""}))
	|| (defined $_[0] && $_[0] eq '');
}

sub short_lang {
    # for shortening the {dub,sub}_language fields
    my $langs = shift;

    my $tmpl= {
        prefered => { default => {}, strict_type => 1 },
        split => { default => "'" },
        join => { default => "," },
        more => { default => "+" },
        none => { default => "?" },
    };

    my $args = check( $tmpl, {@_}, $Params::Check::VERBOSE) or die;

    my @langs = split $args->{split}, $langs;

    my @res_pref = ();
    my @res_other = ();

    for my $lang (@langs) {
        if (defined($args->{prefered}{$lang})) {
            push @res_pref, $args->{prefered}{$lang};
        } else {
            push @res_other, $lang;
        }
    }

    my $res;
    if (scalar @res_pref == 0) {
        if (scalar @res_other == 0) {
            $res = $args->{none};
        } else {
            my $main = shift(@res_other);
            $res = sprintf("%.3s", $main);
        }
    } else {
        $res = join $args->{join}, @res_pref;
    }

    if (scalar @res_other > 0) {
        $res = $res . $args->{more};
    }

    return $res;
}


1;
