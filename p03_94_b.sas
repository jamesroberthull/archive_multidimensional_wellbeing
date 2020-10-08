*********************************************************************
**     Program Name: /home/jhull/nangrong/prog_sas/p01_rice/p01_9401.sas
**     Programmer: james r. hull
**     Start Date: 2010 11 23 (Rework of 2009 December 5)
**     Purpose:
**        1.) Produce a household-level dataset for the 1994 data
**		to be used in an regression analysis on monetized rice labor
**
**     Input Data:
**		'/home/jhull/nangrong/data_sas/1994/current/hh94.xpt'
**		'/home/jhull/nangrong/data_sas/1994/current/helprh94.xpt'
**		'/home/jhull/nangrong/data_sas/1994/current/indiv94.xpt'
**		'/home/jhull/nangrong/data_sas/1994/current/comm94.xpt'
**		'/home/jhull/nangrong/data_sas/1994/current/plots94.xpt'
**		'/home/jhull/nangrong/data_sas/1984/current/hh84.xpt'
**
**     Output Data:
**		'/home/jhull/nangrong/data_sas/p01_rice/current/p01_9401.xpt'
**		'/home/jhull/nangrong/data_sas/p01_rice/current/p01_9402.xpt'
**		'/home/jhull/nangrong/data_sas/p01_rice/current/p01_9403.xpt'
**		'/home/jhull/nangrong/data_sas/p01_rice/current/p01_9406.xpt'
**
**     Notes:
**        1.) This file compiles all previous files and supercedes them
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

%let f=01;    ** Allows greater file portability **;
%let y=94;    ** Allows greater file portability **;

**********************
**  Data Libraries  **
**********************;

libname in&y.&f.01 xport '/home/jhull/nangrong/data_sas/1994/current/hh94.xpt';
libname in&y.&f.02 xport '/home/jhull/nangrong/data_sas/1994/current/helprh94.xpt';
libname in&y.&f.03 xport '/home/jhull/nangrong/data_sas/1994/current/indiv94.xpt';
libname in&y.&f.04 xport '/home/jhull/nangrong/data_sas/1994/current/comm94.xpt';
libname in&y.&f.05 xport '/home/jhull/nangrong/data_sas/1994/current/plots94.xpt';

libname in&y.&f.06 xport '/home/jhull/nangrong/data_sas/1984/current/hh84.xpt';

libname ot&y.&f.01 xport '/home/jhull/nangrong/data_sas/p01_rice/current/p01_9401.xpt';
libname ot&y.&f.02 xport '/home/jhull/nangrong/data_sas/p01_rice/current/p01_9402.xpt';
libname ot&y.&f.03 xport '/home/jhull/nangrong/data_sas/p01_rice/current/p01_9403.xpt';
libname ot&y.&f.04 xport '/home/jhull/nangrong/data_sas/p01_rice/current/p01_9406.xpt';


***c2_94_01*****************************************************************************************;
****************************************************************************************************;

** This data step brings in hh var's and renames **;

data work&y.&f.01;     
     set in&y.&f.01.hh94 (keep=hhid94 hhtype94 lekti84 vill84 
                               house84 hhid84 lekti94 vill94
                               Q6_16 Q6_17 Q6_18 Q6_19 Q6_20 
                               Q6_21 Q6_22 Q6_23 Q6_23A: Q6_23B: 
                               Q6_23C: Q6_23D:);
     rename Q6_16=RICE Q6_23=HELP23B Q6_23A1=HELP23C1 Q6_23A2=HELP23C2
            Q6_23A3=HELP23C3 Q6_23A4=HELP23C4 Q6_23A5=HELP23C5
            Q6_23B1=HELP23D1 Q6_23B2=HELP23D2 Q6_23B3=HELP23D3
            Q6_23B4=HELP23D4 Q6_23B5=HELP23D5 Q6_23C1=HELP23F1
            Q6_23C2=HELP23F2 Q6_23C3=HELP23F3 Q6_23C4=HELP23F4
            Q6_23C5=HELP23F5 Q6_23D1=HELP23G1 Q6_23D2=HELP23G2
            Q6_23D3=HELP23G3 Q6_23D4=HELP23G4 Q6_23D5=HELP23G5;

            if Q6_24B=97 then Q6_24B=.;          ** One missing value recode **;

run;

********************************************************************
**  Separate helping households into same and different villages  **
********************************************************************;

** This data step brings in rice harvest var's  and adds location var **;

data work&y.&f.02 (drop=Q6_24A2);   
     set in&y.&f.02.helprh94 (keep=hhid94 Q6_24A Q6_24B Q6_24C Q6_24D Q6_24E);

     if substr(Q6_24A,1,3)='000' then LOCATION=1;  ** outside village **;
        else if Q6_24A in ('9999997','9999999') then LOCATION=.;  ** missing **;
        else LOCATION=0; ** inside village **;
run;

** Splits rice harvest file into 3 files based on location variable **;

data village othervi noinfo;
     set work&y.&f.02;
     if LOCATION=0 then output village;
        else if LOCATION=1 then output othervi;
        else output noinfo;
run;

*******************************************************************
**  Un-stack data in helprh94 to create single cases for each HH **
*******************************************************************;

** File othervi - max number of variables is 4 **;

data work&y.&f.03 (keep=HELPOC1-HELPOC4 HELPOE1-HELPOE4 HELPOD1-HELPOD4
     HELPOF1-HELPOF4 HELPOG1-HELPOG4 HHID94);
     set othervi (rename=(Q6_24A=HELPOC Q6_24B=HELPOE Q6_24C=HELPOD
      Q6_24D=HELPOF Q6_24E=HELPOG));

   by HHID94;

   length HELPOC1-HELPOC4 $ 7;

   retain HELPOC1-HELPOC4 HELPOE1-HELPOE4 HELPOD1-HELPOD4
          HELPOF1-HELPOF4 HELPOG1-HELPOG4 i;

   array c(1:4) HELPOC1-HELPOC4;
   array e(1:4) HELPOE1-HELPOE4;
   array d(1:4) HELPOD1-HELPOD4;
   array f(1:4) HELPOF1-HELPOF4;
   array g(1:4) HELPOG1-HELPOG4;

   if first.HHID94 then do;
                           do j=1 to 4;
                              c(j)='       ';
                              e(j)=.;
                              d(j)=.;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELPOC;
   e(i)=HELPOE;
   d(i)=HELPOD;
   f(i)=HELPOF;
   g(i)=HELPOG;


   i=i+1;

   if last.HHID94 then output;

run;

** File village - maximum number of variables is 50 **;

data work&y.&f.04 (keep=HELPVC1-HELPVC50 HELPVE1-HELPVE50 HELPVD1-HELPVD50
     HELPVF1-HELPVF50 HELPVG1-HELPVG50 HHID94);
     set village (rename=(Q6_24A=HELPVC Q6_24B=HELPVE Q6_24C=HELPVD
      Q6_24D=HELPVF Q6_24E=HELPVG));

   by HHID94;

   length HELPVC1-HELPVC50 $ 7;

   retain HELPVC1-HELPVC50 HELPVE1-HELPVE50 HELPVD1-HELPVD50
          HELPVF1-HELPVF50 HELPVG1-HELPVG50 i;

   array c(1:50) HELPVC1-HELPVC50;
   array e(1:50) HELPVE1-HELPVE50;
   array d(1:50) HELPVD1-HELPVD50;
   array f(1:50) HELPVF1-HELPVF50;
   array g(1:50) HELPVG1-HELPVG50;

   if first.HHID94 then do;
                           do j=1 to 50;
                              c(j)='       ';
                              e(j)=.;
                              d(j)=.;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELPVC;
   e(i)=HELPVE;
   d(i)=HELPVD;
   f(i)=HELPVF;
   g(i)=HELPVG;


   i=i+1;

   if last.HHID94 then output;

run;

** File noinfo - maximum number of variables is 2 **;

data work&y.&f.05 (keep=HELPXC1-HELPXC2 HELPXE1-HELPXE2 HELPXD1-HELPXD2
     HELPXF1-HELPXF2 HELPXG1-HELPXG2 HHID94);
     set noinfo (rename=(Q6_24A=HELPXC Q6_24B=HELPXE Q6_24C=HELPXD
      Q6_24D=HELPXF Q6_24E=HELPXG));

   by HHID94;

   length HELPXC1-HELPXC2 $ 7;

   retain HELPXC1-HELPXC2 HELPXE1-HELPXE2 HELPXD1-HELPXD2
          HELPXF1-HELPXF2 HELPXG1-HELPXG2 i;

   array c(1:2) HELPXC1-HELPXC2;
   array e(1:2) HELPXE1-HELPXE2;
   array d(1:2) HELPXD1-HELPXD2;
   array f(1:2) HELPXF1-HELPXF2;
   array g(1:2) HELPXG1-HELPXG2;

   if first.HHID94 then do;
                           do j=1 to 2;
                              c(j)='       ';
                              e(j)=.;
                              d(j)=.;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELPXC;
   e(i)=HELPXE;
   d(i)=HELPXD;
   f(i)=HELPXF;
   g(i)=HELPXG;


   i=i+1;

   if last.HHID94 then output;

run;

** Merge previous 3 rice help data files with main hh-level file **;

