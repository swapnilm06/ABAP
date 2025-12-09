REPORT z_abap_report_performance_demo.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*
SELECT-OPTIONS: s_kunnr FOR kna1-kunnr,
                s_bukrs FOR knb1-bukrs.

*---------------------------------------------------------------------*
* Final Output Structure (One Table)
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_final,
         kunnr TYPE kna1-kunnr,   "Customer
         name1 TYPE kna1-name1,   "Name
         land1 TYPE kna1-land1,   "Country
         bukrs TYPE knb1-bukrs,   "Company Code
         akont TYPE knb1-akont,   "Reconciliation Account
       END OF ty_final.

*---------------------------------------------------------------------*
* Helper Structures
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_kna1,
         kunnr TYPE kna1-kunnr,
         name1 TYPE kna1-name1,
         land1 TYPE kna1-land1,
       END OF ty_kna1.

TYPES: BEGIN OF ty_knb1,
         kunnr TYPE knb1-kunnr,
         bukrs TYPE knb1-bukrs,
         akont TYPE knb1-akont,
       END OF ty_knb1.

*---------------------------------------------------------------------*
* Data Declarations
*---------------------------------------------------------------------*
DATA: gt_kna1  TYPE STANDARD TABLE OF ty_kna1,
      gt_knb1  TYPE STANDARD TABLE OF ty_knb1,
      gt_final TYPE STANDARD TABLE OF ty_final,
      gs_final TYPE ty_final.

DATA: gv_name TYPE kna1-name1.

*---------------------------------------------------------------------*
* START-OF-SELECTION
*---------------------------------------------------------------------*
START-OF-SELECTION.

*---------------------------------------------------------------------*
* 1. SELECT SINGLE (Single record fetch)
*---------------------------------------------------------------------*
SELECT SINGLE name1
  INTO @gv_name
  FROM kna1
  WHERE kunnr = '0000001000'.

*---------------------------------------------------------------------*
* 2. SELECT KNA1 (Base table)
*---------------------------------------------------------------------*
SELECT kunnr
       name1
       land1
  FROM kna1
  INTO TABLE @gt_kna1
  WHERE kunnr IN @s_kunnr.

*---------------------------------------------------------------------*
* 3. FOR ALL ENTRIES (Avoid SELECT in LOOP)
*---------------------------------------------------------------------*
IF gt_kna1 IS NOT INITIAL.        "Mandatory check

  SELECT kunnr
         bukrs
         akont
    FROM knb1
    INTO TABLE @gt_knb1
    FOR ALL ENTRIES IN @gt_kna1
    WHERE kunnr = @gt_kna1-kunnr
      AND bukrs IN @s_bukrs.

ENDIF.

*---------------------------------------------------------------------*
* 4. Merge FAE Data into ONE Final Table
*---------------------------------------------------------------------*
LOOP AT gt_kna1 INTO DATA(gs_kna1).

  LOOP AT gt_knb1 INTO DATA(gs_knb1)
       WHERE kunnr = gs_kna1-kunnr.

    CLEAR gs_final.
    gs_final-kunnr = gs_kna1-kunnr.
    gs_final-name1 = gs_kna1-name1.
    gs_final-land1 = gs_kna1-land1.
    gs_final-bukrs = gs_knb1-bukrs.
    gs_final-akont = gs_knb1-akont.

    APPEND gs_final TO gt_final.

  ENDLOOP.
ENDLOOP.

*---------------------------------------------------------------------*
* 5. INNER JOIN (Best Performance)
*---------------------------------------------------------------------*
SELECT a~kunnr
       a~name1
       a~land1
       b~bukrs
       b~akont
  FROM kna1 AS a
  INNER JOIN knb1 AS b
    ON a~kunnr = b~kunnr
  INTO TABLE @DATA(gt_join)
  WHERE a~kunnr IN @s_kunnr
    AND b~bukrs IN @s_bukrs.

*---------------------------------------------------------------------*
* 6. Classical Report Output
*---------------------------------------------------------------------*
WRITE: / 'FOR ALL ENTRIES Output (Merged Table)'.
ULINE.

LOOP AT gt_final INTO gs_final.
  WRITE: / gs_final-kunnr,
           gs_final-name1,
           gs_final-land1,
           gs_final-bukrs,
           gs_final-akont.
ENDLOOP.

ULINE.
WRITE: / 'INNER JOIN Output (Fastest)'.
ULINE.

LOOP AT gt_join INTO DATA(gs_join).
  WRITE: / gs_join-kunnr,
           gs_join-name1,
           gs_join-land1,
           gs_join-bukrs,
           gs_join-akont.
ENDLOOP.

