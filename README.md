# ngspice-tools
Collection of tools to use with ngspice. So far only 1 perl script available that reads MOSFET data(e.g. name,type,vds,vgs,gm,etc.) from 2 files.

# MOSFET Data Reader

The MOSFET Data Reader requires a text file that contains results from running ngspice -b some_circuit.cir
and a text file containing names of MOSFETs to be read.

Running MOSFET Data Reader from command line:
```
perl -I /home/user/source_builds/ngspice-tools /home/user/source_builds/ngspice-tools/read_MOSFET_data.pl \
--sat --type --id --vgs --vds --vt --gm --vdsat \
--mos_file mos_read_file.txt \
--spice_results_file  spice_results_file.txt
```

Options
*  --mos_file specifies the path to text file that provides which names of MOSFETs from which to get data. Mandatory.
*  --spice_results_file the path to text file that contains results of ngspice simulation. Mandatory.
*  --sat option tells MOSFET reader to display whether MOSFET is saturated or not. 
*  --type option tells MOSFET reader to display MOSFET channel type(positive or negative).
*  --id option tells MOSFET reader to display MOSFET drain current.
*  --vgs option tells MOSFET reader to display MOSFET gate-to-source voltage.
*  --vds option tells MOSFET reader to display MOSFET drain-to-source voltage.
*  --vt option tells MOSFET reader to display MOSFET threshold voltage.
*  --gm option tells MOSFET reader to display MOSFET transconductance gm.
*  --vdsat option tells MOSFET reader to display MOSFET overdrive voltage vdsat.

Text file providing names of MOSFETs to read.
## MOSFETs-To-Read.txt
```
*Put all names in lower case letters since spice reads
*it that way.
 
MOSFET-Name: mq2
	type: N
	vt: 1
	
MOSFET-Name: mq3
	type: N
	vt: 1

MOSFET-Name: mq4
	type: P
	vt: -2
```

An example script to perform ngspice simulation, get results in text file, and read MOSFET data from ngspice simulation
results text file.
## ngspice-sim.sh
```
#!/bin/sh

#saves results to text file results.txt
ngspice -b some_circuit.cir > results.txt  

#saves results in output file that ngnutmeg can read and plot
ngspice -b some_circuit.cir -r output.raw 

#read and output to console saturation and type info on certain MOSFETs
perl -I /home/user/source_builds/ngspice-tools /home/user/source_builds/ngspice-tools/read_MOSFET_data.pl \
--sat --type \
--mos_file /home/user/Circuits/Some-Circuit/MOSFETS-To-Read.txt \
--spice_results_file  /home/user/Circuits/Some-Circuit/results.txt
```