data work&y.&f.06 nowork;
   merge
   work&y.&f.01 (in=a)
   work&y.&f.03 (in=b)
   work&y.&f.04 (in=c)
   work&y.&f.05 (in=d);
   by HHID94;
   if a=1 then output work&y.&f.06;
   if a=0 then output nowork;
run;

** This hh-level data step recodes missing values and creates several variables **;

data work&y.&f.07 (drop=i j k HELPVB1-HELPVB50 HELPVAT             
     HELPVT1-HELPVT50 HELPOB1-HELPOB4 HELPOAT
     HELPOET1-HELPOET4);

     set work&y.&f.06;

     if HELP23B=8 then HELP23B=0;

     if HELP23B > 0 then HELP23A=1;
        else HELP23A=0;

     array c(1:5) HELP23C1-HELP23C5;
     array d(1:5) HELP23D1-HELP23D5;
     array f(1:5) HELP23F1-HELP23F5;
     array g(1:5) HELP23G1-HELP23G5;

     array vb(1:50) HELPVB1-HELPVB50;
     array vc(1:50) HELPVC1-HELPVC50;
     array vd(1:50) HELPVD1-HELPVD50;
     array ve(1:50) HELPVE1-HELPVE50;
     array vet(1:50) HELPVT1-HELPVT50;
     array vg(1:50) HELPVG1-HELPVG50;

     array ob(1:4) HELPOB1-HELPOB4;
     array oc(1:4) HELPOC1-HELPOC4;
     array od(1:4) HELPOD1-HELPOD4;
     array oe(1:4) HELPOE1-HELPOE4;
     array oet(1:4) HELPOET1-HELPOET4;
     array og(1:4) HELPOG1-HELPOG4;

     do i=1 to 5;
        if c(i)='998' then c(i)='   ';
           else if c(i)='999' then c(i)='   ';
        if d(i)=98 then d(i)=.;
           else if d(i)=99  then d(i)=1;
        if f(i)=8 then f(i)=.;
           else if f(i)=9 then f(i)=.;
        if g(i)=996 then g(i)=.;
           else if g(i)=998 then g(i)=.;
           else if g(i)=999 then g(i)=1;
     end;

     do j=1 to 50;
        if vd(j)=99 then vd(j)=1;
        if ve(j)=99 then ve(j)=1;
        if vg(j)=996 then vg(j)=.;
           else if vg(j)=998 then vg(j)=.;
           else if vg(j)=999 then vg(j)=1;
        if vc(j) ne '       ' then vb(j)=1;
           else vb(j)=0;
        if ve(j)=. then vet(j)=0;
           else vet(j)=ve(j);
     end;

     do k=1 to 4;
        if od(k)=99 then od(k)=1;
        if oe(k)=99 then oe(k)=1;
        if og(k)=996 then og(k)=.;
           else if og(k)=998 then og(k)=.;
           else if og(k)=999 then og(k)=1;
        if oc(k) ne '       ' then ob(k)=1;
           else ob(k)=0;
        if oe(k)=. then oet(k)=0;
           else oet(k)=oe(k);
     end;

     HELPVAT = sum(of HELPVB1-HELPVB50);

     if HELPVAT > 0 then HELPVA=1;
        else if HELPVAT = 0 then HELPVA = 0;
        else HELPVA=.;                       ** There should be no missing values **;
 
     HELPVB= sum(of HELPVT1-HELPVT50);  ** should not produce a missing-value operation error **;

     HELPOAT = HELPOB1+HELPOB2+HELPOB3+HELPOB4;

     if HELPOAT > 0 then HELPOA=1;
        else if HELPOAT = 0 then HELPOA = 0;
        else HELPOA=.;

     HELPOB=sum(of HELPOET1-HELPOET4);

     TOTHELP=HELP23B+HELPVB+HELPOB;

     if HELP23B = 0 then HELP23B =.;
     if HELPOB = 0 then HELPOB = .;
     if HELPVB = 0 then HELPVB =.;

     if RICE=2 then RICE=0;   

     label HELP23A='Code 2 & 3 HH members helped harvest';
     label HELPOA='Other villages helped harvest';
     label HELPOB='# other villagers who helped';
     label HELPVA='Villagers helped harvest';
     label HELPVB='# Villagers who helped';

     if Q6_17 in (99999,99998) then Q6_17=.;
     if Q6_18=99 then Q6_18=.;
     if Q6_19=99 then Q6_19=.;
     if Q6_20=99 then Q6_20=.;
     if Q6_21=9999 then Q6_21=.;
     if Q6_22=9999 then Q6_22=.;

run;

** This data step creates the original three dependent variables **;

data work&y.&f.08 (drop= i j k);
     set work&y.&f.07;

     array f(1:5) HELP23F1-HELP23F5;
     array vf(1:50) HELPVF1-HELPVF50;
     array of(1:4) HELPOF1-HELPOF4;

     HELPVH_1=0;
     HELPVH_2=0;
     HELPVH_3=0;
     HELPOH_1=0;
     HELPOH_2=0;
     HELPOH_3=0;
     HELP2H_1=0;
     HELP2H_2=0;
     HELP2H_3=0;

     do k=1 to 5;
        if f(k)=1 then HELP2H_1=HELP2H_1+1;
           else if f(k)=2 then HELP2H_2=HELP2H_2+1;
           else if f(k)=3 then HELP2H_3=HELP2H_3+1;
     end;

     do i=1 to 50;
        if vf(i)=1 then HELPVH_1=HELPVH_1+1;
           else if vf(i)=2 then HELPVH_2=HELPVH_2+1;
           else if vf(i)=3 then HELPVH_3=HELPVH_3+1;
     end;

     do j=1 to 4;
        if of(j)=1 then HELPOH_1=HELPOH_1+1;
           else if of(j)=2 then HELPOH_2=HELPOH_2+1;
           else if of(j)=3 then HELPOH_3=HELPOH_3+1;
     end;


     if HELPVH_1>0 then HELPVH=1;
        else if HELPVH_2>0 | HELPVH_3>0 then HELPVH=2;
                              else HELPVH=.;

     if HELPOH_1>0 then HELPOH=1;
        else if HELPOH_2>0 | HELPOH_3>0 then HELPOH=2;
                              else HELPOH=.;

     label HELPVH= 'Used village labor 1=paid 2=unpaid';
     label HELPOH= 'Used non-village labor 1=paid 2=unpaid';

     if RICE=0 then HELPDV=1;
        else if RICE=. then HELPDV=.;
        else if HELP23A=0 & HELPVA=0 & HELPOA=0 then HELPDV=2;
        else if HELP23A=1 & HELPVA=0 & HELPOA=0 then HELPDV=3;
        else if (HELPVH ne 1 & HELPOH ne 1) & (HELPVA=1 or HELPOA=1) then HELPDV=4;
        else if HELPVH=1 & HELPOH ne 1 then HELPDV=5;
        else if HELPOH=1 & HELPVH ne 1 then HELPDV=6;
        else if HELPVH=1 & HELPOH=1 then HELPDV=7;

     if RICE=0 then HELPDV2=1;
        else if RICE=. then HELPDV2=.;
        else if HELP23A=0 & HELPVA=0 & HELPOA=0 then HELPDV2=2;
        else if HELP23A=1 & HELPVA=0 & HELPOA=0 then HELPDV2=3;
        else if (HELPVH ne 1 & HELPOH ne 1) & (HELPVA=1 or HELPOA=1) then HELPDV2=3;
        else if HELPVH=1 & HELPOH ne 1 then HELPDV2=4;
        else if HELPOH=1 & HELPVH ne 1 then HELPDV2=4;
        else if HELPVH=1 & HELPOH=1 then HELPDV2=4;

     if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0)
              & (HELP2H_2=0 & HELPVH_2=0 & HELPOH_2=0)
              & (HELP2H_3=0 & HELPVH_3=0 & HELPOH_3=0) then HELPTYPE=1;
        else if (HELP2H_1=0 & HELPVH_1=0 & HELPOH_1=0)
              & (HELP2H_2>0 | HELPVH_2>0 | HELPOH_2>0)
              & (HELP2H_3=0 & HELPVH_3=0 & HELPOH_3=0) then HELPTYPE=2;
        else if (HELP2H_1=0 & HELPVH_1=0 & HELPOH_1=0)
              & (HELP2H_2=0 & HELPVH_2=0 & HELPOH_2=0)
              & (HELP2H_3>0 | HELPVH_3>0 | HELPOH_3>0) then HELPTYPE=3;
        else if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0)
              & (HELP2H_2>0 | HELPVH_2>0 | HELPOH_2>0)
              & (HELP2H_3=0 & HELPVH_3=0 & HELPOH_3=0) then HELPTYPE=4;
        else if (HELP2H_1=0 & HELPVH_1=0 & HELPOH_1=0)
              & (HELP2H_2>0 | HELPVH_2>0 | HELPOH_2>0)
              & (HELP2H_3>0 | HELPVH_3>0 | HELPOH_3>0) then HELPTYPE=5;
        else if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0)
              & (HELP2H_2=0 & HELPVH_2=0 & HELPOH_2=0)
              & (HELP2H_3>0 | HELPVH_3>0 | HELPOH_3>0) then HELPTYPE=6;
        else if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0)
              & (HELP2H_2>0 | HELPVH_2>0 | HELPOH_2>0)
              & (HELP2H_3>0 | HELPVH_3>0 | HELPOH_3>0) then HELPTYPE=7;
        else HELPTYPE=.;

    if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0) then HELPDV3=1;
       else if RICE=1 then HELPDV3=0;
       else HELPDV3=.;

