# bnbgui
GUI for bnbTP

To do:
- consolidating...
- select channels to register
- default values for filenames
- check data folder when asking for a reference image
- use data from sonas, where imaging is firstly being saved
- add consolidate option
- add 10 seconds pause into consolidate
- add handling of ssh connecting errors

to compile in bnb
mcc -m bnb_register.m -a ./si_functions
mcc -m bnb_extract.m -a ./si_functions


Opentiff problem:

There was an update in the format of the imaging data from SI and a consequent update of the function opentif, so now some datasets correspond to the old and other to the new version. 

I changed functions bnb_register and bnb_extrac to manage both datasets by trying first as new and if it doesn't work then trying the old function (this is in function myOpenTif). This should be working, but is not very elegant. 

Functions:

Regstration: 
	input: tiff files, channel to register against, reference image
	output: registration file (prefix_reg.mat)

There are two methods: 

(1) Reference Image and (2) Recursive


Extraction:
	input: roi data, registration data, tif files
	output: fluorescence traces

Z stacks:





