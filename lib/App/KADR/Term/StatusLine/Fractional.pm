package App::KADR::Term::StatusLine::Fractional;
use v5.10;
use Method::Signatures;
use Moose;
use MooseX::Types -declare => [ qw(Format) ];
use MooseX::Types::Moose qw(ArrayRef CodeRef Int ScalarRef Str);
use MooseX::Types::Stringlike qw(Stringable);

with 'App::KADR::Term::StatusLine';

my %formats = (
	fraction => \&format_as_fraction,
	percent => \&format_as_percent,
	'x/x' => \&format_as_fraction,
);

subtype Format,
	as CodeRef;

coerce Format,
	from Str,
	via {
		my $format = $_;
		$formats{$format} or method { sprintf($format, $self->get_current, $self->get_max) }
	};

has 'current',
	default => 0,
	is => 'rw',
	isa => Int|ArrayRef|ScalarRef|CodeRef;

has 'format',
	coerce => 1,
	default => 'fraction',
	is => 'rw',
	isa => Format;

has 'max',
	is => 'rw',
	isa => Int|ArrayRef|ScalarRef|CodeRef,
	required => 1;

has 'update_label',
	is => 'rw',
	isa => Str|Stringable|CodeRef,
	predicate => 'has_update_label';

has 'update_label_separator',
	default => ' ',
	is => 'rw',
	isa => 'Str';

{
	my $meta = __PACKAGE__->meta;

	for my $attr (qw(current max update_label)) {
		$meta->add_method('get_' . $attr => sub {
			my $value = $_[0]->$attr;
			  ref $value eq 'SCALAR' ? $$value
			: ref $value eq 'ARRAY'  ? scalar @$value
			: ref $value eq 'CODE'   ? $value->()
			:                          $value;
		});
	}
}

method _to_text {
	my $text = $self->format->($self);
	$text .= $self->update_label_separator . $self->get_update_label if $self->has_update_label;
	$text
}

sub incr {
	my ($self, $by) = @_;
	$self->current($self->get_current + ($by // 1));
	$self;
}

method format_as_fraction {
	sprintf('%d/%d', $self->get_current, $self->get_max)
}

method format_as_percent {
	sprintf('%.0f%%', $self->get_current / $self->get_max * 100);
}

method update($update_label?) {
	if(defined $update_label) {
		$self->update_label($update_label);
	}
	$self->update_term;
}

__PACKAGE__->meta->make_immutable;
