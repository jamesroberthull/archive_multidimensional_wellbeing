********************************************************************************************************;
**  Program Name: /home/jhull/nangrong/prog_sas/p03_gom/p03_00_a.sas
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
**   '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_a.xpt'
**
**  Notes:
**   1.) This file creates all of the variables with prefix "a"
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

libname ot&y.01 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_a.xpt';


********************************************************************************************************;
** a01: education of hh head **;

%let f=a01;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.01.indiv00 (keep=hhid00 x13 x20);
     if x20 in (0:20) then n&f.ed=x20;
	 else if x20 in (94,95) then n&f.ed=1;
        else if x20 in (97) then n&f.ed=4;
             else n&f.ed=.;                          
     if x13 in (1:18) then n&f.rl=x13;
       else n&f.rl=.;
     if n&f.rl in (1) then do;
                              n&f=n&f.ed;
                              if n&f.ed in (0:4) then c&f=0;
                                 else if n&f.ed in (5:6) then c&f=1;
                                 else if n&f.ed in (7:20) then c&f=2;
                                 else c&f=.;
                           end;
     if n&f.rl=1;
run;

proc sort data=w&f.01 out=w&f.02a;
     by hhid00;
run;

proc sort data=in&y.06.hh00v84 (keep=hhid00) out=w&f.02b;
     by hhid00;
run;


data w&f.03;
     merge w&f.02a (in=a)
           w&f.02b (in=b);
     by hhid00;
     if b=1;
run;

data w&f.final;
     set w&f.03;
     label n&f="num: educational attainment of hh head"
           c&f="ord: educational attainment of hh head";
run;

** Coding for Categorical Variable: 0=hh head education 0-4 years
                                    1=hh head education 5-6 years    
                                    2=hh head education 7+ years   **;


********************************************************************************************************;
** a02: sex of hh head is female **;

%let f=a02;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.01.indiv00 (keep=hhid00 x4 x13);
     if x4 in (1) then n&f=0;
        else if x4 in (2) then n&f=1;
        else n&f=.;
     if x13 in (1:18) then n&f.rl=x13;
       else n&f.rl=.;     
     if n&f.rl in (1) then do;
                            c&f=n&f;
                           end;
     if n&f.rl=1;
run;

proc sort data=w&f.01 out=w&f.02a;
     by hhid00;
run;

proc sort data=in&y.06.hh00v84 (keep=hhid00) out=w&f.02b;
     by hhid00;
run;


data w&f.03;
     merge w&f.02a (in=a)
           w&f.02b (in=b);
     by hhid00;
     if b=1;
run;

data w&f.final;
     set w&f.03;
     label n&f="num: sex of hh head is female"
           c&f="cat: sex of hh head is female";
run;

** Coding for Categorical Variable: 0=sex of hh head is not female
                                    1=sex of hh head is female      **;

********************************************************************************************************;
** a03: child with parent absent in hh **;

%let f=a03;  ** update with each new variable **;

** Determine the location of parents listed on HH roster **;

data w&f.01a (keep=hhid00 cep00 hhidccep x17 fcep hhidfcep) 
     w&f.01b (keep=hhid00 cep00 hhidccep x18 mcep hhidmcep);
     set in&y.01.indiv00 (keep=hhid00 cep00 x17 x18 code2);
     
     hhidccep=hhid00||cep00;
    
     if substr(x17,1,1)="1" then fcep=substr(x17,3,2);
        else fcep=".";
     if substr(x18,1,1)="1" then mcep=substr(x18,3,2);
        else mcep=".";
     if fcep ^in (".") then hhidfcep=hhid00||fcep;
        else hhidfcep=".";
     if mcep ^in (".") then hhidmcep=hhid00||mcep;
        else hhidmcep=".";
     if code2 ne 1 and hhidfcep ^in (".") then output w&f.01a;   ** remove code 2 double entries **;
     if code2 ne 1 and hhidmcep ^in (".") then output w&f.01b;   ** remove code 2 double entries **;
run;

