#!/usr/bin/env perl 
package Mosfet;

use 5.010000; # use version 5.10
use warnings;
use strict;
use Mosfet; #to use class Mosfet
use Getopt::Long qw(GetOptions);



#Program reads a file for names of MOSFETs 
#These names will be used to find numerical data from results.txt
#for these voltages in circuit.
#Then the numerical data will be used to calculate overdrive voltage, gm, and 
#saturation condition of transistors.  

#*****************************************************
#***** Get Needed File Paths & Display Options *******
#*****************************************************
my $filename_MOS;
my $filename_spice_results;

#filepaths needed to extract MOSFET info
my $mos_read_file_address;
my $spice_results_file_address;

#display options
my $display_type; #bool to display type
my $display_id; #bool to display id
my $display_vgs; #bool to display vgs
my $display_vds; #bool to display vds
my $display_vt; #bool to display vt
my $display_gm; #bool to display gm
my $display_vdsat; #bool to display vdsat 
my $display_sat; #bool to display saturation
GetOptions(
	'sat' => \$display_sat,
	'type' => \$display_type,
	'id' => \$display_id,
	'vgs' => \$display_vgs,
	'vds' => \$display_vds,
	'vt' => \$display_vt,
	'gm' => \$display_gm,
	'vdsat' => \$display_vdsat,
    'mos_file=s' => \$mos_read_file_address,
    'spice_results_file=s' => \$spice_results_file_address,
) or die "Usage: $0 --mos_file  --results_file NAME\n";
 
if ($mos_read_file_address) 
{
	$filename_MOS = $mos_read_file_address;
}

die "missing --mos_file filename" unless ($mos_read_file_address); 

if ($spice_results_file_address) 
{
	$filename_spice_results = $spice_results_file_address;
}

die "missing --spice_results_file filename" unless ($spice_results_file_address);

#***********************************
#***** Open MOSFETS-To-Read.txt ****
#***********************************

#open file, stop program and raise exception if cannot open file
#open(FILEHANDLE,MODE,EXPR) Opens the file whose filename is given by EXPR, and associates it with FILEHANDLE
open(my $filehandle_MOS, '<', $filename_MOS) or die "cannot open '$filename_MOS' $!";
#while loop reads each line until end of file reached 
#<$filehandle> means readline($filehandle)

#*********************************************
#***** Read data from MOSFETS-To-Read.txt ****
#*********************************************

#assign name, type, threshold voltage
#to array of MOSFET objects using get_MOS_data 
my @mosfets = get_MOS_Read_Info($filehandle_MOS);

#*********************************************
#***** Read data from results.txt ************
#*********************************************

#open file, stop program and raise exception if cannot open file
#open(FILEHANDLE,MODE,EXPR) Opens the file whose filename is given by EXPR, and associates it with FILEHANDLE
open(my $filehandle_Results, '<', $filename_spice_results) or die "cannot open '$filename_spice_results' $!";

#call subroutine to read data from results.txt to put intoo MOSFET objects
read_Results_For_MOS_data($filehandle_Results,@mosfets);

#*************************************************
#***** Determine if MOS in Saturation ************
#*************************************************

#Check if MOSFET objects are in saturation 
#based on vds and vgs and vtn collected from results.txt and MOSFETS-To-Read.txt
check_MOS_Saturation(@mosfets);

for(@mosfets)
{
	say $_->getName();
	if($display_type){say "\t type:",$_->getType()}
	if($display_id){say "\t id:",$_->getDrainCurrent()}
	if($display_vds){say "\t vds:",$_->getVoltageDrainToSource()}
	if($display_vgs){say "\t vgs:",$_->getVoltageGateToSource()}
	if($display_vt){say "\t vt:",$_->getThresholdVoltage()}
	if($display_sat){say "\t Saturation:",$_->getSaturationFlag();}
	if($display_gm){say "\t gm:",$_->getTransconductance_gm}
	if($display_vdsat){say "\t vdsat:",$_->getOverdriveVoltage()}
}

exit;

