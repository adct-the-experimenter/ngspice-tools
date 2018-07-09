package MosfetModel;
 
use warnings;
use strict;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub setName 
{
    my ( $self, $name ) = @_;
    $self->{_name} = $name if defined($name);
    return $self->{_name};
}
 
sub getName 
{
    my( $self ) = @_;
    return $self->{_name};
}

sub setType 
{
    my ( $self, $type ) = @_;
    $self->{_type} = $type if defined($type);
    return $self->{_type};
}
 
sub getType 
{
    my( $self ) = @_;
    return $self->{_type};
}

sub setThresholdVoltage 
{
    my ( $self, $vt ) = @_;
    $self->{_vt} = $vt if defined($vt);
    return $self->{_vt};
}
 
sub getThresholdVoltage
{
    my( $self ) = @_;
    return $self->{_vt};
}

1;
