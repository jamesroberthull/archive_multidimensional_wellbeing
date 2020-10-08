********************************************************************************************************;
**  Program Name: /home/jhull/nangrong/prog_sas/p03_gom/p03_00_b.sas
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
**   '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_b.xpt'
**
**  Notes:
**   1.) This file creates all variables with the prefix "b"
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

libname ot&y.01 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_b.xpt';

*******************************************************************************************************;
** b01: Receive Any Money from Migrants **;

%let f=b01;  ** update with each new variable **;

data w&f.01 (keep= hhid00 n&f.rem);
     set in&y.01.indiv00 (keep=hhid00 x25);
     if x25 in (1) then n&f.rem=1;
        else if x25 in (2) then n&f.rem=0;
        else n&f.rem=.;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 hhn&f);
     set w&f.02;
     retain hhn&f;
     by hhid00;
     if first.hhid00 then do;
                            hhn&f=0;
                          end;
     if n&f.rem=1 then hhn&f=hhn&f+1;
     if last.hhid00 then output;
run;

data w&f.04 (keep=hhid00 n&f c&f);
     set w&f.03;
     n&f=hhn&f;
     if n&f>0 then c&f=1;
        else c&f=0;
run;

data w&f.final;
     set w&f.04;
     label n&f="num: # migrants remitting any cash or goods to hh"
           c&f="cat: 1 or more migrants remmitting cash or goods to hh";     
run;     

** Coding for Categorical Variable: 0=no migrants remitting cash or goods to hh
                                    1=1 or more migrants remitting cash or goods to hh **;   

*******************************************************************************************************;
** b02: electricity in village **;

%let f=b02;  ** update with each new variable **;

data w&f.01 (keep=vill94 n&f);
     set in&y.04.comm94 (keep=vill94 Q8_103);
     if q8_103=9998 then thaiyear=.;
        else thaiyear=q8_103;

** convert from B.E. (Buddhist Era) to C.E. (common era/Gregorian) **;

     if thaiyear ne . then do;
                             gregyear=thaiyear-543;
                             yearsold=2000-gregyear;
                             n&f=yearsold;
                           end;
        else n&f=.;
run;

data w&f.02;
     set in&y.02.hh00 (keep=hhid00 vill94);
run;

proc sort data=w&f.01 out=w&f.03;
     by vill94;
run;

proc sort data=w&f.02 out=w&f.04;
     by vill94;
run;

data w&f.05;
    merge w&f.03 (in=a)
          w&f.04 (in=b);
    by vill94;
    if b=1 then output;
run;

proc sort data=w&f.05 out=w&f.06;
    by hhid00;
run;

data w&f.06 (keep=hhid00 n&f c&f);
     set w&f.05;
     if n&f <10 then c&f=0;
        else if (n&f>9 and n&f<20) then c&f=1;
        else if (n&f>19) then c&f=2;
        else c&f=.;
run;

data w&f.final_pre;
     set w&f.06;
     label n&f="num: years that village has had electricity"
           c&f="ord: years that village has had electricity";
run;

proc sort data=w&f.final_pre out=w&f.final;
     by hhid00;
run;

** Coding for Categorical Variable: 0=1-9 years
                                    1=10-19 years
                                    2=20+ years     **;

*******************************************************************************************************;
** b03: indoor piped water **;

%let f=b03;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_2);

     if x6_2 in (1) then n&f=1;
        else if x6_2 in (2) then n&f=0;
        else n&f=.;

     if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: household has piped water indoors"
           c&f="cat: household has piped water indoors";
run;

** Coding for Categorical Variable: 0=piped water indoors: no
                                    1=piped water indoors: yes **;

*******************************************************************************************************;
** b04: Total Area of Land Used by HH: Hectares **;

%let f=b04;  ** update with each new variable **;

data w&f.01;
     set in&y.05.plots00 (keep=hhid00 x6_14nga x6_14rai x6_14wa 
                               x6_15nga x6_15rai x6_15wa x6_20_1);
     if x6_14rai in (98,9999,.) then n&f.ra=.;
        else n&f.ra=x6_14rai;
     if x6_15rai in (98,99,9999,.) then n&f.re=.;
        else n&f.re=x6_15rai;
     if x6_14nga in (99,.) then n&f.na=.;
        else n&f.na=(0.25*x6_14nga);
     if x6_15nga in (98,99,9999,.) then n&f.ne=.;
        else n&f.ne=(0.25*x6_15nga);
     if x6_14wa in (98,99,9999,.) then n&f.wa=.;
        else n&f.wa=(0.0025*x6_14wa);
     if x6_15wa in (98,99,9999,.) then n&f.we=.;
        else n&f.we=(0.0025*x6_15wa);
     if n&f.ra ne . then n&f.rai=n&f.ra;
        else if n&f.re ne . then n&f.rai=n&f.re;
             else if n&f.na ne . then n&f.rai=n&f.na;
                  else if n&f.ne ne . then n&f.rai=n&f.ne;
                       else if n&f.wa ne . then n&f.rai=n&f.wa;
                            else if n&f.we ne . then n&f.rai=n&f.we;
                                 else n&f.rai=.;
     n&f.hect=n&f.rai*0.16;    
  
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 n&f);
     set w&f.02;
     retain n&f;
     by hhid00;
     if first.hhid00 then do;
                            n&f=0;
                          end;
     n&f=n&f+n&f.hect;
    if last.hhid00 then output;
run;

data w&f.04 (keep=hhid00 n&f);
     merge w&f.03 (in=a)
           in&y.02.hh00 (in=b keep=hhid00);
     by hhid00;
     if a=0 and b=1 then n&f=0;
     if b=1 then output;
run;

data w&f.05;
     set w&f.04;
     if n&f>3.99 then c&f=2;
        else if (n&f<4 and n&f>0) then c&f=1;
        else c&f=0;
run;

data w&f.final;
     set w&f.05;
     label n&f="num: total land used previous year, hectares"
           c&f="ord: total land used previous year, hectares";
