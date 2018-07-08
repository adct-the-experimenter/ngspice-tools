package Mosfet;
 
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

sub setOverdriveVoltage 
{
    my ( $self, $vdsat ) = @_;
    $self->{_vdsat} = $vdsat if defined($vdsat);
    return $self->{_vdsat};
}
 
sub getOverdriveVoltage
{
    my( $self ) = @_;
    return $self->{_vdsat};
}

sub setTransconductance_gm 
{
    my ( $self, $gm ) = @_;
    $self->{_gm} = $gm if defined($gm);
    return $self->{_gm};
}
 
sub getTransconductance_gm 
{
    my( $self ) = @_;
    return $self->{_gm};
}

sub setDrainCurrent 
{
    my ( $self, $id ) = @_;
    $self->{_id} = $id if defined($id);
    return $self->{_id};
}
 
sub getDrainCurrent 
{
    my( $self ) = @_;
    return $self->{_id};
}

sub setVoltageGateToSource
{
	my ( $self, $vgs ) = @_;
    $self->{_vgs} = $vgs if defined($vgs);
    return $self->{_vgs};
}

sub getVoltageGateToSource
{
	my( $self ) = @_;
    return $self->{_vgs};
}

sub setVoltageDrainToSource
{
	my ( $self, $vds ) = @_;
    $self->{_vds} = $vds if defined($vds);
    return $self->{_vds};
}

sub getVoltageDrainToSource
{
	my( $self ) = @_;
    return $self->{_vds};
}

#only set to 1 or 0
sub setSaturationFlag
{
	my ( $self, $sat ) = @_;
    $self->{_sat} = $sat if defined($sat);
    return $self->{_sat};
}

#only check for 1 or 0
sub getSaturationFlag
{
	my( $self ) = @_;
    return $self->{_sat};
}

1;

