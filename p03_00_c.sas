********************************************************************************************************;
**  Program Name: /home/jhull/nangrong/prog_sas/p03_gom/p03_00_c.sas
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
**   '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_c.xpt'
**
**  Notes:
**   1.) This file creates all variables with the prefix "c"
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

libname ot&y.01 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_c.xpt';


*******************************************************************************************************;
** c04: No one in HH can speak Central Thai **;

%let f=c04;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_7 x6_8_2);
     if x6_7=2 then n&f.ct=1;
        else if x6_7 ^in (9,.) then n&f.ct=0;
        else n&f.ct=.;
     if x6_8_2=1 then n&f.ct=1;
     if n&f.ct=1 then n&f=0;
        else if n&f.ct=0 then n&f=1;
        else n&f=.;
     c&f=n&f;
run;

data w&f.final;
     set w&f.01;
     label n&f="num: No one in HH can speak Central Thai"
           c&f="cat: No one in HH can speak Central Thai";     
run;     

** Coding for Categorical Variable: 0=No
                                    1=Yes **;   

*******************************************************************************************************;
** c10: housing quality  **;

%let f=c10;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 story space division);
     if story ^in (9,.) then n&f=0;
     if story in (2) then n&f=1;
     if space in (1) then n&f=2;
     if division in (1) then n&f=3;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="ord: Quality of Housing"
           c&f="ord: Quality of Housing";     
run;     

** Coding for Categorical Variable: 0=single story
                                    1=multistory
                                    2=multistory with space below
                                    3=multistory with enclosed space below  **;   

*******************************************************************************************************;
** c13: housing: window type **;

%let f=c13;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
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
** c23: housing: cooking fuel **;

%let f=c23;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_1_1 x6_1_2 x6_1_3 x6_1_4 x6_1_5);
     if (X6_1_1 in (9,.) or X6_1_2 in (9,.) or X6_1_3 in (9,.) or X6_1_4 in (9,.) or X6_1_5 in (9,.)) then n&f=.;
        else n&f=0;
     if x6_1_1=1 then n&f=1;
     if x6_1_2=1 then n&f=2;
     if x6_1_3=1 then n&f=3;
     if x6_1_4=1 then n&f=4;
     if x6_1_5=1 then n&f=4;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: type of cooking fuel used"
           c&f="ord: type of cooking fuel used";    
run;     

** Coding for Categorical Variable: 0=fuel: none
                                    1=fuel: wood only
                                    2=fuel: charcoal (& wood)
                                    3=fuel: gas (& charcoal & wood)
                                    4=fuel: electric (& gas & charcoal & wood) **;   

*******************************************************************************************************;
** c24: housing: secure title to home **;

%let f=c24;  ** update with each new variable **;

** First have to locate the info for the ~210 HHs who described house plang elsewhere (in plots00 data) **;

data w&f.01;
     set in&y.02.hh00 (keep=hhid00 x6_58 x6_58plg);
     if x6_58 in (1) then plang00b=x6_58plg;
        else plang00b=.;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

proc sort data=in&y.05.plots00 (keep=hhid00 plang00 x6_18_1 x6_19_:) out=w&f.03;
     by hhid00;
run;

data w&f.04;
     merge w&f.02 (in=a)
           w&f.03 (in=b);
     by hhid00;
     if b=1 then output;
run;

data w&f.05 (drop=plang00 plang00b x6_58plg x6_58
             rename=(x6_18_1=x6_60_1 x6_19_1=x6_61_1 x6_19_2=x6_61_2
                     x6_19_3=x6_61_3 x6_19_4=x6_61_4 x6_19_5=x6_61_5
                     x6_19_6=x6_61_6 x6_19_7=x6_61_7 x6_19_8=x6_61_8
                     x6_19_9=x6_61_9 x6_19_0=x6_61_0));
     set w&f.04;
     if plang00=plang00b;
run;

data w&f.06 (drop=x6_58);
     set in&y.02.hh00 (keep=hhid00 x6_58 x6_60_1 x6_61_:);
     if x6_58 ^in (1);