run;

proc sort data=work&y.&f.08 out=work&y.&f.09;
     by VILL84;
run;


**************************************************************************
*** CREATE AGGREGATE MEASURES OF PERSONS, PERSON-DAYS, AND TOTAL WAGES ***
**************************************************************************;

*** At some point, I will label these newly created variables like a good boy ***;
*** For now, I'll just note that P=persons, PD=Person-Days, and T=Total Wages ***;
*** The rest should be self-explanatory, unless I hit my head really hard     ***;
*** PAID, FREE, and EXCH refer to Type of Labor, V, O, and 2 to Labor Source  ***;

data work&y.&f.10 (drop= i j k);
     set work&y.&f.09;

     array d(1:5) HELP23D1-HELP23D5;
     array vd(1:50) HELPVD1-HELPVD50;
     array od(1:4) HELPOD1-HELPOD4;

     array ve(1:50) HELPVE1-HELPVE50;
     array oe(1:4) HELPOE1-HELPOE4;

     array f(1:5) HELP23F1-HELP23F5;
     array vf(1:50) HELPVF1-HELPVF50;
     array of(1:4) HELPOF1-HELPOF4;

     array g(1:5) HELP23G1-HELP23G5;
     array vg(1:50) HELPVG1-HELPVG50;
     array og(1:4) HELPOG1-HELPOG4;

     PAIDPD_2=0;
     FREEPD_2=0;
     EXCHPD_2=0;
     PAIDPD_V=0;
     FREEPD_V=0;
     EXCHPD_V=0;
     PAIDPD_O=0;
     FREEPD_O=0;
     EXCHPD_O=0;

     PAID_P_2=0;
     FREE_P_2=0;
     EXCH_P_2=0;
     PAID_P_V=0;
     FREE_P_V=0;
     EXCH_P_V=0;
     PAID_P_O=0;
     FREE_P_O=0;
     EXCH_P_O=0;

     PAID_T_2=0;
     PAID_T_V=0;
     PAID_T_O=0;


     do i=1 to 5;
        if f(i)=1 then PAIDPD_2=PAIDPD_2+(d(i));
           else if f(i)=2 then FREEPD_2=FREEPD_2+(d(i));
           else if f(i)=3 then EXCHPD_2=EXCHPD_2+(d(i));
     end;

     do j=1 to 50;
        if vf(j)=1 then PAIDPD_V=PAIDPD_V+(vd(j)*ve(j));
           else if vf(j)=2 then FREEPD_V=FREEPD_V+(vd(j)*ve(j));
           else if vf(j)=3 then EXCHPD_V=EXCHPD_V+(vd(j)*ve(j));
     end;

     do k=1 to 4;
        if of(k)=1 then PAIDPD_O=PAIDPD_O+(od(k)*oe(k));
           else if of(k)=2 then FREEPD_O=FREEPD_O+(od(k)*oe(k));
           else if of(k)=3 then EXCHPD_O=EXCHPD_O+(od(k)*oe(k));
     end;


     do i=1 to 5;
        if f(i)=1 then PAID_P_2=PAID_P_2+1;
           else if f(i)=2 then FREE_P_2=FREE_P_2+1;
           else if f(i)=3 then EXCH_P_2=EXCH_P_2+1;
     end;

     do j=1 to 50;
        if vf(j)=1 then PAID_P_V=PAID_P_V+ve(j);
           else if vf(j)=2 then FREE_P_V=FREE_P_V+ve(j);
           else if vf(j)=3 then EXCH_P_V=EXCH_P_V+ve(j);
     end;

     do k=1 to 4;
        if of(k)=1 then PAID_P_O=PAID_P_O+oe(k);
           else if of(k)=2 then FREE_P_O=FREE_P_O+oe(k);
           else if of(k)=3 then EXCH_P_O=EXCH_P_O+oe(k);
     end;


     do i=1 to 5;
        if f(i)=1 then PAID_T_2=PAID_T_2+(d(i)*g(i));
     end;

     do j=1 to 50;
        if vf(j)=1 then PAID_T_V=PAID_T_V+(vd(j)*ve(j)*vg(j));
     end;

     do k=1 to 4;
        if of(k)=1 then PAID_T_O=PAID_T_O+(od(k)*oe(k)*og(k));
     end;


     PAID_P=PAID_P_2+PAID_P_V+PAID_P_O;
     FREE_P=FREE_P_2+FREE_P_V+FREE_P_O;
     EXCH_P=EXCH_P_2+EXCH_P_V+EXCH_P_O;

     PAIDPD=PAIDPD_2+PAIDPD_V+PAIDPD_O;
     FREEPD=FREEPD_2+FREEPD_V+FREEPD_O;
     EXCHPD=EXCHPD_2+EXCHPD_V+EXCHPD_O;

     PAID_T=PAID_T_2+PAID_T_V+PAID_T_O;
     ALL_P=PAID_P+FREE_P+EXCH_P;
     ALL_PD=PAIDPD+FREEPD+EXCHPD;

     if RICE=1 then HELPDV4=ALL_P;
        else HELPDV4=.;

run;

proc sort data=work&y.&f.10 out=work&y.&f.10B;
     by HHID94;
run;

** Save out first dataset p01_9401 **;

data ot&y.&f.01.p01_9401;
     set work&y.&f.10B;
run;


***c2_94_02****MIGRATION VARS*********************************************;
**************************************************************************;

*-------------------------*
*  Merge INDIV00 to HH00  *
*-------------------------*;

***Note: this becomes an individual-level file***;

data work&y.&f.11;
     merge in&y.&f.01.hh94(keep=HHID94 VILL94 DATE in=a)
           in&y.&f.03.indiv94(keep=HHID94 VILL94 LEKTI94 
                                   CEP94 Q1 Q3 Q27 Q29 Q30: 
                                   Q31 Q33 Q34: Q10D Q10M Q10Y in=b);
     by HHID94;

     if (a=1 and b=1) and (Q1=3);

     DATECHAR=right(put(DATE,6.));

     if substr(DATECHAR,1,1)=' ' then substr(DATECHAR,1,1)='0';

*** Create YEAR, MONTH, and DAY ***;

     DAY=substr(DATECHAR,1,2);
     MONTH=substr(DATECHAR,3,2);
     YEAR=1994;

*** Create IDATE, HDATE DDATE ***;

      if MONTH in ("99","  ") or DAY in ("99","  ") then IDATE=.;        ** IDATE = interview date **;
         else IDATE=MDY(MONTH,DAY,YEAR);

      HDATE=MDY(10,1,1993);                                              ** HDATE = Harvest begins **;

      if IDATE=. or HDATE=. then DDATE=.;
         else DDATE=IDATE-HDATE;                                         ** DDATE = Difference in # days **;

*** Transform DDATE to months ***;
                                                                         ** DMONTH = # days rounded **;
      if DDATE=. then DMONTH=.;
         else DMONTH=round(DDATE/30);

*** Create # Days Away ***;

      if (Q10D in (98,99) or Q10M in (98,99) or Q10Y in (98,99)) or (Q10M=. and Q10Y=.) then DAYSGONE=99999;
         else if (Q10D=. and Q10Y ne .) then DAYSGONE=(Q10Y*365);
         else DAYSGONE=Q10D+(Q10M*30)+(Q10Y*365);

*** Round # days gone to months ***;

      if Q10D=99 then MOROUND=9;
         else if Q10D=. then MOROUND=.;
         else if Q10D<16 then MOROUND=0;
         else if Q10D>=16 then MOROUND=1;

*** Create variable # months gone ***;

      if (Q10D in (98,99) or Q10M in (98,99) or Q10Y in (98,99)) or (Q10M=. and Q10Y=.) then MOGONE=9999;
         else if (Q10D=. and Q10Y ne .) then MOGONE=(Q10Y*12);
         else MOGONE=MOROUND+Q10M+(Q10Y*12);

*** Create variable # years gone ***;   

     if MOGONE < 12 then YRGONE=0;
        else if MOGONE > 11 and MOGONE < 24 then YRGONE=1;
        else if MOGONE > 23 and MOGONE < 36 then YRGONE=2;
        else if MOGONE > 35 and MOGONE < 48 then YRGONE=3;
        else if MOGONE > 47 and MOGONE < 60 then YRGONE=4;
        else if MOGONE > 59 and MOGONE < 72 then YRGONE=5;
        else if MOGONE > 71 and MOGONE < 84 then YRGONE=6;
        else if MOGONE > 83 and MOGONE < 96 then YRGONE=7;
        else if MOGONE > 95 and MOGONE < 108 then YRGONE=8;
        else if MOGONE > 107 and MOGONE < 120 then YRGONE=9;
        else if MOGONE > 119 and MOGONE < 132 then YRGONE=10;
        else if MOGONE > 131 and MOGONE < 144 then YRGONE=11;
        else if MOGONE > 143 and MOGONE < 156 then YRGONE=12;
        else if MOGONE > 155 and MOGONE < 168 then YRGONE=13;
        else if MOGONE > 167 and MOGONE < 9999 then YRGONE=14;
        else if MOGONE in (9999) then YRGONE=99;