run;

** Coding for Categorical Variable: 0=total land used: 0 hectares
                                    1=total land used: 0-4 hectares
                                    2=total land used: 4+ hectares **;


*******************************************************************************************************;
** b05: total value of livestock **;

%let f=b05;  ** update with each new variable **;

data w&f.01 (keep=hhid00 vill00 n&f.c n&f.b n&f.h n&f.d n&f.p);
     set in&y.02.hh00 (keep=hhid00 x6_10a1 x6_10b1 x6_10a2 x6_10b2 
                            vill00 x6_10a3 x6_10b3 x6_10a4 x6_10b4 
                                   x6_10a5 x6_10b5 x6_10a6 x6_10b6 );
     if x6_10a1 in (9,.) then n&f.c=.;
        else if x6_10a1 in (3) then n&f.c=0;
        else if x6_10b1 ^in (9998,9999) then n&f.c=x6_10b1;
        else n&f.c=.;
     if x6_10a2 in (9,.) then n&f.b=.;
        else if x6_10a2 in (3) then n&f.b=0;
        else if x6_10b2 ^in (9998,9999) then n&f.b=x6_10b2;
        else n&f.b=.;
     if x6_10a3 in (9,.) then n&f.p=.;
        else if x6_10a3 in (3) then n&f.p=0;
        else if x6_10b3 ^in (9998,9999) then n&f.p=x6_10b3;
        else n&f.p=.;
     if x6_10a4 in (9,.) then n&f.d=.;
        else if x6_10a4 in (3) then n&f.d=0;
        else if x6_10b4 ^in (9998,9999) then n&f.d=x6_10b4;
        else n&f.d=.;
     if x6_10a5 in (9,.) then n&f.h=.;
        else if x6_10a5 in (3) then n&f.h=0;
        else if x6_10b5 ^in (9998,9999) then n&f.h=x6_10b5;
        else n&f.h=.;
run;

data w&f.02 (keep=vill00 n&f.cp n&f.dp n&f.hp n&f.bp n&f.pp);
     set in&y.03.comm00 (keep=vill00 x26bufpr x26pigpr x26chipr x26ducpr x26catpr);

     if x26bufpr=9999998 then n&f.bp=.;
        else n&f.bp=x26bufpr;
     if x26pigpr=9999998 then n&f.pp=.;
        else n&f.pp=x26pigpr;
     if x26chipr=9999998 then n&f.hp=.;
        else n&f.hp=x26chipr;
     if x26ducpr=9999998 then n&f.dp=.;
        else n&f.dp=x26ducpr;
     if x26catpr=9999998 then n&f.cp=.;
        else n&f.cp=x26catpr;

	**************************************************************************************
	**
	** Data for simple "Imputation" of selling price of livestock in villages with missing     
	**
	** Variable      N            Mean         Std Dev         Minimum         Maximum
	** -------------------------------------------------------------------------------
	** nb05bp      312        14310.90         3848.35         5000.00        30000.00
	** nb05pp      336         3247.92     425.0321908     300.0000000         6000.00
	** nb05hp      346      49.8872832      12.7732288      30.0000000     100.0000000
	** nb05dp      345      40.8173913      11.8894491      10.0000000     100.0000000
	** nb05cp      328        12297.90         4590.41         1700.00        50000.00
	** -------------------------------------------------------------------------------
	**
	**************************************************************************************;

     if n&f.bp=. then n&f.bp=14310.90;
     if n&f.pp=. then n&f.pp=3247.92;
     if n&f.hp=. then n&f.hp=49.89;
     if n&f.dp=. then n&f.dp=40.82;
     if n&f.cp=. then n&f.cp=12297.90;

run;

proc sort data=w&f.01 out=w&f.03;
     by vill00;
run;

proc sort data=w&f.02 out=w&f.04;
     by vill00;
run;

data w&f.05 (drop=vill00);
     merge w&f.03 (in=a)
           w&f.04 (in=b);
     by vill00;
     if a=1 then output;
run;

data w&f.06 (keep=hhid00 n&f c&f n&f._1 n&f._2 n&f._3 n&f._4 n&f._5);
     set w&f.05;

     ** multiply by village prices to get total value of livestock
        then convert to 2000 dollars using 6 month average exchange 
        rate for 1/1/2000-->6/30/2000 reported at the Federal Reserve:
        http://www.ny.frb.org/markets/fxrates/historical/fx.cfm **;

     n&f._1=(n&f.c*n&f.cp)/38;    ** i.e. 38.20 baht to the dollar **;
     n&f._2=(n&f.b*n&f.bp)/38;
     n&f._3=(n&f.p*n&f.pp)/38;
     n&f._4=(n&f.h*n&f.hp)/38;
     n&f._5=(n&f.d*n&f.dp)/38;
     n&f=sum(of n&f._1 n&f._2 n&f._3 n&f._4 n&f._5);

	**************************************************************
	** Data for categorization by quintile from proc univariate
	** Obs    P_0    P_20    P_40    P_60    P_80      P_100
	**   1    3.55   135     38      52.63   908.42    98597.37
	*************************************************************;

     if n&f >=(34520/38) then c&f=4;
        else if (n&f<(34520/38) and n&f>=(2000/38)) then c&f=3;
        else if (n&f<(2000/38) and n&f>=(600/38)) then c&f=2;
        else if (n&f<(600/38) and n&f>=(135/38)) then c&f=1;
        else if (n&f<(135/38)) then c&f=0;
        else c&f=.;
run;

data w&f.final;
     set w&f.06;
     label n&f="num: value of all livestock in 2000 dollars"
           c&f="ord: quintiles, value of all livestock in 2000 dollars"
           n&f._1="num: value of all cattle in 2000 dollars"
           n&f._2="num: value of all buffalo in 2000 dollars"
           n&f._3="num: value of all pigs in 2000 dollars"
           n&f._4="num: value of all chickens in 2000 dollars"
           n&f._5="num: value of all ducks in 2000 dollars";