data w&f.02 (drop=hhid00 cep00 x1);
     set in&y.01.indiv00 (keep=hhid00 cep00 x1);
     hhidfcep= hhid00||cep00;
     hhidmcep= hhid00||cep00;
     x1f=x1;
     x1m=x1;
run;

proc sort data=w&f.01a out=w&f.03a;
     by hhidfcep;
run;

proc sort data=w&f.01b out=w&f.03b;
     by hhidmcep;
run;

proc sort data=w&f.02 out=w&f.04a (drop=hhidmcep x1m);
     by hhidfcep;
run;

proc sort data=w&f.02 out=W&f.04b (drop=hhidfcep x1f);
     by hhidmcep;
run;

data w&f.05a;
     merge w&f.03a (in=a)
           w&f.04a (in=b);
     by hhidfcep;
     if a=1 and b=1 then output;
run;

data w&f.05b;
     merge w&f.03b (in=a)
           w&f.04b (in=b);
     by hhidmcep;
     if a=1 and b=1 then output;
run;

proc sort data=w&f.05a out=w&f.06a;
     by hhidccep;
run;

proc sort data=w&f.05b out=w&f.06b;
     by hhidccep;
run;

data w&f.07 (keep=hhid00 cep00 x1f x1m);
     merge w&f.06a (in=a)
           w&f.06b (in=b);
    by hhidccep;
    if a=1 or b=1 then output;
run;

data w&f.08;
     merge w&f.07 (in=a)
           in&y.01.indiv00 (in=b keep=hhid00 cep00 x1 x3 x17 x18);
     by hhid00 cep00;
     if b=1 then output;
run;

data w&f.09 (keep=hhid00 cep00 n&f.age n&f);
     set w&f.08;
     if x3 in (1:97) then n&f.age=x3;
        else n&f.age=.;
     if substr(x17,1,1) in ("1") and x1f in (1) then n&f.floc=1;
        else n&f.floc=0;
     if substr(x18,1,1) in ("1") and x1m in (1) then n&f.mloc=1;
        else n&f.mloc=0;
     if x1 in (1) then n&f.cloc=1;
        else n&f.cloc=0;
     n&f.ploc=n&f.floc+n&f.mloc;
     if n&f.cloc=1 and n&f.ploc=2 then n&f.npar=2;
        else if n&f.cloc=1 and n&f.ploc=1 then n&f.npar=1;
        else n&f.npar=0;
     if n&f.age<13 and x1 in (1) then do;                                 **"child" is under age 12**;
                                        if n&f.npar=2 then n&f=2;
                                           else if n&f.npar=1 then n&f=1;
                                           else n&f=0;
                                      end;
run;

proc sort data=w&f.09 out=w&f.10;
     by hhid00;
run;

data w&f.11;
     set w&f.10;
     retain hhn&f;
     by hhid00;
     if first.hhid00 then do;
                            hhn&f=0;
                          end;
     if n&f=0 then hhn&f=hhn&f+2;
        else if n&f=1 then hhn&f=hhn&f+1;
     if last.hhid00 then output;
run;

data w&f.final (keep=hhid00 n&f c&f);
     set w&f.11;
     n&f=hhn&f;

     if n&f>1 then c&f=1;
        else c&f=0;

     label n&f="num: missing parents by child (may exceed 2)"
           c&f="cat: child with parent absent in hh";

run;

** Coding for Categorical Variable: 0=no children missing parents in hh
                                    1=at least 1 child missing parent in hh **;

********************************************************************************************************;
** a04: multiple households living on same plot **;

%let f=a04;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_65 x6_65hh:);
     if x6_65hh7 ^in ("999","  .") then n&f=7;
        else if x6_65hh6 ^in ("999","  .") then n&f=6;
             else if x6_65hh5 ^in ("999","  .") then n&f=5;
                  else if x6_65hh4 ^in ("999","  .") then n&f=4;
                       else if x6_65hh3 ^in ("999","  .") then n&f=3;
                            else if x6_65hh2 ^in ("999","  .") then n&f=2;
                                    else if x6_65hh1 ^in ("999","  .") then n&f=1;
                                         else n&f=0;
     if n&f>0 then c&f=1;
        else c&f=0;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: number of households on same plot"
           c&f="cat: multiple households on same plot";