run;

data w&f.07;
     set w&f.05
         w&f.06;
run;

proc sort data=w&f.07 out=w&f.08 nodupkey;
     by hhid00;
run;

data w&f.09;
     merge w&f.08 (in=a)
           in&y.02.hh00 (in=b keep=hhid00);
     by hhid00;
     if a=0 and b=1 then do;
                           x6_60_1=.;
                           x6_61_0=.;
                           x6_61_1=.;
                           x6_61_2=.;
                           x6_61_3=.;
                           x6_61_4=.;
                           x6_61_5=.;
                           x6_61_6=.;
                           x6_61_7=.;
                           x6_61_8=.;
                           x6_61_9=.;
                         end;
     if b=1 then output;
run;

** Now create the variable **;

data w&f.10 (keep=hhid00 n&f c&f);
     set w&f.09;
     n&f=0;
     if x6_60_1 in (1) then n&f=1;
     if (x6_61_2=1 or x6_61_3=1 or x6_61_6=1 or x6_61_7=1) then n&f=2;
     if x6_61_1=1 then n&f=3;
     c&f=n&f;
run;

proc sort data=w&f.10 out=w&f.11;
     by hhid00;
run;

data w&f.final;
     set w&f.11;
     label n&f="num: type of deed to plot with house"
           c&f="ord: type of deed to plot with house";    
run;     

** Coding for Categorical Variable: 0=deed: does not own
                                    1=deed: owns, but no document
                                    2=deed: owns, partial rights document
                                    3=deed: owns, full rights document     **;   

*******************************************************************************************************;
** c25: assets: telephone **;

%let f=c25;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a5);
     if x6_4a5 in (99,.) then n&f=.;
        else if x6_4a5 in (0:2) then n&f=x6_4a5;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of telephones"
           c&f="cat: hh owns one or more telephones";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c26: assets: computer **;

%let f=c26;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a6);
     if x6_4a6 in (99,.) then n&f=.;
        else if x6_4a6 in (0:2) then n&f=x6_4a6;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of computers"
           c&f="cat: hh owns one or more computers";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c27: assets: microwave **;

%let f=c27;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a8);
     if x6_4a8 in (99,.) then n&f=.;
        else if x6_4a8 in (0:2) then n&f=x6_4a8;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of microwaves"
           c&f="cat: hh owns one or more microwaves";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c28: assets: washing machine **;

%let f=c28;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a9);
     if x6_4a9 in (99,.) then n&f=.;
        else if x6_4a9 in (0:2) then n&f=x6_4a9;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of washing machines"
           c&f="cat: hh owns one or more washing machines";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c29: assets: air conditioner **;

%let f=c29;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a10);
     if x6_4a10 in (99,.) then n&f=.;
        else if x6_4a10 in (0:2) then n&f=x6_4a10;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of air conditioners"
           c&f="cat: hh owns one or more air conditioners";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c30: assets: car **;

%let f=c30;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a17);
     if x6_4a17 in (99,.) then n&f=.;
        else if x6_4a17 in (0:2) then n&f=x6_4a17;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of cars"
           c&f="cat: hh owns one or more cars";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c31: assets: vcr **;

%let f=c31;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a3);
     if x6_4a3 in (99,.) then n&f=.;
        else if x6_4a3 in (0:3) then n&f=x6_4a3;    ** interprets one case of n=10 vcrs as an error **;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of vcrs"
           c&f="cat: hh owns one or more vcrs";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c32: assets: mobile phone **;

%let f=c32;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a4);
     if x6_4a4 in (99,.) then n&f=.;
        else if x6_4a4 in (0:3) then n&f=x6_4a4;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of mobile phones"
           c&f="cat: hh owns one or more mobile phones";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c33: assets: itan farm engine **;

%let f=c33;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a13);
     if x6_4a13 in (99,.) then n&f=.;
        else if x6_4a13 in (0:10) then n&f=x6_4a13;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of itans (engines)"
           c&f="cat: hh owns one or more itans (engines)";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c34: assets: bicycles **;