run;

** Coding for Categorical Variable: 0=value of all livestock: lowest quintile
                                    1=value of all livestock: second lowest quintile
                                    2=value of all livestock: middle quintile
                                    3=value of all livestock: second highest quintile
                                    4=value of all livestock: highest quintile          **;

*******************************************************************************************************;
** b06: Number of plots owned by the hh **;

%let f=b06;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_11);
     if x6_11 in (.,99) then n&f=.;
        else n&f=x6_11;

     if n&f=. then c&f=.;
        else if n&f=0 then c&f=0;
             else if n&f=1 then c&f=1;
                  else if n&f=2 then c&f=2;
                       else c&f=3;
run;

data w&f.final;
     set w&f.01;
     label n&f="num: number of plots owned by the hh"
           c&f="ord: number of plots owned by the hh";
run;

** Coding for Categorical Variable: 0=number of plots: 0 
                                    1=number of plots: 1
                                    2=number of plots: 2 
                                    3=number of plots: 3 or more **;

*******************************************************************************************************;
** b07: nat res: high water suitability for rice **;

%let f=b07;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f.pr);
     set in&y.05.plots00 (keep=hhid00 x6_30 x6_31_1 x6_32_1);
     if x6_30 in (98,99,.) then n&f.y=.;
        else if x6_30 > 30 then n&f.y=30;
        else n&f.y=x6_30;
     if x6_31_1 in (99,.) then n&f.f=.;
        else if x6_31_1 in (98) then n&f.f=0;
        else if x6_31_1 > 30 then n&f.f=30;
        else n&f.f=x6_31_1;
     if x6_32_1 in (99,.) then n&f.d=.;
        else if x6_32_1 in (98) then n&f.d=0;
        else if x6_32_1 > 30 then n&f.d=30;
        else n&f.d=x6_32_1;

     n&f.b=n&f.f+n&f.d;

     n&f.pr=n&f.b/n&f.y;

    if n&f.pr>1 then n&f=1;
       else n&f=n&f.pr;

run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 count hhn&f.pr);
     set w&f.02;
     retain count hhn&f.pr;
     by hhid00;
     if first.hhid00 then do;
                            hhn&f.pr=0;
                            count=0;
                          end;
     hhn&f.pr=hhn&f.pr+n&f.pr;
     count=count+1;
     if last.hhid00 then output;
run;

data w&f.04;
     set w&f.03;
     n&f=hhn&f.pr/count;
run;

data w&f.05 (keep=hhid00 n&f);
     merge w&f.04 (in=a)
           in&y.02.hh00 (in=b keep=hhid00);
     by hhid00;
     if a=0 and b=1 then n&f=0;
     if b=1 then output;
run;

data w&f.06;
     set w&f.05;
     if n&f>=0.25 then c&f=2;
        else if (n&f<25 and n&f>0) then c&f=1;
        else if n&f=. then c&f=.;
        else c&f=0;             
run;

data w&f.final;
     set w&f.06;
     label n&f="num: prop years with major rice crop failure (flood/drought)"
           c&f="ord: prop years with major rice crop failure (flood/drought)";
run;

** Coding for Categorical Variable: 0=major rice crop failure: none 
                                    1=major rice crop failure: 1-25% of years 
                                    2=major rice crop failure: more than 25% of years **;

*******************************************************************************************************;
** b08: current hh member works outside of village **;

%let f=b08;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_9);
     
     if x6_9 in (9,.) then n&f=.;
        else if x6_9 in (1) then n&f=1;
        else n&f=0;

     c&f=n&f;
run;

data w&f.final;
     set w&f.01;
     label n&f="num: current hh member works outside of village"
           c&f="ord: current hh member works outside of village";
run;

** Coding for Categorical Variable: 0=no current hh member works outside of village
                                    1=current hh member works outside of village     **;

*******************************************************************************************************;
** b09: best composite estimate of total income from multiple sources **;

%let f=b09;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f.bj n&f.bs n&f.bo n&f.bc n&f.bg n&f.01);
     set in&y.02.hh00 (keep=hhid00 x6_87a1 x6_87b1 x6_87a2 x6_87b2 
                            vill00 x6_87a3 x6_87b3 x6_97 x6_104);

     ** equivalent income from rice **;

     if x6_87a1 in (998) then n&f.jg=0;
        else if x6_87a1 in (999) then n&f.jg=.;
        else n&f.jg=x6_87a1;
     if x6_87a2 in (998) then n&f.sg=0;
        else if x6_87a2 in (999) then n&f.sg=.;
        else n&f.sg=x6_87a2;
     if x6_87a3 in (998) then n&f.og=0;
        else if x6_87a3 in (999) then n&f.og=.;
        else n&f.og=x6_87a3;

     if x6_87b1 in (998) then n&f.jkgg=0;
        else if x6_87b1 in (999) then n&f.jkgg=.;
        else if x6_87b1 >100 then n&f.jkgg=100;
        else n&f.jkgg=x6_87b1;
     if x6_87b2 in (998) then n&f.skgg=0;
        else if x6_87b2 in (999) then n&f.skgg=.;
        else if x6_87b2 >100 then n&f.skgg=100;
        else n&f.skgg=x6_87b2;
     if x6_87b3 in (998) then n&f.okgg=0;
        else if x6_87b3 in (999) then n&f.okgg=.;
        else if x6_87b3 >100 then n&f.okgg=100;
        else n&f.okgg=x6_87b3;

     n&f.jkg=n&f.jg*n&f.jkgg;
     n&f.skg=n&f.sg*n&f.skgg;
     n&f.okg=n&f.og*n&f.okgg;

     n&f.bj=n&f.jkg*10.62;   ** uses average baht/kg jasmine rice from comm00 survey **;
     n&f.bs=n&f.skg*8.263;   ** uses average baht/kg sticky rice from comm00 survey **;
     n&f.bo=n&f.okg*5.245;   ** uses average baht/kg other rice from comm00 survey **;

     ** equivalent income from cassava **;

     if x6_97 in (99999994, 99999995, 99999999,9999995,9999994,9999999) then n&f.ckg=.;
        else if x6_97 in (99999998,9999998) then n&f.ckg=0;
        else n&f.ckg=x6_97;

     n&f.bc=n&f.ckg*0.70;    ** uses average baht/kg cassava from comm00 survey **;

     ** equivalent income from sugar cane **;

     if x6_104 in (99999994, 99999995, 99999999,9999995,9999994,9999999) then n&f.gkg=.;
        else if x6_104 in (99999998,9999998) then n&f.gkg=0;
        else n&f.gkg=x6_104;

     n&f.bg=n&f.gkg*0.41;    ** uses average baht/kg sugar from comm00 survey **;

     ** Total Income from Three Major Crops **;

     n&f.01=sum(of n&f.bj n&f.bs n&f.bo n&f.bc n&f.bg);
