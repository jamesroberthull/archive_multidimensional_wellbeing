********************************************************************************************************;
**  Program Name: /home/jhull/nangrong/prog_sas/p03_gom/p03_00_d.sas
**  Programmer: james r. hull
**  Start Date: 2011 February 21
**  Purpose:
**   1.) Create a dataset that is properly formatted for GoM modeling
**
**  Input Data:
**   '/home/jhull/nangrong/data_sas/2000/current/hh00.xpt'
**   '/home/jhull/nangrong/data_sas/2000/current/indiv00.xpt'
**   '/home/jhull/nangrong/data_sas/2000/current/comm00.xpt'
**   '/home/jhull/nangrong/data_sas/2000/current/plots00.xpt'
**  Output Data:
**   '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_d.xpt'
**
**  Notes:
**   1.) This file creates all variables with the prefix "d"
********************************************************************************************************;

*******************************************
**  Options and General Macro Variables  **
*******************************************;

options nocenter linesize=80 pagesize=60;

%let y=00; 

**********************
**  Data Libraries  **
**********************;

libname in&y.01 xport '/home/jhull/nangrong/data_sas/2000/current/indiv00.xpt';
libname in&y.02 xport '/home/jhull/nangrong/data_sas/2000/current/hh00.xpt';
libname in&y.03 xport '/home/jhull/nangrong/data_sas/2000/current/comm00.xpt';
libname in&y.04 xport '/home/jhull/nangrong/data_sas/1994/current/comm94.xpt';
libname in&y.05 xport '/home/jhull/nangrong/data_sas/2000/current/plots00.xpt';

libname in&y.06 xport '/home/jhull/nangrong/data_sas/id_sets/current/hh00v84.xpt';

libname ot&y.01 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_d.xpt';


*******************************************************************************************************;
** c13:  **;

%let f=c13;  ** update with each new variable **;

data w&f.01 (keep=hhid00 N7f c&f);
     set in&y.02.hh00 (keep= hhid00 window:);

     if (window3=1 and window4=2 and window5=2 and window6=2) then n&f=1;
          else if (window4=1 or window5=1 or window6=1) then n&f=2;
          else if (window1 in (9,.) or window2 in (9,.) or
                   window3 in (9,.) or window4 in (9,.) or 
                   window5 in (9,.) or window6 in (9,.) or 
                   window7 in (9,.)) then n&f=.;
	   else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: type of windows in house"
           c&f="cat: type of windows in house";    
run;     

** Coding for Categorical Variable: 0=windows: none
                                    1=windows: wood panes only
                                    2=windows: glass panes or screens **;   


*******************************************************************************************************;

** INSERT BIG MERGE **;
** Create FILE: libname ot&y.01 xport '/home/jhull/nangrong/data_sas/p01_rice/current/p03_00_c.xpt'; **;