run;

** Coding for Categorical Variable: 0=only 1 household on plot
                                    1=more than 1 household on plot **;

********************************************************************************************************;
** a05: dependency ratio of hh  **;

%let f=a05;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f.c n&f.e n&f.w);
     set in&y.01.indiv00 (keep=hhid00 x3 code2);
     if x3 in (1:97) then n&f.age=x3;
        else n&f.age=.;
     if n&f.age<13 then n&f.c=1;
        else n&f.c=0;
     if n&f.age>55 then n&f.e=1;
        else n&f.e=0;
     if (n&f.age>12 and n&f.age<56) then n&f.w=1;
        else n&f.w=0;
     if code2 ne 1;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 hhn&f.c hhn&f.e hhn&f.w);
     set w&f.02;
     retain hhn&f.c hhn&f.e hhn&f.w;
     by hhid00;
     if first.hhid00 then do;
                            hhn&f.c=0;
                            hhn&f.e=0;
                            hhn&f.w=0;
                          end;
     if n&f.c=1 then hhn&f.c=hhn&f.c+1;
     if n&f.e=1 then hhn&f.e=hhn&f.e+1;
     if n&f.w=1 then hhn&f.w=hhn&f.w+1;
     if last.hhid00 then output;
run;

data w&f.04 (keep=hhid00 n&f c&f);
     set w&f.03;
     n&f.d=sum (of hhn&f.c hhn&f.e);
     n&f.w=hhn&f.w;  
     if n&f.w=0 then n&f.w=.1;
     n&f=n&f.d/n&f.w;
     if n&f<1 then c&f=0;
        else if n&f=1 then c&f=1;
        else if n&f>1 then c&f=2;
        else c&f=.;
run;

data w&f.final;
     set w&f.04;
     label n&f="num: dependency ratio (working age 13-55)"
           c&f="cat: dependency ratio greater than 1 (working age 13-55)";     
run;

** Coding for Categorical Variable: 0=dependency ratio less than 1
                                    1=dependency ratio equal to 1
			               2=dependency ratio greater than 1 **;

*******************************************************************************************************;
** a06: Assets: refrigerator **;

%let f=a06;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a11 x6_4a12);
     if x6_4a11 in (0:3) then n&f.1d=x6_4a11;
        else n&f.1d=.;
     if x6_4a12 in (0:3) then n&f.2d=x6_4a12;
        else n&f.2d=.;
     n&f=sum(of n&f.1d n&f.2d);
     if n&f>0 then c&f=1;
        else c&f=0;                           ** codes missing to zero **;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: refrigerators"
           c&f="cat: hh has 1 or more refrigerators";     
run;

** Coding for Categorical Variable: 0=refrigerator: none
                                    1=refrigerator: 1 or more **;

*******************************************************************************************************;
** a07: Assets: Color Television **;

%let f=a07;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a1 x6_4a2);
     if x6_4a1 in (0:6) then n&f.big=x6_4a1;
        else n&f.big=.;
     if x6_4a2 in (0:11) then n&f.sm=x6_4a2;
        else n&f.sm=.;
     n&f=sum(of n&f.big n&f.sm);
     if n&f>0 then c&f=1;
        else c&f=0;                           ** codes missing to zero **;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: color televisions"
           c&f="cat: hh has 1 or more color televisions";     
run;

** Coding for Categorical Variable: 0=color television: none
                                    1=color television: 1 or more **;     

*******************************************************************************************************;
** a08: Assets: Sewing Machine **;

%let f=a08;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a20);
     if x6_4a20 in (0:6) then n&f=x6_4a20;
        else n&f=.;
     if n&f>0 then c&f=1;
        else c&f=0;                           ** codes missing to zero **;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: sewing machine"
           c&f="cat: hh has 1 or more sewing machines";     