run;

** WAGES EARNED BY HH MEMBERS WORKING BEYOND VILLAGE ***;

data w&f.02 (keep=hhid00 n&f.02);
     set in&y.02.hh00 (keep=VILL00 HHID00 X6_9T: X6_9I:);
     if (X6_9I1 ^in (999) & X6_9T1 ^in (99)) then do;
                                               if X6_9I1 in (.,998) then WAGE1=0;
                                                  else WAGE1=X6_9I1;
                                               if X6_9T1 in (.,98) then DAYS1=0;
                                                  else DAYS1=X6_9T1;
                                               WAGELAB1=WAGE1*DAYS1;
                                            end;
        else WAGELAB1=.;
     if (X6_9I2 ^in (999) & X6_9T2 ^in (99)) then do;
                                               if X6_9I2 in (.,998) then WAGE2=0;
                                                  else WAGE2=X6_9I2;
                                               if X6_9T2 in (.,98) then DAYS2=0;
                                                  else DAYS2=X6_9T2;
                                               WAGELAB2=WAGE2*DAYS2;
                                            end;
        else WAGELAB2=.;
     if (X6_9I3 ^in (999) & X6_9T3 ^in (99)) then do;
                                               if X6_9I3 in (.,998) then WAGE3=0;
                                                  else WAGE3=X6_9I3;
                                               if X6_9T3 in (.,98) then DAYS3=0;
                                                  else DAYS3=X6_9T3;
                                               WAGELAB3=WAGE3*DAYS3;
                                            end;
        else WAGELAB3=.;
     if (X6_9I4 ^in (999) & X6_9T4 ^in (99)) then do;
                                               if X6_9I4 in (.,998) then WAGE4=0;
                                                  else WAGE4=X6_9I4;
                                               if X6_9T4 in (.,98) then DAYS4=0;
                                                  else DAYS4=X6_9T4;
                                               WAGELAB4=WAGE4*DAYS4;
                                            end;
        else WAGELAB4=.;
     if (X6_9I5 ^in (999) & X6_9T5 ^in (99)) then do;
                                               if X6_9I5 in (.,998) then WAGE5=0;
                                                  else WAGE5=X6_9I5;
                                               if X6_9T5 in (.,998) then DAYS5=0;
                                                  else DAYS5=X6_9T5;
                                               WAGELAB5=WAGE5*DAYS5;
                                            end;
        else WAGELAB5=.;
     n&f.02=sum(of WAGELAB1 WAGELAB2 WAGELAB3 WAGELAB4 WAGELAB5);
run;


** INCOME FROM AGRICULTURAL LABOR IN VILLAGE **;

data w&f.03;
     set in&y.02.hh00 (keep=HHID00 VILL00 X6_85H: X6_85N: X6_85W:);
     keep HHID00 VILL00 X6_86L X6_86N X6_86W LOCATION;

     length X6_86L $ 10;

     array a(1:13) X6_85H1-X6_85H13;
     array b(1:13) X6_85N1-X6_85N13;
     array c(1:13) X6_85W1-X6_85W13;

     do i=1 to 13;
 
          ** FIX ANOTHER CRAZY ERROR IN ORIGINAL DATA WITH REVERSED CODING FOR IN-VILLAGE LABOR **;
         
          if substr(a(i),5,3) in ('020','021','170','180') then a(i)=cat("2",substr(a(i),5,6),substr(a(i),2,3));

          if a(i)="9999999999" then LOCATION=8;
             else if substr(a(i),8,3)='999' then LOCATION=2;
             else LOCATION=0;

          X6_86L=a(i);
          X6_86N=b(i);
          X6_86W=c(i);

          if a(i) ne "         ." then output;  * Keep only those cases with data *;
     end;
run;

data w&f.04;
     set w&f.03 (rename=(X6_86L=HELPHHID));
     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86N=1;                * Assume at least 1 person worked *;
     if LOCATION=0 then HELPHHID=substr(HELPHHID,2,9);
        else HELPHHID=".";
     if X6_86W in (1) and LOCATION in (0) then output;
run;

proc sort data=w&f.04 out=w&f.05;
     by vill00;
run;

**input average village wages during high demand from community survey**;

data w&f.06 (drop=X45MHIGH X45MTYP);  
    set in&y.03.comm00 (keep=VILL00 X45MHIGH X45MTYP);

    if X45MHIGH=9999998 then X45MHIGH=.; ** USING ONLY MALES B/C MALE AND FEMALE WAGES IDENTICAL **;
    if X45MTYP=9999998 then X45MTYP=.;

    if X45MHIGH=. then RICEWAGH=125.77;
       else RICEWAGH=X45MHIGH;
    if X45MTYP=. then RICEWAGN=105.29;
       else RICEWAGN=X45MTYP;
run;

proc sort data=w&f.06 out=w&f.07;
     by vill00;
run;

data w&f.08;
     merge w&f.05 (in=a)
           w&f.07 (in=b);
     by vill00;
     if a=1 then output;
run;

proc sort data=w&f.08 out=w&f.09;
     by helphhid;
run;

