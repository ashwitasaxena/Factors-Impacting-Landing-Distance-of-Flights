/* Generated Code (IMPORT) */
/* Source File: FAA1.xls */
/* Source Path: /folders/myfolders/Statistical Computing */
/* Code generated on: 9/9/18, 4:15 PM */
libname project '/folders/myfolders/Statistical Computing';
FILENAME data1 '/folders/myfolders/Statistical Computing/FAA1.xls';

PROC IMPORT DATAFILE=data1 DBMS=XLS OUT=project.FAA1;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=project.FAA1;
RUN;

FILENAME data2 '/folders/myfolders/Statistical Computing/FAA2.xls';

PROC IMPORT DATAFILE=data2 DBMS=XLS OUT=project.FAA2;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=project.FAA2;
RUN;

/*merging data*/
data project.merge;
	set project.faa1 project.faa2;
run;

proc print data=project.merge;
run;

/*exploring the new dataset*/
proc means data=project.merge;
run;

/*removing duplicates from the data*/
proc sort data=project.merge out=project.remdup nodupkey;
	by distance speed_ground height pitch no_pasg aircraft speed_air;
run;

proc print data=project.remdup;
run;

Data project.remdup_new;
	Set project.remdup;

	IF no_pasg="." then
		delete;
RUN;

PROC PRINT Data=project.remdup_new;
	/*data exploration*/
proc contents data=project.remdup_new;
run;

PROC MEANS Data=project.remdup_new;
RUN;

proc freq data=project.remdup_new;
run;

/*data cleaning*/
data project.clean;
	set project.remdup_new;

	if aircraft='' then
		delete;

	if duration ne '' then
		if duration<40 then
			delete;

		if speed_ground < 30 then
			delete;

		if speed_ground > 140 then
			delete;

		if height < 6 then
			delete;

		if distance > 6000 then
			delete;
	run;

proc print data=project.clean;
	run;

proc means data=project.clean;
	run;

/*variable exploration*/
proc univariate data=project.clean;
		histogram;
	run;

proc sgplot data=PROJECT.CLEAN;
		vbox duration;
		yaxis grid;
	run;
proc sgplot data=project.clean;
		vbox pitch;
		yaxis grid;
	run;
proc sgplot data=project.clean;
		vbox speed_ground;
		yaxis grid;
	run;

proc sgplot data=project.clean;
		vbox height;
		yaxis grid;
	run;
proc sgplot data=project.clean;
		vbox distance;
		yaxis grid;
	run;
proc sgplot data=project.clean;
		vbox speed_air;
		yaxis grid;
	run;	
proc sgplot data=project.clean;
		vbox no_pasg;
		yaxis grid;
	run;
proc univariate data=project.clean;
run;

data project.final;
set project.clean;
 if duration>294 then delete;
 if pitch>5.4 then delete;
 if pitch<2.3 then delete;
 if speed_ground>130 then delete;
 if height>56 then delete;
 if distance<180 then delete;
 if distance>4737 then delete; /*based on 99 percentile - did not delete all outliers because we have missing data.*/
 if speed_air>125.5 then delete;
run;
 
proc means data=project.final;
run;

/*new boxplots*/

 proc sgplot data=PROJECT.final;
		vbox duration;
		yaxis grid;
	run;
proc sgplot data=project.final;
		vbox pitch;
		yaxis grid;
	run;
proc sgplot data=project.final;
		vbox speed_ground;
		yaxis grid;
	run;
proc sgplot data=project.final;
		vbox height;
		yaxis grid;
	run;
proc sgplot data=project.final;
		vbox distance;
		yaxis grid;
	run;
proc sgplot data=project.final;
		vbox speed_air;
		yaxis grid;
	run;
proc sgplot data=project.final;
		vbox no_pasg;
		yaxis grid;
	run;
proc univariate data=project.final;
run;
 
/*EDA*/
/*ttest for aircraft*/
proc ttest data=project.final;
class aircraft;
var distance;
run;

proc plot data=project.final;
plot distance*no_pasg;
run;
proc plot data=project.final;
plot distance*duration;
run;
proc plot data=project.final;
plot distance*speed_ground;
run;
proc plot data=project.final;
plot distance*speed_air;
run;
proc plot data=project.final;
plot distance*height;
run;
proc plot data=project.final;
plot distance*pitch;
run;
/* some correlation observed between distance and speed ground and distance and speed air*/

proc sgplot data=project.final;
   reg x=speed_air y=distance / nomarkers;
   title 'scatterplot';
   scatter x=speed_air y=distance;
run;
proc sgplot data=project.final;
   reg x=speed_ground y=distance / nomarkers;
   title 'scatterplot';
   scatter x=speed_ground y=distance;
run;

/*correlation analysis*/
proc corr data=project.final;
var distance pitch height speed_ground speed_air no_pasg duration;
run;


/* creating dummy variable for aircraft*/
data project.dummy;
set project.final;
if aircraft='airbus' then aircraft_dummy=1;
else aircraft_dummy=0;
run;


/*regression*/
proc reg data=project.dummy;
model distance= no_pasg duration speed_ground height pitch speed_air aircraft_dummy/*/r*/;
title 'Regression Model with all the variables';
/*output out=diagnostics r=residual*/;
run;

/*model without speed_air as it has many missing values*/
proc reg data=project.dummy;
model distance= no_pasg duration speed_ground height pitch aircraft_dummy;
title 'Model without speed_air';
run;

/*model without speed_air and duration*/
proc reg data=project.dummy;
model distance= no_pasg speed_ground height pitch aircraft_dummy;
title 'Model with no missing values(all variables but speed_air and duration)';
output out=diagnostics r=residual;
run;

/*model with no dummy*/
proc reg data=project.dummy;
model distance= speed_ground height pitch no_pasg;
title 'Model with speed_ground, height, pitch and No_pasg';
run;

/*logit model for dummy*/
proc logistic descending data=project.dummy;
model aircraft_dummy= distance speed_ground pitch height no_pasg / link=logit;
title 'logistic regression';
run;


/*	data project.cleandist;
		set project.clean;

		if distance<180 then
			delete;
	run;

	proc univariate data=project.cleandist;
		histogram;
		var distance;
	run;
	*/
	