sub get_MOS_Read_Info
{
  my ($filehandle) = @_; #get inputs

  my @data;#array of data to return

  my $found_name = " "; #var to contain MOSFET name found
  my $found_type; #var to contain MOSFET type found
  my $found_vt; #var to contain MOSFET threshold
  
  #read each line
  while(my $line = <$filehandle>) 
  {
	
    chomp($line); #truncate possible trailing line  
    
    my $mos;
    
    #Find parameters for mosfet 
	
    #split into 2 pieces with :,one-or-more space act as divider
    #assign parameter and value according to split
    my $parameter; my $value;
    ($parameter, $value) = split(/: +/, $line, 2);
    
    #if parameter and value defined
    if($parameter && $value)
    {
		#say "$parameter is parameter. $value is value \n";
		
		#if parameter is MOSFET-Name, and value is defined
		if($parameter =~ m/^MOSFET-Name/ && $value) 
		{
		    $found_name = $value;
		}
		
		#if parameter is type, and value is defined
		if($parameter =~ m/type$/ && $value)
		{
			$found_type = $value;
			#if value is not N or P, raise exception and break loop
			die "malformed $line. Must be N(Negative) or P(Positive)." unless($value =~ m/N|P$/);
			die "MOSFET-Name parameter needs to be defined before type." unless ($found_name);
		}
		
		#if parameter is vt, and value is defined
		if($parameter =~ m/vt$/ && $value)
		{
			$found_vt = $value;
			
			die "malformed $line. Value must be a real number with or without e exponent notation.\n" unless($value =~ m/^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/);
			die "type parameter needs to be defined before vt." unless ($found_type);
			
			#since last expected parameter
			#create new mosfet and initialize values
			$mos = Mosfet->new;
			$mos->setName($found_name);
			$mos->setType($found_type);
			$mos->setThresholdVoltage($found_vt);
			
			push (@data,$mos);
		}
	}
	
  }
  
  #stop program if data array is not defined
  #die "nothing read for MOSFETs." unless(@data);
  return(@data); #return data array
}