data w&f.10 (keep=hhid00 helphhid n&f.wage);
     set w&f.09;
     n&f.wage=ricewagh*x6_86n*3;          ** 3 is the median number of days worked by HHs in 1994 **;
run;                                      

data w&f.11 (keep=helphhid n&f.03);
     set w&f.10;
     retain n&f.03;
     by helphhid;
     if first.helphhid then do;
                              n&f.03=0;
                            end;
     n&f.03=n&f.03+n&f.wage;
     if last.helphhid then output;
run;

data w&f.12;
     merge w&f.11 (in=a rename=(helphhid=hhid00))
           in&y.06.hh00v84 (in=b keep=hhid00);
     by hhid00;
     if a=0 and b=1 then n&f.03=0;
     if b=1 then output;
run;

data w&f.13;
     merge w&f.01 (in=a)
           w&f.02 (in=b)
           w&f.12 (in=c);
     by hhid00;
run;


data w&f.14;
     set w&f.13;
     n&f.tot=round((sum(of n&f.01 n&f.02 n&f.03))/38,.01);      ** Sum and Convert to 2000 USD **;
run;

** Divide by Number of Current HH Members to Create Per Capita Income **;

data w&f.15;
     set in&y.01.indiv00 (keep=hhid00 x5);
     if x5=1 then n&f.cnt=1;
        else n&f.cnt=0;
run;

proc sort data=w&f.15 out=w&f.16;
     by hhid00;
run;

data w&f.17 (keep=hhid00 n&f.nhh);
     set w&f.16;
     retain n&f.nhh;
     by hhid00;
     if first.hhid00 then do;
                            n&f.nhh=0;
                          end;
     n&f.nhh=n&f.nhh+n&f.cnt;
     if n&f.nhh=0 then n&f.nhh=1;            ** Quick fix for 3 HHs with 0 "usually stays here" counts **;
     if last.hhid00 then output;
run;
     
data w&f.18;
     merge w&f.14 (in=a)
           w&f.17 (in=b);
     by hhid00;
     if a=1 then output;
run;

data w&f.19;
     set w&f.18;
     n&f=n&f.tot/n&f.nhh;
run;

data w&f.20 (keep=hhid00 n&f c&f);
     set w&f.19;

	**********************************************************************
	** Obs P0   P20        P40        P60        P80         P100
	** 1   0    9.47333    139.368    250.157    421.478    8878.86
	**********************************************************************;

     if n&f >=421 then c&f=4;
        else if (n&f<421 and n&f>=250) then c&f=3;
        else if (n&f<250 and n&f>=139) then c&f=2;
        else if (n&f<139 and n&f>=9.5) then c&f=1;
        else if (n&f<9.5) then c&f=0;
        else c&f=.;
run;

data w&f.final;
     set w&f.20;
     label n&f="num: per capita income (ag prod+ag wage+other wage), 2000 Dollars"
           c&f="ord: quintiles, per capita income (ag prod+ag wage+other wage), 2000 Dollars";
run;

** Coding for Categorical Variable: 0=per capita income (ag prod+ag wage+other wage): lowest quintile
                                    1=per capita income (ag prod+ag wage+other wage): second lowest quintile
                                    2=per capita income (ag prod+ag wage+other wage): middle quintile
                                    3=per capita income (ag prod+ag wage+other wage): second highest quintile
                                    4=per capita income (ag prod+ag wage+other wage): highest quintile        **;

*******************************************************************************************************;
** b10: HH Used Any Family Labor Last Season        **;
** b11: HH Used Any Nonmonetized Labor Last Season  **;
** b12: HH Used Any Monetized Labor Last Season     **;

%let f=b10;  ** update with each new variable (HAND CODED FOR b11 and b12) **;

data w&f.01 (keep=hhid00 n&f.hh c&f cb11 cb12); 

     set in&y.02.hh00 (keep=hhid00 x6_83 x6_93 x6_100 x6_84w: x6_85w: 
                            x6_86w: x6_94w: x6_95w: x6_96w: x6101w: 
                            x6102w: x6103w:);

	**********************************************************************;

** RICE: HH Labor (all Free) **;
     if x6_83 in (99,.) then n&f.hhr=.;
        else if x6_83 in (98) then n&f.hhr=0;
        else if x6_83 in (1:20) then n&f.hhr=x6_83;
        else n&f.hhr=.;
** CASSAVA: HH Labor (all Free) **;
     if x6_93 in (99,.) then n&f.hhc=.;
        else if x6_93 in (98) then n&f.hhc=0;
        else if x6_93 in (1:20) then n&f.hhc=x6_93;
        else n&f.hhc=.;
** SUGAR: HH Labor (all Free) **;
     if x6_100 in (99,.) then n&f.hhs=.;
        else if x6_100 in (98) then n&f.hhs=0;
        else if x6_100 in (1:20) then n&f.hhs=x6_100;
        else n&f.hhs=.;
** COMPOSITE: HH Labor (all Free) **;
     n&f.hh=sum(of n&f.hhr n&f.hhc n&f.hhs); ** Kind of Bogus: Double Counts, but useful for creating cat var **;
     if n&f.hh>0 then c&f.hh=1;
        else c&f.hh=0;

	**********************************************************************;