run;

** Coding for Categorical Variable: 0=sewing machine: none
                                    1=sewing machine: 1 or more **;     

*******************************************************************************************************;
** a09: Assets: Satellite Dish **;

%let f=a09;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_4a7);
     if x6_4a7 in (0:1) then n&f=x6_4a7;
        else n&f=.;
     if n&f>0 then c&f=1;
        else c&f=0;                           ** codes missing to zero **;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: satellite dish"
           c&f="cat: hh has 1 or more satellite dish";     
run;

** Coding for Categorical Variable: 0=satellite dish: none
                                    1=satellite dish: 1 or more **;     

*******************************************************************************************************;
** a10: Income: Commercial Stall **;

%let f=a10;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_66);
     if x6_66 in (1) then n&f=1;
        else if x6_66 in (2) then n&f=0;
        else n&f=.;
     if n&f>0 then c&f=1;
        else c&f=0;                           ** codes missing to zero **;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: hh operates shop, stall, or peddlers car"
           c&f="cat: hh operates shop, stall, or peddlers car";     
run;

** Coding for Categorical Variable: 0=hh d/n operate shop/stall/peddler car
                                    1=hh operates shop/stall/peddler **;     

*******************************************************************************************************;
** a11: Ag Tech: HH used herbicides on one or more plots **;

%let f=a11;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f.pl);
     set in&y.05.plots00 (keep=hhid00 keep=x6_27);
     if x6_27 in (1) then n&f.pl=1;
        else if x6_27 in (2) then n&f.pl=0;
        else n&f.pl=.;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 hhn&f.pl);
     set w&f.02;
     retain hhn&f.pl;
     by hhid00;
     if first.hhid00 then do;
                            hhn&f.pl=0;
                          end;
     if n&f.pl=1 then hhn&f.pl=hhn&f.pl+1;
     if last.hhid00 then output;
run;

data w&f.04;
     set w&f.03
         in&y.02.hh00 (keep=hhid00);
run;

proc sort data=w&f.04 out=w&f.05 nodupkey;
     by hhid00;
run;

data w&f.06 (keep=hhid00 n&f c&f);
     set w&f.05;
     if hhn&f.pl=. then n&f=0;     ** codes missing to zero along with hhs that used no land **;
        else n&f=hhn&f.pl;    
     if n&f>0 then c&f=1;
        else c&f=0;      
run;

data w&f.final;
     set w&f.06;
     label n&f="num: hh plots on which hh used herbicide"
           c&f="cat: hh used herbicide on one or more plots";     
run;

** Coding for Categorical Variable: 0=hh d/n use herbicide on any plot
                                    1=hh used herbicide on one or more plots **;     

*******************************************************************************************************;
** a12: Ag Tech: HH used chemical fertilizer on one or more plots **;

%let f=a12;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f.pl);
     set in&y.05.plots00 (keep=hhid00 keep=x6_25);
     if x6_25 in (1) then n&f.pl=1;
        else if x6_25 in (2) then n&f.pl=0;
        else n&f.pl=.;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 hhn&f.pl);
     set w&f.02;
     retain hhn&f.pl;
     by hhid00;
     if first.hhid00 then do;
                            hhn&f.pl=0;
                          end;
     if n&f.pl=1 then hhn&f.pl=hhn&f.pl+1;
     if last.hhid00 then output;
run;

data w&f.04;
     set w&f.03
         in&y.02.hh00 (keep=hhid00);
run;

proc sort data=w&f.04 out=w&f.05 nodupkey;
     by hhid00;
run;

data w&f.06 (keep=hhid00 n&f c&f);
     set w&f.05;
     if hhn&f.pl=. then n&f=0;     ** codes missing to zero along with hhs that used no land **;
        else n&f=hhn&f.pl;    
     if n&f>0 then c&f=1;
        else c&f=0;      
run;

data w&f.final;
     set w&f.06;
     label n&f="num: hh plots on which hh used chemical fertilizer"
           c&f="cat: hh used chemical fertilizer on one or more plots";     
