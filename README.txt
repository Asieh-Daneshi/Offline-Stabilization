This version works ONLY with Matlab2014b or higher				
				
For Bonn AOSLO Data use				
stabilizefromraw_multiple_ND_13_03_2019.m				
	added: 			
		#NAME?		
		- Clean up after looping through videos (script writes huge and mostly unnecessary .mat files)		
				
If too many frames are skipped during offline stabilzation or your sumframes are getting too smudy try the following				
	"- badsamplethreshold = _?_?_?_;  "		0.6	"High value=more strips included; keep above 0.6 and below 0.9"
	- analyse_inputstruct = ...			
		'badstripthreshold',_?_?_?_	0.66	"High value=more strips included; keep above 0.6 and below 0.9"
		'minpercentofgoodstripsperframe',_?_?_?_	0.4	Low values=more frames included