** RICE: Code 2&3 Paid & Free (7) **;
     if x6_84w1 in (2,3) then n&f.23f1=1;
        else n&f.23f1=0;
     if x6_84w2 in (2,3) then n&f.23f2=1;
        else n&f.23f2=0;
     if x6_84w3 in (2,3) then n&f.23f3=1;
        else n&f.23f3=0;
     if x6_84w4 in (2,3) then n&f.23f4=1;
        else n&f.23f4=0;
     if x6_84w5 in (2,3) then n&f.23f5=1;
        else n&f.23f5=0;
     if x6_84w6 in (2,3) then n&f.23f6=1;
        else n&f.23f6=0;
     if x6_84w7 in (2,3) then n&f.23f7=1;
        else n&f.23f7=0;
     n&f.23rf=sum(of n&f.23f1 n&f.23f2 n&f.23f3 n&f.23f4 n&f.23f5 n&f.23f6 n&f.23f7);
     if n&f.23rf > 1 then c&f.23rf=1;
        else c&f.23rf=0;
     if x6_84w1 in (1) then n&f.23p1=1;
        else n&f.23p1=0;
     if x6_84w2 in (1) then n&f.23p2=1;
        else n&f.23p2=0;
     if x6_84w3 in (1) then n&f.23p3=1;
        else n&f.23p3=0;
     if x6_84w4 in (1) then n&f.23p4=1;
        else n&f.23p4=0;
     if x6_84w5 in (1) then n&f.23p5=1;
        else n&f.23p5=0;
     if x6_84w6 in (1) then n&f.23p6=1;
        else n&f.23p6=0;
     if x6_84w7 in (1) then n&f.23p7=1;
        else n&f.23p7=0;
     n&f.23rp=sum(of n&f.23p1 n&f.23p2 n&f.23p3 n&f.23p4 n&f.23p5 n&f.23p6 n&f.23p7);
     if n&f.23rp > 1 then c&f.23rp=1;
        else c&f.23rp=0;
** CASSAVA: Code 2&3 Paid & Free (3) **;
     if x6_94w1 in (2,3) then n&f.2cf1=1;
        else n&f.2cf1=0;
     if x6_94w2 in (2,3) then n&f.2cf2=1;
        else n&f.2cf2=0;
     if x6_94w3 in (2,3) then n&f.2cf3=1;
        else n&f.2cf3=0;
     n&f.23cf=sum(of n&f.2cf1 n&f.2cf2 n&f.2cf3);
     if n&f.23cf > 1 then c&f.23cf=1;
        else c&f.23cf=0;
     if x6_94w1 in (1) then n&f.2cp1=1;
        else n&f.2cp1=0;
     if x6_94w2 in (1) then n&f.2cp2=1;
        else n&f.2cp2=0;
     if x6_94w3 in (1) then n&f.2cp3=1;
        else n&f.2cp3=0;
     n&f.23cp=sum(of n&f.2cp1 n&f.2cp2 n&f.2cp3);
     if n&f.23cp > 1 then c&f.23cp=1;
        else c&f.23cp=0;
** SUGAR: Code 2&3 Paid & Free (1) **;
     if x6101w1 in (2,3) then n&f.2sf1=1;
        else n&f.2sf1=0;
     n&f.23sf=sum(of n&f.2sf1);
     if n&f.23sf > 1 then c&f.23sf=1;
        else c&f.23sf=0;
     if x6101w1 in (1) then n&f.2sp1=1;
        else n&f.2sp1=0;
     n&f.23sp=sum(of n&f.2sp1);
     if n&f.23sp > 1 then c&f.23sp=1;
        else c&f.23sp=0;
** COMPOSITE: CODE 2 & # Paid & Free **;
     n&f.23f=sum(of n&f.23rf n&f.23cf n&f.23sf);
     n&f.23p=sum(of n&f.23rp n&f.23cp n&f.23sp);
     if n&f.23f > 1 then c&f.23f=1;
        else c&f.23f=0;
     if n&f.23p > 1 then c&f.23p=1;
        else c&f.23p=0;

	**********************************************************************;

** RICE: Same Village Paid & Free (13) **;
     if x6_85w1 in (2,3) then n&f.svf1=1;
        else n&f.svf1=0;
     if x6_85w2 in (2,3) then n&f.svf2=1;
        else n&f.svf2=0;
     if x6_85w3 in (2,3) then n&f.svf3=1;
        else n&f.svf3=0;
     if x6_85w4 in (2,3) then n&f.svf4=1;
        else n&f.svf4=0;
     if x6_85w5 in (2,3) then n&f.svf5=1;
        else n&f.svf5=0;
     if x6_85w6 in (2,3) then n&f.svf6=1;
        else n&f.svf6=0;
     if x6_85w7 in (2,3) then n&f.svf7=1;
        else n&f.svf7=0;
     if x6_85w8 in (2,3) then n&f.svf8=1;
        else n&f.svf8=0;
     if x6_85w9 in (2,3) then n&f.svf9=1;
        else n&f.svf9=0;
     if x6_85w10 in (2,3) then n&f.svf10=1;
        else n&f.svf10=0;
     if x6_85w11 in (2,3) then n&f.svf11=1;
        else n&f.svf11=0;
     if x6_85w12 in (2,3) then n&f.svf12=1;
        else n&f.svf12=0;
     if x6_85w13 in (2,3) then n&f.svf13=1;
        else n&f.svf13=0;
     n&f.svrf=sum(of n&f.svf1 n&f.svf2 n&f.svf3 n&f.svf4 n&f.svf5 n&f.svf6 n&f.svf7
                     n&f.svf8 n&f.svf9 n&f.svf10 n&f.svf11 n&f.svf12 n&f.svf13);
     if n&f.svrf > 1 then c&f.svrf=1;
        else c&f.svrf=0;
     if x6_85w1 in (1) then n&f.svp1=1;
        else n&f.svp1=0;
     if x6_85w2 in (1) then n&f.svp2=1;
        else n&f.svp2=0;
     if x6_85w3 in (1) then n&f.svp3=1;
        else n&f.svp3=0;
     if x6_85w4 in (1) then n&f.svp4=1;
        else n&f.svp4=0;
     if x6_85w5 in (1) then n&f.svp5=1;
        else n&f.svp5=0;
     if x6_85w6 in (1) then n&f.svp6=1;
        else n&f.svp6=0;
     if x6_85w7 in (1) then n&f.svp7=1;
        else n&f.svp7=0;
     if x6_85w8 in (1) then n&f.svp8=1;
        else n&f.svp8=0;
     if x6_85w9 in (1) then n&f.svp9=1;
        else n&f.svp9=0;
     if x6_85w10 in (1) then n&f.svp10=1;
        else n&f.svp10=0;
     if x6_85w11 in (1) then n&f.svp11=1;
        else n&f.svp11=0;
     if x6_85w12 in (1) then n&f.svp12=1;
        else n&f.svp12=0;
     if x6_85w13 in (1) then n&f.svp13=1;
        else n&f.svp13=0;
     n&f.svrp=sum(of n&f.svp1 n&f.svp2 n&f.svp3 n&f.svp4 n&f.svp5 n&f.svp6 n&f.svp7
                     n&f.svp8 n&f.svp9 n&f.svp10 n&f.svp11 n&f.svp12 n&f.svp13);
     if n&f.svrp > 1 then c&f.svrp=1;
        else c&f.svrp=0;
