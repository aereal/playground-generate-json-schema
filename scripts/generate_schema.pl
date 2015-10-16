#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw(read_file);
use JSON::TypeInference::Type::Null;
use JSON::TypeInference;
use JSON::XS;

my $JSON = JSON::XS->new->pretty(1)->indent(1)->canonical(1);

my $dataset = [ map { $JSON->decode($_) } map { scalar read_file($_) } @ARGV ];

# (JSON::TypeInference::Type, [Any])
sub _array_property_descriptor {
  my ($array_type, $example_data) = @_;
  return +{
    type  => $array_type->name,
    items => _generate_property_descriptor($array_type->element_type, $example_data),
  };
}

# (JSON::TypeInference::Type, HashRef[Str, Any])
sub _object_property_descriptor {
  my ($object_type, $example_data) = @_;
  my $properties = $object_type->properties;
  return {
    type       => $object_type->name,
    properties => {
      map { ($_ => _property_descriptor($properties->{$_}, $example_data->{$_})) } keys %$properties,
    },
  };
}

# (JSON::TypeInference::Type, Any)
sub _atom_property_descriptor {
  my ($atom_type, $example_data) = @_;
  return +{
    type => ($atom_type->isa('JSON::TypeInference::Type::Maybe') ? [ map { $_->name } ($atom_type->type, 'JSON::TypeInference::Type::Null') ] : $atom_type->name),
    example => $example_data,
  };
}

sub _property_descriptor {
  my ($type, $example_data) = @_;
  if ($type->name eq 'array') {
    return _array_property_descriptor($type, $example_data);
  } elsif ($type->name eq 'object') {
    return _object_property_descriptor($type, $example_data);
  } elsif ($type->name eq 'union') {
    return _property_descriptor($type->types->[0], $example_data);
  } else {
    return _atom_property_descriptor($type, $example_data);
  }
}

sub generate_schema {
  my ($dataset) = @_;
  my $type = JSON::TypeInference->infer($dataset);
  my $example_data = $dataset->[0];
  return {
    '$schema'   => 'http://json-schema.org/draft-04/schema#',
    title       => 'TODO',
    description => 'TODO',
    %{_property_descriptor($type, $example_data)},
  };
}

my $schema = generate_schema($dataset);
print $JSON->encode($schema);