*** Compare Months gone to time since 10/1/1999 ***;

      if MOGONE=9999 then RICEMIG=9;
         else if (MOGONE > DMONTH and MOGONE < 72) then RICEMIG=1;
         else RICEMIG=0;

*** A second variable usinG 3 years as the cut-off, not 6 years ***;

      if MOGONE=9999 then RICEMIG2=9;
         else if (MOGONE > DMONTH and MOGONE < 36) then RICEMIG2=1;
         else RICEMIG2=0;

*** Create numeric equivalents (means) of remittances for aggregation ***;

      if Q29=1 then REMAMT=500;
         else if Q29=2 then REMAMT=2000;
         else if Q29=3 then REMAMT=4000;
         else if Q29=4 then REMAMT=7500;
         else if Q29=5 then REMAMT=15000;
         else if Q29=6 then REMAMT=20000;
         else REMAMT=0;

    if Q29 in (8,9) then Q29=0;          ** old: need to be merged to final dataset - why? 2011 01 18 **;

    if Q33=1 then SNDAMT=500;
         else if Q33=2 then SNDAMT=2000;
         else if Q33=3 then SNDAMT=4000;
         else if Q33=4 then SNDAMT=7500;
         else if Q33=5 then SNDAMT=15000;
         else if Q33=6 then SNDAMT=20000;
         else SNDAMT=0;

    if Q33 in (8,9) then Q33=0;         ** old: need to be merged to final dataset - why? 2011 01 18 **;

run;


 *** Create a HH-level file - Migration and Remittances ***;

data work&y.&f.12;                                                                 
     set work&y.&f.11 (keep=HHID94 Q3 Q27 Q29 Q30: Q31 Q33 Q34: REMAMT SNDAMT RICEMIG RICEMIG2);

     by HHID94;

     keep HHID94 NUMMIGM NUMMIGF NUMMIGT NUMMIGT2 RECMIG RECMIG2
          MISSMIG MISSMIG2 NUMRRCD2 NUMRRCD3 NUMRSND2 NUMRSND3 NUMREMIT NUMREMSD
          REM_ND2 REM_ND3 SREM_ND2 SREM_ND3 TOTRRCD2 TOTRRCD3 TOTRSND2 TOTRSND3 MIGREM_Y MIGREM_N;

     retain NUMMIGM NUMMIGF NUMMIGT NUMMIGT2 RECMIG RECMIG2
            MISSMIG MISSMIG2 NUMRRCD2 NUMRRCD3 NUMRSND2 NUMRSND3 NUMREMIT NUMREMSD
            REM_ND2 REM_ND3 SREM_ND2 SREM_ND3 TOTRRCD2 TOTRRCD3 TOTRSND2 TOTRSND3 MIGREM_Y MIGREM_N;

     if first.HHID94 then do;
                            NUMMIGM=0;
                            NUMMIGF=0;
                            NUMMIGT=0;
                            NUMMIGT2=0;
                            RECMIG=0;
                            RECMIG2=0;
                            MISSMIG=0;
                            MISSMIG2=0;
                            NUMREMIT=0;
                            NUMREMSD=0;
                            NUMRRCD2=0;
                            NUMRRCD3=0;
                            NUMRSND2=0;
                            NUMRSND3=0;
                            REM_ND2=0;
                            REM_ND3=0;
                            SREM_ND2=0;
                            SREM_ND3=0;
                            TOTRRCD2=0;
                            TOTRRCD3=0;
                            TOTRSND2=0;
                            TOTRSND3=0;
                            MIGREM_Y=0;
                            MIGREM_N=0;
                          end;

     if (Q27=1 OR Q30A=1 OR Q30B=1 OR Q30C=1 OR Q30D=1 OR Q30E=1) then NUMREMIT=NUMREMIT+1;
     if (Q31=1 OR Q34A=1 OR Q34B=1 OR Q34C=1 OR Q34D=1 OR Q34E=1) then NUMREMSD=NUMREMSD+1;

     if RICEMIG=1 and (Q27=1 OR Q30A=1 OR Q30B=1 OR Q30C=1 OR Q30D=1 OR Q30E=1) then NUMRRCD2=NUMRRCD2+1;
        else if Q27=9 then REM_ND2=1;

     if RICEMIG=1 and (Q31=1 OR Q34A=1 OR Q34B=1 OR Q34C=1 OR Q34D=1 OR Q34E=1) then NUMRSND2=NUMRSND2+1;
        else if Q31=9 then SREM_ND2=1;

     if RICEMIG2=1 and (Q27=1 OR Q30A=1 OR Q30B=1 OR Q30C=1 OR Q30D=1 OR Q30E=1) then NUMRRCD3=NUMRRCD3+1;
        else if Q27=9 then REM_ND3=1;

     if RICEMIG2=1 and (Q31=1 OR Q34A=1 OR Q34B=1 OR Q34C=1 OR Q34D=1 OR Q34E=1) then NUMRSND3=NUMRSND3+1;
        else if Q31=9 then SREM_ND3=1;

     if RICEMIG=1 and Q3=1 then NUMMIGM=NUMMIGM+1;
        else if RICEMIG=1 and Q3=2 then NUMMIGF=NUMMIGF+1;

     if RICEMIG=1 then NUMMIGT=NUMMIGT+1;
        else if RICEMIG=0 then RECMIG=RECMIG+1;
        else if RICEMIG=9 then MISSMIG=MISSMIG+1;

     if RICEMIG2=1 then NUMMIGT2=NUMMIGT2+1;
        else if RICEMIG2=0 then RECMIG2=RECMIG2+1;
        else if RICEMIG2=9 then MISSMIG2=MISSMIG2+1;

     if RICEMIG=1 then TOTRRCD2=TOTRRCD2+REMAMT;

     if RICEMIG=1 then TOTRSND2=TOTRSND2+SNDAMT;

     if RICEMIG2=1 then TOTRRCD3=TOTRRCD3+REMAMT;

     if RICEMIG2=1 then TOTRSND3=TOTRSND3+SNDAMT;

     if RICEMIG=1 and (Q27=1 OR Q30A=1 OR Q30B=1 OR Q30C=1 OR Q30D=1 OR Q30E=1) then MIGREM_Y=MIGREM_Y+1;
        else if RICEMIG=1 then MIGREM_N=MIGREM_N+1;

     if last.HHID94 then output;
run;


** Merges HHs with migrants to all HH vars in p01_9401 **;

data work&y.&f.13 noricefile;                               
     merge work&y.&f.12 (in=a)
           ot&y.&f.01.p01_9401 (in=b);
     by HHID94;
     if a=0 and b=1 then do;
                           NUMMIGT=0;
                           NUMMIGT2=0;
                           NUMMIGM=0;
                           NUMMIGF=0;
                           MISSMIG=0;
                           MISSMIG2=0;
                           RECMIG=0;
                           RECMIG2=0;
                           NUMREMIT=0;
                           NUMREMSD=0;
                           NUMRRCD2=0;
                           NUMRRCD3=0;
                           NUMRSND2=0;
                           NUMRSND3=0;
                           REM_ND2=0;
                           REM_ND3=0;
                           SREM_ND2=0;
                           SREM_ND3=0;
                           TOTRRCD2=0;
                           TOTRRCD3=0;
                           TOTRSND2=0;
                           TOTRSND3=0;
                           MIGREM_Y=0;
                           MIGREM_N=0;
                         end;

     ** if MISSMIG > 0 then NUMMIG=.; **;  **This line will force a stricter treatment of missing data **;

     if b=1 then output work&y.&f.13;
     if a=1 and b=0 then output noricefile;

run;

** Saves out second data set p01_0002 **;

data ot&y.&f.02.p01_9402;
     set work&y.&f.13;
run;

**c3_94_03******************************************************************************************;
****************************************************************************************************;

*---------------------------------------------*
*  Assemble individual-level origin variables *
*---------------------------------------------*;

data work&y.&f.14 (keep=VILL94 LEKTI94 HHID94 CEP94 Q1
 Q3 Q27 Q31 AGE);
     set in&y.&f.03.indiv94 (keep=VILL94 LEKTI94 HHID94 CEP94 Q1 Q2 Q3 CODE2 Q27 Q31);

     *** Recode specially coded ages to numeric equivalents ***;

     if Q2=99 then AGE=0;
        else if Q2 in (81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91) then AGE=0;
        else if Q2=98 then AGE=.;
        else AGE=Q2;

    *** Remove duplicate code 2 cases - leave destination HH data ***;

    if CODE2 ^in (1,5);

run;

** Creates hh-level file with counts of various hh demographic vars **;

