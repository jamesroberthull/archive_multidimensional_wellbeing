********************************************************************************************************;
**  Program Name: /home/jhull/nangrong/prog_sas/p03_gom/p03_0001.sas
**  Programmer: james r. hull
**  Start Date: 2011 February 21
**  Purpose:
**   1.) Create a dataset that is properly formatted for GoM modeling
**
**  Input Data:
**  '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_a.xpt'
**  '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_b.xpt'
**  '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_c.xpt'
**  '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_d.xpt'
**
**  Output Data:
**   '/home/jhull/nangrong/data_sas/p03_gom/current/p03_0001.xpt'
**
**  Notes:
**   1.) This dataset merges all variables created in files a-->d
**   2.) This datset also creates a format library for variable value labels
********************************************************************************************************;

*******************************************
**  Options and General Macro Variables  **
*******************************************;

options nocenter linesize=80 pagesize=60;

%let y=00; 

**********************
**  Data Libraries  **
**********************;

libname in&y.01 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_a.xpt';
libname in&y.02 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_b.xpt';
libname in&y.03 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_c.xpt';
libname in&y.04 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_00_d.xpt';

libname ot&y.01 xport '/home/jhull/nangrong/data_sas/p03_gom/current/p03_0001.xpt';


/*

********************************************************************************************************;
** create formats for categorical variables **;

proc format;
     value c&f.f 0="primary grade 4 or less"
                 1="primary grade 4 to grade 6"
                 2="secondary or greater";
run;

proc format library = myfmtlib.cat1;
value $jc 'one' = 'management'
          'two' = 'non-management';
value rate 
           0 = 'terrible'
           1 = 'poor'
           2 = 'fair'
	   3 = 'good'
	   4 = 'excellent';
run;


** Remember to add a dataset label at finish **;

********************************************************************************************************;
** Include SAS code for variable formats, PROC_CODEBOOK macro program;

%include 'C:\My_project\HWT_short_formats.sas';
%include ' C:\My_project\proc_codebook.sas';

*User defines folder where data set resides;

libname here 'C:\My_project';

*User specifies titles for codebook PDF file;

title1 'CODEBOOK FOR WAY TO HEALTH BASELINE HEIGHT/WEIGHT DATA';
footnote 'Created by:  hwt_base_codebook.sas';  
%let organization=One Record per Participant (ID); 

*Run Codebook macro;

%proc_codebook(lib=here,
		file1=hwt_base, 
		fmtlib=work.formats, 
		pdffile=hwt_base_codebook.pdf); 
run;


********************************************************************************************************;
** CREATE A STATA DATASET **;

data p01_&y.06;
     set work&y.&f.73;
run;


%include "/home/jhull/public/sasmacros/savastata.mac";

%savastata(/home/jhull/nangrong/data_sas/p01_rice/current/,-x -replace);

*/