run;

** Coding for Categorical Variable: 0=hh d/n use chemical fertilizer on any plot
                                    1=hh used chemical fertilizer on one or more plots **;     

*******************************************************************************************************;
** a13: Ag Tech: HH used pesticides on one or more plots **;

%let f=a13;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f.pl);
     set in&y.05.plots00 (keep=hhid00 keep=x6_26);
     if x6_26 in (1) then n&f.pl=1;
        else if x6_26 in (2) then n&f.pl=0;
        else n&f.pl=.;
run;

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.03 (keep=hhid00 hhn&f.pl);
     set w&f.02;
     retain hhn&f.pl;
     by hhid00;
     if first.hhid00 then do;
                            hhn&f.pl=0;
                          end;
     if n&f.pl=1 then hhn&f.pl=hhn&f.pl+1;
     if last.hhid00 then output;
run;

data w&f.04;
     set w&f.03
         in&y.02.hh00 (keep=hhid00);
run;

proc sort data=w&f.04 out=w&f.05 nodupkey;
     by hhid00;
run;

data w&f.06 (keep=hhid00 n&f c&f);
     set w&f.05;
     if hhn&f.pl=. then n&f=0;     ** codes missing to zero along with hhs that used no land **;
        else n&f=hhn&f.pl;    
     if n&f>0 then c&f=1;
        else c&f=0;      
run;

data w&f.final;
     set w&f.06;
     label n&f="num: hh plots on which hh used pesticide"
           c&f="cat: hh used pesticide on one or more plots";     
run;

** Coding for Categorical Variable: 0=hh d/n use pesticide on any plot
                                    1=hh used pesticide on one or more plots **;     

*******************************************************************************************************;
** a14: Ag Tech: HH used irrigation **;

%let f=a14;  ** update with each new variable **;

data w&f.01 (keep=hhid00 n&f c&f);
     set in&y.02.hh00 (keep=hhid00 x6_78 x6_79 x6_80);
     if x6_78 in (1) then n&f.i1=1;
        else if x6_78 in (2,8) then n&f.i1=0;
        else n&f.i1=.;
     if x6_79 in (1) then n&f.i2=1;
        else if x6_79 in (2,8) then n&f.i2=0;
        else n&f.i2=.;
     if x6_80 in (1) then n&f.i3=1;
        else if x6_80 in (2,8) then n&f.i3=0;
        else n&f.i3=.;

     n&f=sum(of n&f.i1 n&f.i2 n&f.i3);

     if n&f>0 then c&f=1;
        else c&f=0;      

proc sort data=w&f.01 out=w&f.02;
     by hhid00;
run;

data w&f.final;
     set w&f.02;
     label n&f="num: # irrigation methods used by hh"
           c&f="cat: hh uses any irrigation/water diversion";     
run;

** Coding for Categorical Variable: 0=hh d/n use any irrigation/water diversion
                                    1=hh uses irrigation/water diversion **;     

*******************************************************************************************************;
** MERGE ALL VARIABLES WITH PREFIX "A" INTO A SINGLE FILE **;

%let f=a00;  ** update with each new variable **;

data w&f.01;
     merge wa01final (in=a)
           wa02final (in=b)
           wa03final (in=c) 
           wa04final (in=d)
           wa05final (in=e)
           wa06final (in=f)
           wa07final (in=g)
           wa08final (in=h)
           wa09final (in=i)
           wa10final (in=j)
           wa11final (in=k)
           wa12final (in=l)
           wa13final (in=m)
           wa14final (in=o)
;
     by hhid00;
     if a=1 then output;
run;

data ot&y.01.p03_00_a;
     set w&f.01;
run;

********************************************************************************************************;
** CREATE A STATA DATASET **;

data p03_00_a;
     set w&f.01;
run;

%include "/home/jhull/public/sasmacros/savastata.mac";

%savastata(/home/jhull/nangrong/data_sas/p03_gom/current/,-x -replace);