%let f=c34;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a14);
     if x6_4a14 in (99,.) then n&f=.;
        else if x6_4a14 in (0:11) then n&f=x6_4a14;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of bicycles"
           c&f="cat: hh owns one or more bicycles";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c35: assets: motorcycle - large **;

%let f=c35;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a15);
     if x6_4a15 in (99,.) then n&f=.;
        else if x6_4a15 in (0:7) then n&f=x6_4a15;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of large motorcycles"
           c&f="cat: hh owns one or more large motorcycles";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c36: assets: motorcycle - small **;

%let f=c36;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a16);
     if x6_4a16 in (99,.) then n&f=.;
        else if x6_4a16 in (0:20) then n&f=x6_4a16;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of small motorcycles"
           c&f="cat: hh owns one or more small motorcycles";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c37: assets: big truck **;

%let f=c37;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a18);
     if x6_4a18 in (99,.) then n&f=.;
        else if x6_4a18 in (0:5) then n&f=x6_4a18;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of big truck"
           c&f="cat: hh owns one or more big truck";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c38: assets: pickup truck **;

%let f=c38;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a19);
     if x6_4a19 in (99,.) then n&f=.;
        else if x6_4a19 in (0:3) then n&f=x6_4a19;
        else n&f=.;
     if n&f=. then c&f=.;     
        else if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of pickup trucks"
           c&f="cat: hh owns one or more pickup trucks";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **; 

*******************************************************************************************************;
** c41: income: silk weaving **;

%let f=c41;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_3a1);
     if x6_3a1 in (9,.) then n&f=.;
        else if x6_3a1 in (1:3) then n&f=1;         ** Treats HH use, sale, and mix as equivalent **;
        else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh participates in silk weaving"
           c&f="cat: hh participates in silk weaving";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c42: income: silk worm raising **;

%let f=c42;  ** update with each new variable **;
data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_3a2);
     if x6_3a2 in (9,.) then n&f=.;
        else if x6_3a2 in (1:3) then n&f=1;         ** Treats HH use, sale, and mix as equivalent **;
        else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh participates in silk worm raising"
           c&f="cat: hh participates in silk worm raising";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c43: income: cloth weaving **;

%let f=c43;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_3a3);
     if x6_3a3 in (9,.) then n&f=.;
        else if x6_3a3 in (1:3) then n&f=1;         ** Treats HH use, sale, and mix as equivalent **;
        else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh participates in other cloth weaving"
           c&f="cat: hh participates in other cloth weaving";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c44: income: charcoal making **;

%let f=c44;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_3a4);
     if x6_3a4 in (9,.) then n&f=.;
        else if x6_3a4 in (1:3) then n&f=1;         ** Treats HH use, sale, and mix as equivalent **;
        else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh participates in charcoal making"
           c&f="cat: hh participates in charcoal making";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c45: income: collecting firewood **;

%let f=c45;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_3a5);
     if x6_3a5 in (9,.) then n&f=.;
        else if x6_3a5 in (1:3) then n&f=1;         ** Treats HH use, sale, and mix as equivalent **;
        else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh participates in firewood collection"
           c&f="cat: hh participates in firewood collection";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c46: income: migrant remittances **;

%let f=c46;  ** update with each new variable **;

data w&f.01;
     set in&y.01.indiv00 (keep=hhid00 x26);
        if x26 in (0) then n&f.ind=0;
           else if x26 in (1) then n&f.ind=1;
           else if x26 in (2) then n&f.ind=1001;
           else if x26 in (3) then n&f.ind=3001;
           else if x26 in (4) then n&f.ind=5001;
           else if x26 in (5) then n&f.ind=10001;
           else if x26 in (6) then n&f.ind=20001;
           else if x26 in (7) then n&f.ind=40001;
        else n&f.ind=.;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 n&f.hh);
     set w&f.02;
     retain n&f.hh;
     by hhid00;
     if first.hhid00 then do;
                            n&f.hh=0;
                          end;
     n&f.hh=sum(of n&f.hh n&f.ind);
     if last.hhid00 then output;