** CASSAVA: Same Village Paid & Free (6) **;
     if x6_95w1 in (2,3) then n&f.2cf1=1;
        else n&f.2cf1=0;
     if x6_95w2 in (2,3) then n&f.2cf2=1;
        else n&f.2cf2=0;
     if x6_95w3 in (2,3) then n&f.2cf3=1;
        else n&f.2cf3=0;
     if x6_95w4 in (2,3) then n&f.2cf4=1;
        else n&f.2cf4=0;
     if x6_95w5 in (2,3) then n&f.2cf5=1;
        else n&f.2cf5=0;
     if x6_95w6 in (2,3) then n&f.2cf6=1;
        else n&f.2cf6=0;
     n&f.svcf=sum(of n&f.2cf1 n&f.2cf2 n&f.2cf3 n&f.2cf4 n&f.2cf5 n&f.2cf6);
     if n&f.svcf > 1 then c&f.svcf=1;
        else c&f.svcf=0;
     if x6_95w1 in (1) then n&f.2cp1=1;
        else n&f.2cp1=0;
     if x6_95w2 in (1) then n&f.2cp2=1;
        else n&f.2cp2=0;
     if x6_95w3 in (1) then n&f.2cp3=1;
        else n&f.2cp3=0;
     if x6_95w4 in (1) then n&f.2cp4=1;
        else n&f.2cp4=0;
     if x6_95w5 in (1) then n&f.2cp5=1;
        else n&f.2cp5=0;
     if x6_95w6 in (1) then n&f.2cp6=1;
        else n&f.2cp6=0;
     n&f.svcp=sum(of n&f.2cp1 n&f.2cp2 n&f.2cp3 n&f.2cp4 n&f.2cp5 n&f.2cp6);
     if n&f.svcp > 1 then c&f.svcp=1;
        else c&f.svcp=0;
** SUGAR: Same Village Paid & Free (5) **;
     if x6102w1 in (2,3) then n&f.2sf1=1;
        else n&f.2sf1=0;
     if x6102w2 in (2,3) then n&f.2sf2=1;
        else n&f.2sf2=0;
     if x6102w3 in (2,3) then n&f.2sf3=1;
        else n&f.2sf3=0;
     if x6102w4 in (2,3) then n&f.2sf4=1;
        else n&f.2sf4=0;
     if x6102w5 in (2,3) then n&f.2sf5=1;
        else n&f.2sf5=0;
     n&f.svsf=sum(of n&f.2sf1 n&f.2sf2 n&f.2sf3 n&f.2sf4 n&f.2sf5);
     if n&f.svsf > 1 then c&f.svsf=1;
        else c&f.svsf=0;
     if x6102w1 in (1) then n&f.2sp1=1;
        else n&f.2sp1=0;
     if x6102w2 in (1) then n&f.2sp2=1;
        else n&f.2sp2=0;
     if x6102w3 in (1) then n&f.2sp3=1;
        else n&f.2sp3=0;
     if x6102w4 in (1) then n&f.2sp4=1;
        else n&f.2sp4=0;
     if x6102w5 in (1) then n&f.2sp5=1;
        else n&f.2sp5=0;
     n&f.svsp=sum(of n&f.2sp1 n&f.2sp2 n&f.2sp3 n&f.2sp4 n&f.2sp5);
     if n&f.svsp > 1 then c&f.svsp=1;
        else c&f.svsp=0;
** COMPOSITE: Same Village Paid & Free **;
     n&f.svf=sum(of n&f.svrf n&f.svcf n&f.svsf);
     n&f.svp=sum(of n&f.svrp n&f.svcp n&f.svsp);
     if n&f.svf > 1 then c&f.svf=1;
        else c&f.svf=0;
     if n&f.svp > 1 then c&f.svp=1;
        else c&f.svp=0;

	**********************************************************************;

** RICE: Other Village Paid & Free (10) **;
     if x6_86w1 in (2,3) then n&f.ovf1=1;
        else n&f.ovf1=0;
     if x6_86w2 in (2,3) then n&f.ovf2=1;
        else n&f.ovf2=0;
     if x6_86w3 in (2,3) then n&f.ovf3=1;
        else n&f.ovf3=0;
     if x6_86w4 in (2,3) then n&f.ovf4=1;
        else n&f.ovf4=0;
     if x6_86w5 in (2,3) then n&f.ovf5=1;
        else n&f.ovf5=0;
     if x6_86w6 in (2,3) then n&f.ovf6=1;
        else n&f.ovf6=0;
     if x6_86w7 in (2,3) then n&f.ovf7=1;
        else n&f.ovf7=0;
     if x6_86w8 in (2,3) then n&f.ovf8=1;
        else n&f.ovf8=0;
     if x6_86w9 in (2,3) then n&f.ovf9=1;
        else n&f.ovf9=0;
     if x6_86w10 in (2,3) then n&f.ovf10=1;
        else n&f.ovf10=0;
     n&f.ovrf=sum(of n&f.ovf1 n&f.ovf2 n&f.ovf3 n&f.ovf4 n&f.ovf5 n&f.ovf6 n&f.ovf7
                     n&f.ovf8 n&f.ovf9 n&f.ovf10);
     if n&f.ovrf > 1 then c&f.ovrf=1;
        else c&f.ovrf=0;
     if x6_86w1 in (1) then n&f.ovp1=1;
        else n&f.ovp1=0;
     if x6_86w2 in (1) then n&f.ovp2=1;
        else n&f.ovp2=0;
     if x6_86w3 in (1) then n&f.ovp3=1;
        else n&f.ovp3=0;
     if x6_86w4 in (1) then n&f.ovp4=1;
        else n&f.ovp4=0;
     if x6_86w5 in (1) then n&f.ovp5=1;
        else n&f.ovp5=0;
     if x6_86w6 in (1) then n&f.ovp6=1;
        else n&f.ovp6=0;
     if x6_86w7 in (1) then n&f.ovp7=1;
        else n&f.ovp7=0;
     if x6_86w8 in (1) then n&f.ovp8=1;
        else n&f.ovp8=0;
     if x6_86w9 in (1) then n&f.ovp9=1;
        else n&f.ovp9=0;
     if x6_86w10 in (1) then n&f.ovp10=1;
        else n&f.ovp10=0;
     n&f.ovrp=sum(of n&f.ovp1 n&f.ovp2 n&f.ovp3 n&f.ovp4 n&f.ovp5 n&f.ovp6 n&f.ovp7
                     n&f.ovp8 n&f.ovp9 n&f.ovp10);
     if n&f.ovrp > 1 then c&f.ovrp=1;
        else c&f.ovrp=0;

