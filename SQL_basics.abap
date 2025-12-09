REPORT z_demo_reports_kna1_knb1.

*---------------------------------------------------------------------*
*  Topic Covered
*  1. Classical Report
*  2. Selection Screen
*  3. Open SQL
*     - SELECT / SELECT SINGLE
*     - FOR ALL ENTRIES
*     - INNER JOIN
*     - LEFT OUTER JOIN
*  4. Best Practices
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
* Selection Screen (Optional screen)
*---------------------------------------------------------------------*
SELECT-OPTIONS: s_kunnr FOR kna1-kunnr,
                s_bukrs FOR knb1-bukrs.

*---------------------------------------------------------------------*
* Type Declarations
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_kna1,
         kunnr TYPE kna1-kunnr,
         name1 TYPE kna1-name1,
         land1 TYPE kna1-land1,
       END OF ty_kna1.

TYPES: BEGIN OF ty_join,
         kunnr TYPE kna1-kunnr,
         name1 TYPE kna1-name1,
         bukrs TYPE knb1-bukrs,
         akont TYPE knb1-akont,
       END OF ty_join.

*---------------------------------------------------------------------*
* Data Declarations
*---------------------------------------------------------------------*
DATA: gt_kna1 TYPE STANDARD TABLE OF ty_kna1,
      gs_kna1 TYPE ty_kna1.

DATA: gt_join TYPE STANDARD TABLE OF ty_join,
      gs_join TYPE ty_join.

DATA: gv_name TYPE kna1-name1.

*---------------------------------------------------------------------*
* START-OF-SELECTION
*---------------------------------------------------------------------*
START-OF-SELECTION.

*---------------------------------------------------------------------*
* 1. SELECT SINGLE example
*---------------------------------------------------------------------*
SELECT SINGLE name1
  INTO gv_name
  FROM kna1
  WHERE kunnr = '0000001000'.

IF sy-subrc = 0.
  WRITE: / 'SELECT SINGLE Result:', gv_name.
ENDIF.

ULINE.

*---------------------------------------------------------------------*
* 2. SELECT Statement (Without *)
*---------------------------------------------------------------------*
SELECT kunnr
       name1
       land1
  FROM kna1
  INTO TABLE gt_kna1
  WHERE kunnr IN s_kunnr.

WRITE: / 'Simple SELECT Output:'.
LOOP AT gt_kna1 INTO gs_kna1.
  WRITE: / gs_kna1-kunnr,
           gs_kna1-name1,
           gs_kna1-land1.
ENDLOOP.

ULINE.

*---------------------------------------------------------------------*
* 3. FOR ALL ENTRIES example
*---------------------------------------------------------------------*
IF gt_kna1 IS NOT INITIAL.

  SELECT kunnr
         bukrs
         akont
    FROM knb1
    INTO TABLE @DATA(gt_knb1)
    FOR ALL ENTRIES IN gt_kna1
    WHERE kunnr = gt_kna1-kunnr
      AND bukrs IN s_bukrs.

  WRITE: / 'FOR ALL ENTRIES Output:'.
  LOOP AT gt_knb1 INTO DATA(gs_knb1).
    WRITE: / gs_knb1-kunnr,
             gs_knb1-bukrs,
             gs_knb1-akont.
  ENDLOOP.

ENDIF.

ULINE.

*---------------------------------------------------------------------*
* 4. INNER JOIN example
*---------------------------------------------------------------------*
SELECT a~kunnr
       a~name1
       b~bukrs
       b~akont
  FROM kna1 AS a
  INNER JOIN knb1 AS b
    ON a~kunnr = b~kunnr
  INTO TABLE gt_join
  WHERE a~kunnr IN s_kunnr
    AND b~bukrs IN s_bukrs.

WRITE: / 'INNER JOIN Output:'.
LOOP AT gt_join INTO gs_join.
  WRITE: / gs_join-kunnr,
           gs_join-name1,
           gs_join-bukrs,
           gs_join-akont.
ENDLOOP.

ULINE.

*---------------------------------------------------------------------*
* 5. LEFT OUTER JOIN example
*---------------------------------------------------------------------*
CLEAR gt_join.

SELECT a~kunnr
       a~name1
       b~bukrs
       b~akont
  FROM kna1 AS a
  LEFT OUTER JOIN knb1 AS b
    ON a~kunnr = b~kunnr
  INTO TABLE gt_join
  WHERE a~kunnr IN s_kunnr.

WRITE: / 'LEFT OUTER JOIN Output:'.
LOOP AT gt_join INTO gs_join.
  WRITE: / gs_join-kunnr,
           gs_join-name1,
           gs_join-bukrs,
           gs_join-akont.
ENDLOOP.

*---------------------------------------------------------------------*
* End of Classical Report
*---------------------------------------------------------------------*