data work&y.&f.15 (keep=VILL94 HHID94 AGETOTAL NUMMEMS NUMMALES NUMFEMS NUMDEPCH NUMDEPEL NUMDEPS M_13_55 F_13_55 CODETWO);
     set work&y.&f.14;

     by HHID94;

     keep VILL94 HHID94 AGETOTAL NUMMEMS NUMMALES NUMFEMS NUMDEPCH NUMDEPEL NUMDEPS M_13_55 F_13_55 CODETWO;

     *** Create variables: # of HH members, # males, # females, mean age ***;

     retain AGETOTAL NUMMEMS NUMMALES NUMFEMS NUMDEPCH NUMDEPEL NUMDEPS M_13_55 F_13_55 CODETWO;

     if first.HHID94 then do;
                            AGETOTAL=0;
                            NUMMEMS=0;
                            NUMMALES=0;
                            NUMFEMS=0;
                            NUMDEPCH=0;
                            NUMDEPEL=0;
                            NUMDEPS=0;
                            M_13_55=0;
                            F_13_55=0;
                            CODETWO=0;
                          end;

     if ((AGE^=.) and (Q1=2)) then CODETWO=CODETWO+1;

     if ((AGE^=.) and (Q1 ^in (0,2,3,9))) then do;

                       if ((13 <= AGE <=55) and (Q3=1))
                          then M_13_55=M_13_55+1;        * Males 13-55 *;

                       if ((13 <= AGE <=55) and (Q3=2))
                          then F_13_55=F_13_55+1;        * Females 13-55 *;

                       if (AGE < 13) then NUMDEPCH=NUMDEPCH+1;
                       if (AGE > 55) then NUMDEPEL=NUMDEPEL+1;

                       NUMDEPS=NUMDEPCH+NUMDEPEL;

                       AGETOTAL=AGETOTAL+AGE;

                       NUMMEMS=NUMMEMS+1;

                       if Q3=1 then NUMMALES=NUMMALES+1;
                          else if Q3=2 then NUMFEMS=NUMFEMS+1;

                     end;

     if last.HHID94 then output;

run;

*** miscellaneous manipulations on formerly indiv-level data ***;

data work&y.&f.16;
     set work&y.&f.15;

     *** calculated HH demography variable ***;

     MEANAGE=AGETOTAL/NUMMEMS;

run;

*---------------------------------------------*
*  Assemble household-level origin variables  *
*---------------------------------------------*;

data work&y.&f.17 (drop=Q6_4SA Q6_4WA Q6_4OA Q6_4CA Q6_10A Q6_10B Q6_10C Q6_26 Q6_22
                    Q6_13: Q6_20 Q6_5: Q6_9D: Q6_9C: WAGE: DAYS:Q6_2: Q6_3 WINDOW);
     set in&y.&f.01.hh94 (keep=vill94 hhid94 Q6_4SA Q6_4WA Q6_4OA Q6_4CA
                             Q6_10A Q6_10B Q6_10C Q6_17 Q6_22 Q6_26
                             Q6_5: Q6_13: Q6_20 Q6_9D: Q6_9C: Q6_2: Q6_3 WINDOW);


     *** HH production variables ***;

     if Q6_4SA=0 then SILK=0;
        else SILK=1;

     if Q6_4WA=0 then SILKWORM=0;
        else SILKWORM=1;

     if Q6_4OA=0 then CLOTH=0;
        else CLOTH=1;

     if Q6_4CA=0 then CHARCOAL=0;
        else CHARCOAL=1;

     if Q6_10A=0 then COWS=0;
        else if Q6_10A=9999 then COWS=.;
        else if Q6_10A>=3000 then COWS=Q6_10A-3000;
        else if Q6_10A>=2000 then COWS=Q6_10A-2000;
        else if Q6_10A>=1000 then COWS=Q6_10A-1000;

     if Q6_10B=0 then BUFFALO=0;
        else if Q6_10B=9999 then BUFFALO=.;
        else if Q6_10B>=3000 then BUFFALO=Q6_10B-3000;
        else if Q6_10B>=2000 then BUFFALO=Q6_10B-2000;
        else if Q6_10B>=1000 then BUFFALO=Q6_10B-1000;

     if Q6_10C=0 then PIGS=0;
        else if Q6_10C=999 then PIGS=.;
        else if Q6_10C>=3000 then PIGS=Q6_10C-3000;
        else if Q6_10C>=2000 then PIGS=Q6_10C-2000;
        else if Q6_10C>=1000 then PIGS=Q6_10C-1000;


     if (COWS>1 or BUFFALO>1 or PIGS>1) then STOCK=1;
        else STOCK=0;

     if Q6_26=2 then CASSAVA=0;
        else if Q6_26=1 then CASSAVA=1;
        else CASSAVA=.;

     if SILK=1 or SILKWORM=1 or CLOTH=1 then COTTAGE=1;
        else COTTAGE=0;

     *** HH assets variables ***;

     LTV1=Q6_5A1;
     STV1=Q6_5B1;
     VIDEO1=Q6_5C1;
     REFRI=Q6_5D1;
     ITAN1=Q6_5E1;
     CAR1=Q6_5F1;
     MOTOR=Q6_5G1;
     SEWM1=Q6_5H1;
     LTRACTOR=Q6_13A2;
     if Q6_13A2 ne 1 then LTRACTOR=0;
     STRACTOR=Q6_13B2;
     if Q6_13B2 ne 1 then STRACTOR=0;

     *** Create a variable measuring ownership of any equipment ***;

        if((Q6_13A2=1) or (Q6_13B2=1) or (Q6_13C2=1) or (Q6_13D2=1) or (Q6_13E2=1)) then EQUIP94=1;
           else EQUIP94=0;

     CASSET1=LTV1*8.513+STV1*6.280+VIDEO1*7.522+REFRI*8.5;
     PASSET1=ITAN1*80+LTRACTOR*483.75+STRACTOR*42.607+SEWM1*6.4;
     PCASSET1=CAR1*626.33+MOTOR*37.82;

     ASSET_T=CASSET1+PASSET1+PCASSET1;


     *** HH Rice Yield ***;

     if Q6_22=9998 then RICE_YLD=0;
        else if Q6_22=9999 then RICE_YLD=.;
        else RICE_YLD=Q6_22;

     *** EXTRA HH RICE AREA VARIABLE AVAILABLE ONLY IN 1994 - COMPARE TO RAI_RICE ***;

     if Q6_17=99995 then RAI_RIC2=(250);
        else if Q6_17=99999 then RAI_RIC2=.;
        else if Q6_17=99998 then RAI_RIC2=0;
        else if Q6_17<100 then RAI_RIC2=0;
                else RAI_RIC2=Q6_17*0.0025;

    *** COUNT OF NUMBER OF RICE PLANTING HELPERS ***;

    if Q6_20 in (97,99) then PLANTNUM=.;
       else if Q6_20=98 then PLANTNUM=0;
       else PLANTNUM=Q6_20;

    *** HH WAGES EARNED IN LOCAL ECONOMY ***;

    if (q6_9D1 ne 999 & q6_9C1 ne 99) then do;
                                       if q6_9D1=998 then WAGE1=0;
                                          else WAGE1=Q6_9D1;
                                       if Q6_9C1=98 then DAYS1=0;
                                          else DAYS1=Q6_9C1;
                                       WAGELAB1=WAGE1*DAYS1;
                                     end;
       else WAGELAB1=.;

    if (q6_9D2 ne 999 & q6_9C2 ne 99) then do;
                                       if q6_9D2=998 then WAGE2=0;
                                          else WAGE2=Q6_9D2;
                                       if Q6_9C2=98 then DAYS2=0;
                                          else DAYS2=Q6_9C2;
                                       WAGELAB2=WAGE2*DAYS2;
                                     end;
       else WAGELAB2=.;

    if (q6_9D3 ne 999 & q6_9C3 ne 99) then do;
                                       if q6_9D3=998 then WAGE3=0;
                                          else WAGE3=Q6_9D3;
                                       if Q6_9C3=98 then DAYS3=0;
                                          else DAYS3=Q6_9C3;
                                       WAGELAB3=WAGE3*DAYS3;
                                     end;
        else WAGELAB3=.;

     if (q6_9D4 ne 999 & q6_9C4 ne 99) then do;
                                       if q6_9D4=998 then WAGE4=0;
                                          else WAGE4=Q6_9D4;
                                       if Q6_9C4=98 then DAYS4=0;
                                          else DAYS4=Q6_9C4;
                                       WAGELAB4=WAGE4*DAYS4;
                                     end;
        else WAGELAB4=.;

     if (q6_9D5 ne 999 & q6_9C5 ne 99) then do;
                                       if q6_9D5=998 then WAGE5=0;
                                          else WAGE5=Q6_9D5;
                                       if Q6_9C5=98 then DAYS5=0;
                                          else DAYS5=Q6_9C5;
                                       WAGELAB5=WAGE5*DAYS5;
                                     end;
        else WAGELAB5=.;

    if ((WAGELAB1 ne .) and (WAGELAB2 ne .) and (WAGELAB3 ne .)
       and (WAGELAB4 ne .) and (WAGELAB5 ne .)) then
       WORKWAGE=WAGELAB1+WAGELAB2+WAGELAB3+WAGELAB4+WAGELAB5;

   *** General HH development indicators ***;

   if Q6_3=9 then PIPE_WAT=.;
      else if Q6_3=2 then PIPE_WAT=0;
      else PIPE_WAT=Q6_3;

   FUEL_OLD=0;
   FUEL_NEW=0;
   FUEL_NO=0;

   if (Q6_2A=1 or Q6_2B=1) then FUEL_OLD=1;
      else if (Q6_2C=1 or Q6_2D=1 or Q6_2E=1) then FUEL_NEW=1;
      else if (Q6_2A ne . & Q6_2B ne . & Q6_2C ne . & Q6_2D ne . & Q6_2E ne .) then FUEL_NO=1;
      else do;
             FUEL_OLD=.;
             FUEL_NEW=.;
             FUEL_NO=.;
           end;

   if WINDOW=9 then WIND_0_1=.;
      else if WINDOW=1 then WIND_0_1=0;
      else WIND_0_1=1;