sub read_Results_For_MOS_data
{
	my ($filehandle,@mosfets) = @_; #get inputs
	
	my $parameter_line;
	my @stats;
	my $mosBlockFound=0; #var to indicate mos block found
	
	#use hash to store and match mosfet label 
	#and column index in stat
	my %hash;
	my $hash_count;
				
	#read each line
	while(my $line = <$filehandle>) 
	{
		chomp($line); #truncate possible trailing line  
		
		#split into as many pieces with :,one-or-more space act as divider
		#assign name and stats array according to split
		my ($parameter_line, @stats) = split(/( :)+/, $line);
		
		#if parameter_line is undefined, and mosBlockFound is 1
		if(!$parameter_line && $mosBlockFound == 1)
		{
			$mosBlockFound = 0; #set mos block found flag to off
		}
		if($parameter_line)
		{
			
			if($parameter_line =~ m/ Mos\d+: +/ )
			{
				#say "Found MOS block! \n";
				$mosBlockFound=1; #initialize mos block found var
			}
			
			#if mos block found
			if($mosBlockFound == 1)
			{
				#if in device line
				if($parameter_line =~ m/ +device/)
				{
					#say "$parameter_line found!\n";
					my $parameter;
					($parameter, @stats) = split(/ {11,20}/, $parameter_line);
										
					#index is 1 because a zero in if statement returns undefined for some reason.
					my $index = 1;
					
					#check which columns have which labels to read
					for(@stats)
					{
						my $this_stat = $_;
						#if element in stats 
						for(@mosfets)
						{
							my $mos = $_;
							
							#if stat element and mosfet name strings match
							if($this_stat eq $mos->getName())
							{	
								$hash{$mos->getName()} = $index;
							} 
						}
						
						$index = $index+1;#increment column index	
					}
					
					#say "$_: $hash{$_}" for(sort keys %hash);
				}
				
				$hash_count = keys %hash;
				
				#if in id line
				if($parameter_line =~ m/ +id/ && $hash_count >= 1)
				{	
					my $parameter;
					($parameter, @stats) = split(/ {10,18}/, $parameter_line);
					
					for(@mosfets)
					{
						#if its drain current is undefined
						if(!$_->getDrainCurrent())
						{
							#if its hash at name is defined
							if($hash{$_->getName()})
							{
								my $adjusted_index=$hash{$_->getName()}-1;#need this so that can access stats[0]
								$_->setDrainCurrent($stats[$adjusted_index]);
							}
						}
					}
				}
				
				#if in vgs line
				if($parameter_line =~ m/ +vgs/ && $hash_count >= 1)
				{	
					my $parameter;
					($parameter, @stats) = split(/ {10,18}/, $parameter_line);
					
					for(@mosfets)
					{
						#if its drain current is undefined
						if(!$_->getVoltageGateToSource())
						{
							#if its hash at name is defined
							if($hash{$_->getName()})
							{
								my $adjusted_index=$hash{$_->getName()}-1;#need this so that can access stats[0]
								$_->setVoltageGateToSource($stats[$adjusted_index]);
							}
						}
					}
				}
				
				#if in vds line
				if($parameter_line =~ m/ +vds/ && $hash_count >= 1)
				{	
					my $parameter;
					($parameter, @stats) = split(/ {10,18}/, $parameter_line);
					
					for(@mosfets)
					{
						#if its drain current is undefined
						if(!$_->getVoltageDrainToSource())
						{
							#if its hash at name is defined
							if($hash{$_->getName()})
							{
								my $adjusted_index=$hash{$_->getName()}-1;#need this so that can access stats[0]
								$_->setVoltageDrainToSource($stats[$adjusted_index]);
							}
						}
					}
				}
				
				#if in vdsat line
				if($parameter_line =~ m/ +vdsat/ && $hash_count >= 1)
				{
					my $parameter;
					($parameter, @stats) = split(/ {10,18}/, $parameter_line);
					
					for(@mosfets)
					{
						#if its overdrive voltage is undefined
						if(!$_->getOverdriveVoltage())
						{
							#if its hash at name is defined
							if($hash{$_->getName()})
							{
								my $adjusted_index=$hash{$_->getName()}-1;#need this so that can access stats[0]
								$_->setOverdriveVoltage($stats[$adjusted_index]);
							}
						}
					}
				}
				
				#if in gm line
				if($parameter_line =~ m/ +gm/ && $hash_count >= 1)
				{
					my $parameter;
					($parameter, @stats) = split(/ {10,18}/, $parameter_line);
					
					for(@mosfets)
					{
						#if its gm is undefined
						if(!$_->getTransconductance_gm())
						{
							#if its hash at name is defined
							if($hash{$_->getName()})
							{
								my $adjusted_index=$hash{$_->getName()}-1;#need this so that can access stats[0]
								$_->setTransconductance_gm($stats[$adjusted_index]);
							}
						}
					}
				}
			}
			
			#if resistor block found or 
			#independent voltage source block found
			# end reading
			last if($parameter_line =~ m/ Resistor: +/
					|| $parameter_line =~ m/ Vsource: +/)
			
		}
	}
}

sub check_MOS_Saturation
{
	my (@mosfets) = @_; #get inputs
	
	for(@mosfets)
	{
		my $sat1_flag=0;
		my $sat2_flag=0;
		
		#for n-channel mosfets
		if($_->getType() eq 'N')
		{
			#check if vds >= vgs-vt
			if($_->getVoltageDrainToSource() >= 
				$_->getVoltageGateToSource() - $_->getThresholdVoltage())
			{
				$sat1_flag=1;
			}
			
			#check if vgs >= vt
			if($_->getVoltageGateToSource() >= 
				$_->getThresholdVoltage())
			{
				$sat2_flag=1;
			}
			
			if($sat1_flag & $sat2_flag)
			{
				$_->setSaturationFlag('Yes');
			}
			else
			{
				$_->setSaturationFlag('No');
			}
		}
		
		#for p-channel mosfets
		if($_->getType() eq 'P')
		{
			#check if vsd >= vsg-vt
			if(-1*$_->getVoltageDrainToSource() >= 
				-1*$_->getVoltageGateToSource() - -1*$_->getThresholdVoltage())
			{
				$sat1_flag=1;
			}
			
			#check if vsg >= vt
			if(-1*$_->getVoltageGateToSource() >= 
				-1*$_->getThresholdVoltage())
			{
				$sat2_flag=1;
			}
			
			if($sat1_flag == 1 && $sat2_flag == 1)
			{
				$_->setSaturationFlag('Yes');
			}
			else
			{
				$_->setSaturationFlag('No');
			}
		}
	}
}