run;

data w&f.04 (keep=hhid00 n&f c&f);
     set w&f.03;
     if n&f.hh=. then n&f=.;
        else n&f=n&f.hh/38.20;
     if n&f=. then c&f=.;
        else if n&f=0 then c&f=0;
        else if (n&f>0 and n&f<=125) then c&f=1;
        else if (n&f>125 and n&f<=250) then c&f=2;
        else if (n&f>250 and n&f<=500) then c&f=3;
        else if (n&f>500 and n&f<=1000) then c&f=4;
        else if (n&f>1000) then c&f=5;
run;

proc sort data=w&f.04 out=w&f.05;
     by hhid00;
run;

data w&f.final;
     set w&f.05;
     label n&f="num: Min. est. remittances from migrant members (2000 USD)"
           c&f="ord: Min. est. remittances from migrant members (2000 USD)";    
run;     

** Coding for Categorical Variable: 0=0
                                    1=1-125 
                                    2=126-250
                                    3=251-500 
                                    4=501-1000
                                    5=1000+     **;  


*******************************************************************************************************;
** c47-51: income: migrant remittances in kind **;

%let f=c47;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f.cl n&f.fd n&f.ap n&f.hh n&f.ve);
     set in&y.01.indiv00 (keep=hhid00 x27_1-x27_5);
     if x27_1 in (9,.) then n&f.cl=.;
        else if x27_1 in (8,2) then n&f.cl=0;
        else if x27_1 in (1) then n&f.cl=1;
        else n&f.cl=.;
     if x27_2 in (9,.) then n&f.fd=.;
        else if x27_2 in (8,2) then n&f.fd=0;
        else if x27_2 in (1) then n&f.fd=1;
        else n&f.fd=.;
     if x27_3 in (9,.) then n&f.ap=.;
        else if x27_3 in (8,2) then n&f.ap=0;
        else if x27_3 in (1) then n&f.ap=1;
        else n&f.ap=.;
     if x27_4 in (9,.) then n&f.hh=.;
        else if x27_4 in (8,2) then n&f.hh=0;
        else if x27_4 in (1) then n&f.hh=1;
        else n&f.hh=.;
     if x27_5 in (9,.) then n&f.ve=.;
        else if x27_5 in (8,2) then n&f.ve=0;
        else if x27_5 in (1) then n&f.ve=1;
        else n&f.ve=.;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 n&f.cl2 n&f.fd2 n&f.ap2 n&f.hh2 n&f.ve2);
     set w&f.02;
     retain n&f.cl2 n&f.fd2 n&f.ap2 n&f.hh2 n&f.ve2;
     by hhid00;
     if first.hhid00 then do;
                            n&f.cl2=0;
                            n&f.fd2=0;
                            n&f.ap2=0;
                            n&f.hh2=0;
                            n&f.ve2=0;
                          end;
     n&f.cl2=sum(of n&f.cl2 n&f.cl);
     n&f.fd2=sum(of n&f.fd2 n&f.fd);
     n&f.ap2=sum(of n&f.ap2 n&f.sp);
     n&f.hh2=sum(of n&f.hh2 n&f.hh);
     n&f.ve2=sum(of n&f.ve2 n&f.ve);
     if last.hhid00 then output;
run;

data w&f.04 (keep=hhid00 nc47 nc48 nc49 nc50 nc51 cc47 cc48 cc49 cc50 cc51);
     set w&f.03;
     nc47=n&f.cl2;
     nc48=n&f.fd2;
     nc49=n&f.ap2;
     nc50=n&f.hh2;
     nc51=n&f.ve2;

     if nc47=. then cc47=.;
       else if nc47>0 then cc47=1;
       else cc47=0;
     if nc48=. then cc48=.;
       else if nc48>0 then cc48=1;
       else cc48=0;
     if nc49=. then cc49=.;
       else if nc49>0 then cc49=1;
       else cc49=0;    
     if nc50=. then cc50=.;
       else if nc50>0 then cc50=1;
       else cc50=0;
     if nc51=. then cc51=.;
       else if nc51>0 then cc51=1;
       else cc51=0;