** CASSAVA: Other Village Paid & Free (2) **;
     if x6_96w1 in (2,3) then n&f.2cf1=1;
        else n&f.2cf1=0;
     if x6_96w2 in (2,3) then n&f.2cf2=1;
        else n&f.2cf2=0;
     n&f.ovcf=sum(of n&f.2cf1 n&f.2cf2);
     if n&f.ovcf > 1 then c&f.ovcf=1;
        else c&f.ovcf=0;
     if x6_96w1 in (1) then n&f.2cp1=1;
        else n&f.2cp1=0;
     if x6_96w2 in (1) then n&f.2cp2=1;
        else n&f.2cp2=0;
     n&f.ovcp=sum(of n&f.2cp1 n&f.2cp2);
     if n&f.ovcp > 1 then c&f.ovcp=1;
        else c&f.ovcp=0;

** SUGAR: Other Village Paid & Free (2) **;
     if x6103w1 in (2,3) then n&f.2sf1=1;
        else n&f.2sf1=0;
     if x6103w2 in (2,3) then n&f.2sf2=1;
        else n&f.2sf2=0;
     n&f.ovsf=sum(of n&f.2sf1 n&f.2sf2);
     if n&f.ovsf > 1 then c&f.ovsf=1;
        else c&f.ovsf=0;
     if x6103w1 in (1) then n&f.2sp1=1;
        else n&f.2sp1=0;
     if x6103w2 in (1) then n&f.2sp2=1;
        else n&f.2sp2=0;
     n&f.ovsp=sum(of n&f.2sp1 n&f.2sp2);
     if n&f.ovsp > 1 then c&f.ovsp=1;
        else c&f.ovsp=0;

** COMPOSITE: Other Village Paid & Free **;
     n&f.ovf=sum(of n&f.ovrf n&f.ovcf n&f.ovsf);
     n&f.ovp=sum(of n&f.ovrp n&f.ovcp n&f.ovsp);
     if n&f.ovf > 1 then c&f.ovf=1;
        else c&f.ovf=0;
     if n&f.ovp > 1 then c&f.ovp=1;
        else c&f.ovp=0;

	**********************************************************************;

** COMPOSITES OF COMPOSITES **;
    if c&f.hh=1 or c&f.23f=1 then c&f=1;
       else c&f=0;                        ** HH and Free Code 2&3 = "Family Labor" **;
    if c&f.svf=1 or c&f.ovf=1 then cb11=1;
       else cb11=0;                        ** Free Same and Other Village = "Non-Monetized Labor" **;
    if c&f.23p=1 or c&f.svp=1 or c&f.ovp=1 then cb12=1;
       else cb12=0;                        ** Paid Code 2&3, Same, and Other Village = "Monetized Labor" **;
run;

data w&f.final;
     set w&f.01 (keep=hhid00 c&f);
     label c&f="cat: HH used family labor (rice, cassava, sugar, last season)";
run;

data wb11final;
     set w&f.01 (keep=hhid00 cb11);
     label cb11="cat: HH used nonmonetized labor (rice, cassava, sugar, last season)";
run;

data wb12final;
     set w&f.01 (keep=hhid00 cb12);
     label cb12="cat: HH used monetized labor (rice, cassava, sugar, last season)";
run;


** Coding for Categorical Variables: 0=HH Did Not Use Labor Type: Family
                                     1=HH Used Labor Type: Family                 **;

** Coding for Categorical Variables: 0=HH Did Not Use Labor Type: Nonmonetized
                                     1=HH Used Labor Type: Nonmonetized           **;

** Coding for Categorical Variables: 0=HH Did Not Use Labor Type: Monetized
                                     1=HH Used Labor Type:Monetize                **;


*******************************************************************************************************;
** MERGE ALL VARIABLES WITH PREFIX "B" INTO A SINGLE FILE **;

%let f=b00;  ** update with each new variable **;

data w&f.01;
     merge wb01final (in=a)
           wb02final (in=b)
           wb03final (in=c) 
           wb04final (in=d)
           wb05final (in=e)
           wb06final (in=f)
           wb07final (in=g)
           wb08final (in=h)
           wb09final (in=i)
           wb10final (in=j)
           wb11final (in=k)
           wb12final (in=l);
     by hhid00;
     if a=1 then output;
run;

data ot&y.01.p03_00_b;
     set w&f.01;
run;

********************************************************************************************************;
** CREATE A STATA DATASET **;

data p03_00_b;
     set w&f.01;
run;

%include "/home/jhull/public/sasmacros/savastata.mac";

%savastata(/home/jhull/nangrong/data_sas/p03_gom/current/,-x -replace);