run;

*** Create HH land and rice area variables ***;

** Sorted by HHID94 at end **;

data work&y.&f.18;                                                            
     set in&y.&f.05.plots94 (keep=HHID94 Q6_15C Q6_15A Q6_15B);

     by HHID94;

     keep HHID94 RAI_RICE RAI_O_94 MISCOUNT PLANGNUM;

     retain RAI_RICE RAI_O_94 MISCOUNT PLANGNUM;

     if first.HHID94 then do;
                            RAI_RICE=0;
                            RAI_O_94=0;
                            MISCOUNT=0;
                            PLANGNUM=0;
                          end;

      PLANGNUM=PLANGNUM+1;

      if Q6_15C in (99999,.) then MISCOUNT=MISCOUNT+1;
         else if Q6_15C=99995 then RAI_O_94=RAI_O_94+250; ***Automatically converts to RAI***;
         else RAI_O_94=RAI_O_94+(Q6_15C*0.0025);

      if (Q6_15A=2 or Q6_15B=2) then do;
                            if Q6_15C=99995 then RAI_RICE=RAI_RICE+250; ***Automatically converts to RAI***;
                              else RAI_RICE=RAI_RICE+(Q6_15C*0.0025);
                        end;

     if last.HHID94 then output;

run;


*** miscellaneous manipulations on rice land data ***;

data work&y.&f.19 (drop=MISCOUNT PLANGNUM);
     set work&y.&f.18;

     RICEPROP=.;

     if MISCOUNT=PLANGNUM then do;
                                 RAI_O_94=.;
                                 RAI_RICE=.;
                               end;

     if ((RAI_O_94 ne .) & (RAI_RICE ne .) & (RAI_O_94 ne 0)
        & (RAI_RICE < RAI_O_94))
        then RICEPROP=RAI_RICE/RAI_O_94;
        else RICEPROP=.;

run;


*** Create Categorical land variable ***;

data work&y.&f.20;
     set work&y.&f.19;

     RO94_0=0;
     RO94_1=0;
     RO94_2=0;
     RO94_3=0;

     RO94_A=.;

    if RAI_O_94=0 then RO94_0=1;
        else if (RAI_O_94>0 & RAI_O_94 <15) then RO94_1=1;
        else if (RAI_O_94>=15 & RAI_O_94 <45) then RO94_2=1;
        else if RAI_O_94>=45 then RO94_3=1;
        else if RAI_O_94 = . then do;
                                     RO94_0=.;
                                     RO94_1=.;
                                     RO94_2=.;
                                     RO94_3=.;
                                  end;

     if RO94_0=1 then RO94_A=1;
     if RO94_1=1 then RO94_A=1;
     if RO94_2=1 then RO94_A=2;
     if RO94_3=1 then RO94_A=3;

run;

*---------------------------------------------*
*  Assemble village-level origin variables    *
*---------------------------------------------*;

*** Prepare previous files for aggregation at village 94 level ***;

data work&y.&f.21;
     merge work&y.&f.20 (in=a)
           in&y.&f.01.hh94 (in=b keep=VILL94 HHID94);

     by HHID94;

     if a=0 and b=1 then do;
                            RAI_O_94=0;
                            RAI_RICE=0;
                            RICEPROP=0;
                            RO94_0=0;
                            RO94_1=0;
                            RO94_2=0;
                            RO94_3=0;
                         end;

     if b=1 then output work&y.&f.21;
run;


*** Aggregated Village-Level Variables ***;

data work&y.&f.22 (keep=VILL94 VILL1355 VILL_WAM VILL_WAF);
     set work&y.&f.16;
     by VILL94;

     keep VILL94 VILL1355 VILL_WAM VILL_WAF;

     retain VILL1355 VILL_WAM VILL_WAF;

     if first.VILL94 then do;
                            VILL_WAM=0;
                            VILL_WAF=0;
                            VILL1355=0;
                          end;


     VILL_WAM=VILL_WAM+NUMMALES;  ** Males 13-55 **;

     VILL_WAF=VILL_WAF+NUMFEMS;   ** Females 13-55 **;

     VILL1355=VILL1355+NUMMALES+NUMFEMS;

     if last.VILL94 then output;

run;

data work&y.&f.23;
     set work&y.&f.21;

     by VILL94;

     keep VILL94 VILL_RAI VILL_RIC;

     retain VILL_RAI VILL_RIC;

     if first.VILL94 then do;
                             VILL_RAI=0;
                             VILL_RIC=0;
                          end;

     if RAI_RICE ne . then VILL_RIC=VILL_RIC+RAI_RICE;

     if RAI_O_94 ne . then VILL_RAI=VILL_RAI+RAI_O_94;

     if last.VILL94 then output;

run;

*** True Village-Level Variables ***;

data work&y.&f.24 (drop=Q4_53 Q8_104 Q5_76_1 Q5_76_2);
     set in&y.&f.04.comm94 (in=d keep=VILL94 Q5_76_1 Q5_76_2 Q4_53 Q8_104);

    if Q5_76_1=2 then V_HELPM=0;
       else if Q5_76_1=1 then V_HELPM=1;

     if Q5_76_2=2 then V_HELPF=0;
       else if Q5_76_2=1 then V_HELPF=1;

        if Q4_53=2 then V_TOODRY=1;
             else V_TOODRY=0;

          if Q8_104=2 then V_PHONE=0;
            else if Q8_104=1 then V_PHONE=1;

    if V_HELPM=1 | V_HELPF=1 then V_HELP=1;
       else V_HELP=0;

run;

***----------------------------------------------------***
*** merge variables from all levels and existing files ***
***----------------------------------------------------***;

** Strategy: 1.) Merge MIG VARS onto 2.) Merge DEP VARS onto **;

** merge HH-level variables **;

data work94_hh;
     merge work&y.&f.21 (in=a)
           work&y.&f.17 (in=b)
           work&y.&f.16 (in=c);

     by HHID94;

     if a=1 and b=1 and c=1 then output work94_hh;

run;

data work94_vil;
     merge work&y.&f.22 (in=a)
           work&y.&f.23 (in=b)
           work&y.&f.24 (in=c);

     by VILL94;

     if a=1 and b=1 and c=1 then output work94_vil;

run;


****************************************************************
** Added to create just village-level data file for chapter 2 **
****************************************************************;

libname ot&y.&f.05 xport '/home/jhull/nangrong/data_sas/p01_rice/current/p01_94VL.xpt';

data ot&y.&f.05.p01_&y.VL;
     set work&y._vil;
run;

****************************************************************;


** Merge Village-level vars onto hh-level file **;

data work94_hh_vil;
     merge work94_hh (in=a)
           work94_vil (in=b);

     by VILL94;

     if a=1 then output;

run;


** Bring in existing cumulative file p01_9402 and sort **;

proc sort data=ot&y.&f.02.p01_9402 out=c3_94_02a;
     by HHID94;
run;

proc sort data=work94_hh_vil out=work94_hh_vila;
     by HHID94;
run;


** Merge all newly created hh and village vars onto cumulative file **;

data work&y._all;
     merge work94_hh_vila (in=a)
           c3_94_02a (in=b);

    by HHID94;

    if a=1 and b=1 then output;

run;


** Clean up new cumulative file - drop extra variables, limit to old households only **;

data work&y.&f.25;
     set work&y._all (drop=HELP23A: HELP23C: HELP23D: HELP23F: HELP23G:
                           HELPVA: HELPVC: HELPVD: HELPVE: HELPVF: HELPVG:
                           HELPOA: HELPOC: HELPOD: HELPOE: HELPOF: HELPOG:
                                   HELPXC: HELPXD: HELPXE: HELPXF: HELPXG:
                     );

    if HHTYPE94 in (1,3);   *** Removes NEW HH's from final file ***; 
run;


*** Save Out dataset to p01_9403 ***;

data ot&y.&f.03.p01_9403;
     set work&y.&f.25;
run;


******c2_94_03*********************************************************;
***********************************************************************;

********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

* This code stacks the code 2&3 help into a child file *;
* It adds the location=9 variable and codes # helpers=1 for all *;

** Unstacks hh-level rice harvest variables **;

data work&y.&f.51;
     set in&y.&f.01.hh94 (keep=hhid94 Q6_23A: Q6_23B: Q6_23C: Q6_23D:);
     keep HHID94 Q6_24A Q6_24B Q6_24C Q6_24D Q6_24E LOCATION;

	   length Q6_24A $ 7;

          array a(1:5) Q6_23A1-Q6_23A5;
          array b(1:5) Q6_23B1-Q6_23B5;
          array c(1:5) Q6_23C1-Q6_23C5;
          array d(1:5) Q6_23D1-Q6_23D5;

          do i=1 to 5;
               Q6_24A=put(a(i),3.0);
               Q6_24B=1;
               Q6_24C=b(i);
               Q6_24D=c(i);
               Q6_24E=d(i);
               LOCATION=9;
               if Q6_24A ne '998' then output;  *Keep only those cases with data *;
          end;
run;

** Brings in rice harvest-level variables **;