run;

proc sort data=w&f.04 out=w&f.05;
     by hhid00;
run;

data wc47final;
     set w&f.05 (keep=hhid00 nc47 cc47);
     label nc47="num: number of hh migrants remitting clothing"
           cc47="cat: at least one hh migrant remitted clothing";    
run;     

data wc48final;
     set w&f.05 (keep=hhid00 nc48 cc48);
     label nc48="num: number of hh migrants remitting food"
           cc48="cat: at least one hh migrant remitted food";    
run;     

data wc49final;
     set w&f.05 (keep=hhid00 nc49 cc49);
     label nc49="num: number of hh migrants remitting appliances"
           cc49="cat: at least one hh migrant remitted appliances";    
run;     

data wc50final;
     set w&f.05 (keep=hhid00 nc50 cc50);
     label nc50="num: number of hh migrants remitting other hh goods"
           cc50="cat: at least one hh migrant remitted other hh goods";    
run;     

data wc51final;
     set w&f.05 (keep=hhid00 nc51 cc51);
     label nc51="num: number of hh migrants remitting a vehicle"
           cc51="cat: at least one hh migrant remitted a vehicle";    
run;     
        
** Coding for Categorical Variable: 0=no
                                    1=yes   **;  

*******************************************************************************************************;
** c65: income: ag tech: large tractor **;

%let f=c65;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_76t2);
     if x6_76t2 in (9,.) then n&f=.;
        else if x6_76t2 in (1) then n&f=1;
        else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh owns one or more large tractors"
           c&f="cat: hh owns one or more large tractors";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c66: income: ag tech: iron buffalo (tiller) **;

%let f=c66;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_76b2);
     if x6_76b2 in (9,.) then n&f=.;
        else if x6_76b2 in (1) then n&f=1;
        else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh owns one or more tillers"
           c&f="cat: hh owns one or more tillers";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** c67: income: ag tech: rice thresher **;

%let f=c67;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_76r2);
     if x6_76r2 in (9,.) then n&f=.;
        else if x6_76r2 in (1) then n&f=1;
        else n&f=0;
     c&f=n&f;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh owns one or more rice threshers"
           c&f="cat: hh owns one or more rice threshers";    
run;     

** Coding for Categorical Variable: 0=no 
                                    1=yes **;  

*******************************************************************************************************;
** MERGE ALL VARIABLES WITH PREFIX "C" INTO A SINGLE FILE **;

%let f=c00;  ** update with each new variable **;

data w&f.01;
     merge wc04final (in=a)
           wc10final (in=b)
           wc13final (in=c) 
           wc23final (in=d)
           wc24final (in=e)
           wc25final (in=f)
           wc26final (in=g)
           wc27final (in=h)
           wc28final (in=i)
           wc29final (in=j)
           wc30final (in=k)
           wc31final (in=l)
           wc32final (in=m)
           wc33final (in=o)
           wc34final (in=p)
           wc35final (in=q)
           wc36final (in=r)
           wc37final (in=s)
           wc38final (in=t)
           wc41final (in=u)
           wc42final (in=v)
           wc43final (in=w)
           wc44final (in=x)
           wc45final (in=y)
           wc46final (in=z)
           wc47final (in=aa)
           wc48final (in=ab)
           wc49final (in=ac)
           wc50final (in=ad)
           wc51final (in=ae)
           wc65final (in=af)
           wc66final (in=ag)
           wc67final (in=ah);
     by hhid00;
     if a=1 then output;
run;

data ot&y.01.p03_00_c;
     set w&f.01;
run;

********************************************************************************************************;
** CREATE A STATA DATASET **;

data p03_00_c;
     set w&f.01;
run;

%include "/home/jhull/public/sasmacros/savastata.mac";

%savastata(/home/jhull/nangrong/data_sas/p03_gom/current/,-x -replace);