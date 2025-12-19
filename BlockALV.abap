*&---------------------------------------------------------------------*
*& Report ZHIR_REPORT2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBLOCK_REPORT.

TABLES : VBAP, VBAk.

SELECT-OPTIONS: p_vbeln for VBAP-vbeln.


TYPES: BEGIN OF ty_vbak,
  VBELN type VBELN_VA,
  ERDAT type ERDAT,
  END OF ty_vbak.


  TYPES: BEGIN OF ty_vbap,
    VBELN type vbeln_va,
    POSNR type POSNR_VA,
    MATNR type MATNR,
    END OF ty_vbap.

DATA: lt_vbak type table of ty_vbak,
      lt_vbap type table of ty_vbap.


    SELECT VBELN, ERDAT
      FROM vbak
      WHERE vbeln in @p_vbeln
      INto TABLE @lt_vbak
      .

"for all entries----
      if lt_vbak is NOT INITIAL.

        SELECT VBELN, POSNR, MATNR
          FROM vbap
          FOR ALL ENTRIES IN @lt_vbak
          WHERE vbeln = @lt_vbak-vbeln
          INTO TABLE @lt_vbap.


        ENDIF.

"create a fieldcat

DATA: lt_fieldcat type slis_t_fieldcat_alv.
DATA: lt_fieldcat2 type slis_t_fieldcat_alv,
      ls_fieldcat type slis_fieldcat_alv.



"mordern way to create fieldcat "update syntax

"value expression to fill internal tables ---
 lt_fieldcat = VALUE #(
 ( fieldname = 'VBELN' col_pos = '01' tabname = 'LT_VBAK' seltext_m = 'Sales no'   )  "first field of internal table
 ( fieldname = 'ERDAT' col_pos = '02' tabname = 'LT_VBAK' seltext_m = 'creation date'   )  "first field of internal table

 ).

 lt_fieldcat2 = VALUE #(

 ( fieldname = 'POSNR' col_pos = '03' tabname = 'LT_VBAP' seltext_m = 'Postal code'   )  "first field of internal table
 ( fieldname = 'MATNR' col_pos = '04' tabname = 'LT_VBAP' seltext_m = 'material no'   )  "first field of internal table
 ).

CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
  EXPORTING
    i_callback_program             = sy-repid
*   I_CALLBACK_PF_STATUS_SET       = ' '
*   I_CALLBACK_USER_COMMAND        = ' '
*   IT_EXCLUDING                   =
          .

DATA: ls_layout TYPE SLIS_LAYOUT_ALV.
DATA: ls_event TYPE SLIS_T_EVENT.

CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
  EXPORTING
    is_layout                        = ls_layout
    it_fieldcat                      = lt_fieldcat
    i_tabname                        = 'LT_VBAK'
    it_events                        = ls_event
*   IT_SORT                          =
   I_TEXT                           = 'Header data'
  TABLES
    t_outtab                         = lt_vbak
* EXCEPTIONS
*   PROGRAM_ERROR                    = 1
*   MAXIMUM_OF_APPENDS_REACHED       = 2
*   OTHERS                           = 3
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

DATA: ls_layout1 TYPE SLIS_LAYOUT_ALV.
DATA: ls_event1 TYPE SLIS_T_EVENT.

CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
  EXPORTING
    is_layout                        = ls_layout1
    it_fieldcat                      = lt_fieldcat2
    i_tabname                        = 'LT_VBAP'
    it_events                        = ls_event1
*   IT_SORT                          =
   I_TEXT                           = 'Header data'
  TABLES
    t_outtab                         = lt_vbap
* EXCEPTIONS
*   PROGRAM_ERROR                    = 1
*   MAXIMUM_OF_APPENDS_REACHED       = 2
*   OTHERS                           = 3
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'
* EXPORTING
*   I_INTERFACE_CHECK             = ' '
*   IS_PRINT                      =
*   I_SCREEN_START_COLUMN         = 0
*   I_SCREEN_START_LINE           = 0
*   I_SCREEN_END_COLUMN           = 0
*   I_SCREEN_END_LINE             = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER       =
*   ES_EXIT_CAUSED_BY_USER        =
* EXCEPTIONS
*   PROGRAM_ERROR                 = 1
*   OTHERS                        = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.