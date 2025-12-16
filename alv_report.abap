*&---------------------------------------------------------------------*
*& Report ZALV_PRG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zalv_prg.


*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*
TABLES: kna1, knb1.
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
* 5. INNER JOIN (Best Performance)
*---------------------------------------------------------------------*
  SELECT a~kunnr,
  a~name1,
  a~land1,
  b~bukrs,
  b~akont
  FROM kna1 AS a
  INNER JOIN knb1 AS b
  ON a~kunnr = b~kunnr
  INTO TABLE @DATA(gt_join)
        WHERE a~kunnr IN @s_kunnr
        AND b~bukrs IN @s_bukrs.




**step 1 : lvc_fieldcatalog_merge

  DATA : fieldcat TYPE  slis_t_fieldcat_alv.
  DATA: wa_fieldcat TYPE slis_fieldcat_alv.


  "CREATE FIEDCAT USING FUNCTION MODULE ----------------------------------------------------------------------------------------------------------------------------------------

* CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*  EXPORTING
**    I_PROGRAM_NAME               =
**    I_INTERNAL_TABNAME           =
*    I_STRUCTURE_NAME             =  'ZFIELDCAT'
**    I_CLIENT_NEVER_DISPLAY       = 'X'
**    I_INCLNAME                   =
**    I_BYPASSING_BUFFER           =
**    I_BUFFER_ACTIVE              =
*   CHANGING
*ct_fieldcat                  = fieldcat
**  EXCEPTIONS
**    INCONSISTENT_INTERFACE       = 1
**    PROGRAM_ERROR                = 2
**    OTHERS                       = 3
*           .
* IF sy-subrc <> 0.
** Implement suitable error handling here
* ENDIF.


  "CREATE FIELDCAT MANUALLY --------------------------------------------------------------------------------------------------------------------------

  wa_fieldcat-fieldname = 'KUNNR'.
  wa_fieldcat-col_pos = '1'.
  wa_fieldcat-seltext_m = 'CUST NO'.
  APPEND wa_fieldcat TO fieldcat.


  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-col_pos = '2'.
  wa_fieldcat-seltext_m = 'NAME'.
  APPEND wa_fieldcat TO fieldcat.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =  'ZFIELDCAT'    "Directly pass structure ----
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
*     IS_LAYOUT   =
      it_fieldcat                      = fieldcat         "pass fieldcate ---------
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT     =
*     IT_FILTER   =
*     IS_SEL_HIDE =
*     I_DEFAULT   = 'X'
*     I_SAVE      = ' '
*     IS_VARIANT  =
*     IT_EVENTS   =
*     IT_EVENT_EXIT                     =
*     IS_PRINT    =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
*     O_COMMON_HUB                      =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab    = gt_join
 EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS      = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.