data work&y.&f.52 (drop=Q6_24TMP);
     set in&y.&f.02.helprh94 (keep=hhid94 Q6_24A Q6_24B Q6_24C Q6_24D Q6_24E rename=(Q6_24A=Q6_24TMP));

     Q6_24A=put(Q6_24TMP,7.0);

     if Q6_24A in ('9999997','0009999','9999999') then LOCATION=8;                  *allmissing*;
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)='5' then LOCATION=7;  *country*;
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)='4' then LOCATION=6;  *province*;
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)='3' then LOCATION=5;  *district*;
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)='2' then LOCATION=4;  *othervill*;
        else if substr(Q6_24A,1,3)='997' and substr(Q6_24A,4,1)='2' then LOCATION=3;  *splitmissing*;
        else if substr(Q6_24A,1,3)='997' and substr(Q6_24A,4,1)='0' then LOCATION=2;  *samemissing*;
        else if substr(Q6_24A,4,4)='9999' then LOCATION=2;   *samemissing*;
        else if substr(Q6_24A,4,4)='0000' then LOCATION=0;   *samevill*;
        else if substr(Q6_24A,4,1)='2' then LOCATION=1;      *splitvill*;
        else if substr(Q6_24A,4,1)='0' then LOCATION=1;      *splitvill*;
        else LOCATION=.;                                     * LOGIC PROBLEMS IF . > 0 *;

        if Q6_24C=99 then Q6_24C=1;        *RECODES*;    *If number of days unknown, code as "."*;
        if Q6_24B=99 then Q6_24B=1;                      *If number of workers unknown, code as "."*;
                                                         *No recodes needed for Q6_24D *;
        if Q6_24E=996 then Q6_24E=.;                     *If wages unknown, code as "."  *;
           else if Q6_24E=998 then Q6_24E=.;             *The above recodes to 1 impact 22 and 12 helping hhs respectively *;
           else if Q6_24E=999 then Q6_24E=.;             *The logic is that if the hh was named then at least*;
								 * one person worked for at least 1 day *;
run;                                                    

** Merges rice harvest data from files hh94 and helprh94, leaves unstacked **;

data work&y.&f.53;
     set work&y.&f.51
         work&y.&f.52;
run;


***************************************************************************
** Add V84 identifiers to 1994 data file as per Rick's comments on web   **
***************************************************************************;

proc sort data=work&y.&f.53 out=work&y.&f.54;
     by HHID94 q6_24a LOCATION;
run;

data work&y.&f.51fix;
     set in&y.&f.03.indiv94;
     keep HHID94 V84;
run;

proc sort data=work&y.&f.51fix out=work&y.&f.52fix nodupkey;
     by HHID94 v84;
run;

data work&y.&f.55;
     merge work&y.&f.54 (in=a)
           work&y.&f.52fix (in=b);
           if a=1 and b=1 then output;
     by HHID94;
run;

proc sort data=work&y.&f.55 out=work&y.&f.56;
     by V84 HHID94;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 11 cases (a case here is a helper group)        **
******************************************************************************;

data work&y.&f.57;
     set work&y.&f.56;

     if Q6_24D ^in (.,9) then output;

     ** if LOCATION ^=9;   ** DROPS ALL HHs EXCEPT THOSE THAT USED NON-CODE 2&3 EXTRA LABOR **;
run;

proc sort data=work&y.&f.57 out=work&y.&f.57B;
     by HHID94;
run;


***************************************************************
** The Following code is executed for each possible location **
***************************************************************;

** This code collapses the data just like before, but by household this time, not by village **;

* Location=1 Number and proportion, total, free, and paid *;

data work&y.&f.62_01 (keep=HHID94 H_NUM_T1 H_NUM_P1 H_NUM_F1);  * Collapse into HHs *;
     set work&y.&f.57B (keep=HHID94 Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T1 H_NUM_P1 H_NUM_F1 0;

  if first.HHID94 then do;
                          H_NUM_T1=0;
                          H_NUM_P1=0;
                          H_NUM_F1=0;
                       end;

  if LOCATION in (0,1,2,3) then do;
                        H_NUM_T1=H_NUM_T1+Q6_24B;
                        if Q6_24D=1 then H_NUM_P1=H_NUM_P1+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F1=H_NUM_F1+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T1='Total Number Persons Helping';
  label H_NUM_P1='Total Number Persons Helping for Pay';
  label H_NUM_F1='Total Number Persons Helping for Free';

run;

data work&y.&f.63_01;                                          * Create Proportion Variable *;
     set work&y.&f.62_01;

     H_PRO_P1=ROUND(H_NUM_P1/(H_NUM_T1+0.0000001),.0001);
     H_PRO_F1=ROUND(H_NUM_F1/(H_NUM_T1+0.0000001),.0001);

     if H_NUM_T1=0 then do;
                           H_NUM_T1=.;
                           H_NUM_P1=.;
                           H_NUM_F1=.;
                           H_PRO_P1=.;
                           H_PRO_F1=.;
                        end;

run;


* Location=4 Number and proportion, total, free, and paid *;

data work&y.&f.62_04 (keep=HHID94  H_NUM_T4 H_NUM_P4 H_NUM_F4);  * Collapse into HHs *;
     set work&y.&f.57B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T4 H_NUM_P4 H_NUM_F4 0;

  if first.HHID94 then do;
                          H_NUM_T4=0;
                          H_NUM_P4=0;
                          H_NUM_F4=0;
                       end;

  if LOCATION=4 then do;
                        H_NUM_T4=H_NUM_T4+Q6_24B;
                        if Q6_24D=1 then H_NUM_P4=H_NUM_P4+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F4=H_NUM_F4+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T4='Total Number Persons Helping';
  label H_NUM_P4='Total Number Persons Helping for Pay';
  label H_NUM_F4='Total Number Persons Helping for Free';

run;

data work&y.&f.63_04;                                          * Create Proportion Variable *;
     set work&y.&f.62_04;

     H_PRO_P4=ROUND(H_NUM_P4/(H_NUM_T4+0.0000001),.0001);
     H_PRO_F4=ROUND(H_NUM_F4/(H_NUM_T4+0.0000001),.0001);

     if H_NUM_T4=0 then do;
                           H_NUM_T4=.;
                           H_NUM_P4=.;
                           H_NUM_F4=.;
                           H_PRO_P4=.;
                           H_PRO_F4=.;
                        end;

run;


* Location=5 Number and proportion, total, free, and paid *;

data work&y.&f.62_05 (keep=HHID94  H_NUM_T5 H_NUM_P5 H_NUM_F5);  * Collapse into HHs *;
     set work&y.&f.57B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T5 H_NUM_P5 H_NUM_F5 0;

  if first.HHID94 then do;
                          H_NUM_T5=0;
                          H_NUM_P5=0;
                          H_NUM_F5=0;
                       end;

  if LOCATION=5 then do;
                        H_NUM_T5=H_NUM_T5+Q6_24B;
                        if Q6_24D=1 then H_NUM_P5=H_NUM_P5+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F5=H_NUM_F5+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T5='Total Number Persons Helping';
  label H_NUM_P5='Total Number Persons Helping for Pay';
  label H_NUM_F5='Total Number Persons Helping for Free';

run;

data work&y.&f.63_05;                                          * Create Proportion Variable *;
     set work&y.&f.62_05;

     H_PRO_P5=ROUND(H_NUM_P5/(H_NUM_T5+0.0000001),.0001);
     H_PRO_F5=ROUND(H_NUM_F5/(H_NUM_T5+0.0000001),.0001);

     if H_NUM_T5=0 then do;
                           H_NUM_T5=.;
                           H_NUM_P5=.;
                           H_NUM_F5=.;
                           H_PRO_P5=.;
                           H_PRO_F5=.;
                        end;

run;


* Location=6 Number and proportion, total, free, and paid *;

data work&y.&f.62_06 (keep=HHID94  H_NUM_T6 H_NUM_P6 H_NUM_F6);  * Collapse into HHs *;
     set work&y.&f.57B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T6 H_NUM_P6 H_NUM_F6 0;

  if first.HHID94 then do;
                          H_NUM_T6=0;
                          H_NUM_P6=0;
                          H_NUM_F6=0;
                       end;

  if LOCATION=6 then do;
                        H_NUM_T6=H_NUM_T6+Q6_24B;
                        if Q6_24D=1 then H_NUM_P6=H_NUM_P6+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F6=H_NUM_F6+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T6='Total Number Persons Helping';
  label H_NUM_P6='Total Number Persons Helping for Pay';
  label H_NUM_F6='Total Number Persons Helping for Free';

run;

data work&y.&f.63_06;                                          * Create Proportion Variable *;
     set work&y.&f.62_06;

     H_PRO_P6=ROUND(H_NUM_P6/(H_NUM_T6+0.0000001),.0001);
     H_PRO_F6=ROUND(H_NUM_F6/(H_NUM_T6+0.0000001),.0001);

     if H_NUM_T6=0 then do;
                           H_NUM_T6=.;
                           H_NUM_P6=.;
                           H_NUM_F6=.;
                           H_PRO_P6=.;
                           H_PRO_F6=.;
                        end;

run;


* Location=8 Number and proportion, total, free, and paid *;

data work&y.&f.62_08 (keep=HHID94  H_NUM_T8 H_NUM_P8 H_NUM_F8);  * Collapse into HHs *;
     set work&y.&f.57B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T8 H_NUM_P8 H_NUM_F8 0;

  if first.HHID94 then do;
                          H_NUM_T8=0;
                          H_NUM_P8=0;
                          H_NUM_F8=0;
                       end;

  if LOCATION=8 then do;
                        H_NUM_T8=H_NUM_T8+Q6_24B;
                        if Q6_24D=1 then H_NUM_P8=H_NUM_P8+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F8=H_NUM_F8+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T8='Total Number Persons Helping';
  label H_NUM_P8='Total Number Persons Helping for Pay';
  label H_NUM_F8='Total Number Persons Helping for Free';

run;

data work&y.&f.63_08;                                          * Create Proportion Variable *;
     set work&y.&f.62_08;

     H_PRO_P8=ROUND(H_NUM_P8/(H_NUM_T8+0.0000001),.0001);
     H_PRO_F8=ROUND(H_NUM_F8/(H_NUM_T8+0.0000001),.0001);

     if H_NUM_T8=0 then do;
                           H_NUM_T8=.;
                           H_NUM_P8=.;
                           H_NUM_F8=.;
                           H_PRO_P8=.;
                           H_PRO_F8=.;
                        end;

run;


* Location=9 Number and proportion, total, free, and paid *;

data work&y.&f.62_09 (keep=HHID94  H_NUM_T9 H_NUM_P9 H_NUM_F9);  * Collapse into HHs *;
     set work&y.&f.57B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

     retain H_NUM_T9 H_NUM_P9 H_NUM_F9 0;

     if first.HHID94 then do;
                          H_NUM_T9=0;
                          H_NUM_P9=0;
                          H_NUM_F9=0;
                       end;

     if LOCATION=9 then do;
                        H_NUM_T9=H_NUM_T9+Q6_24B;
                        if Q6_24D=1 then H_NUM_P9=H_NUM_P9+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F9=H_NUM_F9+Q6_24B;
                     end;

     if last.HHID94 then output;

     label H_NUM_T9='Total Number Persons Helping';
     label H_NUM_P9='Total Number Persons Helping for Pay';
     label H_NUM_F9='Total Number Persons Helping for Free';

run;

data work&y.&f.63_09;                                          * Create Proportion Variable *;
     set work&y.&f.62_09;

     H_PRO_P9=ROUND(H_NUM_P9/(H_NUM_T9+0.0000001),.0001);
     H_PRO_F9=ROUND(H_NUM_F9/(H_NUM_T9+0.0000001),.0001);

     if H_NUM_T9=0 then do;
                           H_NUM_T9=.;
                           H_NUM_P9=.;
                           H_NUM_F9=.;
                           H_PRO_P9=.;
                           H_PRO_F9=.;
                        end;

run;


*****************************************************************
**  Merge all separate hh files together, number cases= 2548   **
*****************************************************************;

data work&y.&f.64;
     merge work&y.&f.63_01
           work&y.&f.63_04
           work&y.&f.63_05
           work&y.&f.63_06
           work&y.&f.63_08
           work&y.&f.63_09;
     by HHID94;
run;


** NOTE: The code that follows will be affected by any **
** changes to the grouping of cases above done on 2/15 **;

** Code 2 & 3 excluded from analysis, as well as unknown location **;

** After examining the data for 1994 and 2000, I found very few cases  **
** in which a household mixed payment strategies or labor sources, so  **
** the decision to recode these variables to dichotomous indicators    **
** 0,any seems a sensible way to simplify the data analysis. For the   **
** variable H_PRO_PD, roughly 4% in either year fell between 0 and 1,  **
** while for H_PRO_OT it was somewhere near 13% in either year. 3/10    **;


data work&y.&f.66 (drop=ZIPPO);
     set work&y.&f.64;
     ZIPPO=0;     ** SLICK TRICK TO TAKE CARE OF MISSING DATA **;
     H_TOT_T=sum(of H_NUM_T1 H_NUM_T4 H_NUM_T5 H_NUM_T6 ZIPPO);
     H_TOT_P=sum(of H_NUM_P1 H_NUM_P4 H_NUM_P5 H_NUM_P6 ZIPPO);
     H_TOT_F=sum(of H_NUM_F1 H_NUM_F4 H_NUM_F5 H_NUM_F6 ZIPPO);
     H_TOT_IN=sum(of H_NUM_T1 ZIPPO);
     H_TOT_OT=sum(of H_NUM_T4 H_NUM_T5 H_NUM_T6 ZIPPO);

     H_PRO_PD=ROUND(H_TOT_P/(H_TOT_T+0.0000001),.0001);
     H_PRO_IN=ROUND(H_TOT_IN/(H_TOT_T+0.0000001),.0001);
     H_PRO_OT=ROUND(H_TOT_OT/(H_TOT_T+0.0000001),.0001);
     H_PRO_FR=ROUND(H_TOT_F/(H_TOT_T+0.0000001),.0001);

      if H_TOT_P>0 then H_ANY_PD=1;
         else H_ANY_PD=0;
      if H_TOT_F>0 then H_ANY_FR=1;
         else H_ANY_FR=0;
      if H_TOT_IN>0 then H_ANY_IN=1;
         else H_ANY_IN=0;
      if H_TOT_OT>0 then H_ANY_OT=1;
         else H_ANY_OT=0;

     if H_TOT_P >= 1 and H_TOT_F >= 1 then H_PF_11=1;
        else H_PF_11=0;
     if H_TOT_P >= 1 and H_TOT_F = 0 then H_PF_10=1;
        else H_PF_10=0;
     if H_TOT_P = 0 and H_TOT_F >= 1 then H_PF_01=1;
        else H_PF_01=0;
     if H_TOT_P =0 and H_TOT_F = 0 then H_PF_00=1;
        else H_PF_00=0;

     if H_TOT_OT >= 1 and H_TOT_IN >= 1 then H_OI_11=1;
        else H_OI_11=0;
     if H_TOT_OT >= 1 and H_TOT_IN = 0 then H_OI_10=1;
        else H_OI_10=0;
     if H_TOT_OT = 0 and H_TOT_IN >= 1 then H_OI_01=1;
        else H_OI_01=0;
     if H_TOT_OT =0 and H_TOT_IN = 0 then H_OI_00=1;
        else H_OI_00=0;

       if H_PF_10=1 then HELPDV5=1;
         else HELPDV5=0;

     ** if H_TOT_T>0;  ** DROPS ALL HHs BUT THOSE THAT USED NON-CODE 2&3 EXTRA LABOR **;

 run;

**NEW STUFF ***********************************************************************************************;
***********************************************************************************************************;

data work&y.&f.70;
     merge work&y.&f.25 (in=a)
           work&y.&f.66 (in=b);
     by HHID&y;
     if a=1 then output;
run;

data work&y.&f.71 (drop=ro94_0 fuel_no);
     set work&y.&f.70;
     if HELPDV5=. and HELPDV3^=. then HELPDV5=0;    ** Could only be done once files were merged **;

     if ro94_0=1 then ro94_1=1;                     ** recode land variables to 3-categories **;
     if fuel_no=1 then fuel_old=1;

run;

data work&y.&f.72;
     set work&y.&f.71;
     if m_13_55^=.;
     if f_13_55^=.;
     if numdepch^=.;
     if numdepel^=.;
     if codetwo^=.;
     if meanage^=.;
     if migrem_y^=.;
     if migrem_n^=.;
     if rai_rice^=.;
     if riceprop^=.;
     if plantnum^=.;
     if cassava^=.;
     if cottage^=.;
     if stock^=.;
     if charcoal^=.;
     if casset1^=.;
     if passet1^=.;
     if pcasset1^=.;
     if workwage^=.;
     if pipe_wat^=.;
     if wind_0_1^=.;
     if fuel_new^=.;
     if vill1355^=.;
     if vill_ric^=.;
     if v_toodry^=.;
     if v_phone^=.;
     if ro&y._1^=.;
     if ro&y._2^=.;
     if ro&y._3^=.;
     if equip&y^=.;
     if vill_rai^=.;
     if v_help^=.;

     if helpdv5^=. then grewrice=1;
        else grewrice=0;

run;


data work&y.&f.73;
     set work&y.&f.72 (keep=hhtype&y helpdv3 m_13_55 f_13_55 
                            numdepch numdepel codetwo meanage 
                            migrem_y migrem_n rai_rice riceprop 
                            plantnum cassava cottage stock charcoal 
                            casset1 passet1 pcasset1 workwage 
                            pipe_wat wind_0_1 fuel_new fuel_old
                            vill1355 vill_ric v_toodry v_phone 
                            ro&y._1 ro&y._2 ro&y._3 equip&y 
                            vill_rai vill&y hhid&y helpdv5
                            ro&y._A plantnum workwage tothelp 
                            h_tot_t h_tot_p h_tot_f v_helpm 
                            v_helpf v_help rice_yld all_pd all_p 
                            paid_t grewrice);
run;


data ot&y.&f.04.p01_9406;
     set work&y.&f.73;
run;


** CREATE A STATA DATASET **;

data p01_&y.06;
     set work&y.&f.73;
run;

%include "/home/jhull/public/sasmacros/savastata.mac";

%savastata(/home/jhull/nangrong/data_sas/p01_rice/current/, -x -replace);