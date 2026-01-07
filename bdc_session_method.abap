report ZMAT_SAMPLE01
       no standard page heading line-size 255.


PARAMETERS: p_file type localfile.

TYPES: BEGIN OF ty_material,
      MATNR TYPE MATNR,
      MAKTX TYPE MAKTX,
  MTART TYPE MTART,
  MBRSH TYPE MBRSH,
  MEINS TYPE MEINS ,
  END OF ty_material.

  DATA: gt_material TYPE TABLE of ty_material.

  DATA: lv_file type string.

DATA:   gt_BDCDATA TYPE TABLE of BDCDATA,
        wa_bdcdata type BDCDATA.     "OCCURS 0 WITH HEADER LINE.

data : gt_messages type table of BDCMSGCOLL.


at SELECTION-SCREEN on VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
   EXPORTING
     PROGRAM_NAME        = SYST-CPROG
     DYNPRO_NUMBER       = SYST-DYNNR
     FIELD_NAME          = ' '
   IMPORTING
     FILE_NAME           = p_file. "char128


START-OF-SELECTION. "interact with data

lv_file = p_file.

CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    filename                      = lv_file "string
*   FILETYPE                      = 'ASC'
   HAS_FIELD_SEPARATOR           = 'X'
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
*   DAT_MODE                      = ' '
*   CODEPAGE                      = ' '
*   IGNORE_CERR                   = ABAP_TRUE
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER                        =
  tables
    data_tab                      = gt_material  "store data --> import data to sap system
* CHANGING
*   ISSCANPERFORMED               = ' '
 EXCEPTIONS
   FILE_OPEN_ERROR               = 1
   FILE_READ_ERROR               = 2
   NO_BATCH                      = 3
   GUI_REFUSE_FILETRANSFER       = 4
   INVALID_TYPE                  = 5
   NO_AUTHORITY                  = 6
   UNKNOWN_ERROR                 = 7
   BAD_DATA_FORMAT               = 8
   HEADER_NOT_ALLOWED            = 9
   SEPARATOR_NOT_ALLOWED         = 10
   HEADER_TOO_LONG               = 11
   UNKNOWN_DP_ERROR              = 12
   ACCESS_DENIED                 = 13
   DP_OUT_OF_MEMORY              = 14
   DISK_FULL                     = 15
   DP_TIMEOUT                    = 16
   OTHERS                        = 17
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.





* Include bdcrecx1_s:
* The call transaction using is called WITH AUTHORITY-CHECK!
* If you have own auth.-checks you can use include bdcrecx1 instead.
*include bdcrecx1_s.
*
*start-of-selection.


"These are the steps for one record only


" perform saame steps for multiple --> loops

*MAT1011  Material 01 DP06  2 EA
*MAT1012  Material 02 BMS 2 EA      -->gt_bdcdata
*MAT1013  Material 03 BMS C EA
*MAT1014  Material 04 BT96  C EA
*MAT1015  Material 05 BT97  C EA

CALL FUNCTION 'BDC_OPEN_GROUP'
 EXPORTING
   CLIENT                    = SY-MANDT
*   DEST                      = FILLER8
   GROUP                     = 'MM01_GRP'
   HOLDDATE                  = sy-datum
   KEEP                      = 'X'
USER                      = sy-uname
*   RECORD                    = FILLER1
*   PROG                      = SY-CPROG
*   DCPFM                     = '%'
*   DATFM                     = '%'
*   APP_AREA                  = FILLER12
*   LANGU                     = SY-LANGU
* IMPORTING
*   QID                       =
* EXCEPTIONS
*   CLIENT_INVALID            = 1
*   DESTINATION_INVALID       = 2
*   GROUP_INVALID             = 3
*   GROUP_IS_LOCKED           = 4
*   HOLDDATE_INVALID          = 5
*   INTERNAL_ERROR            = 6
*   QUEUE_ERROR               = 7
*   RUNNING                   = 8
*   SYSTEM_LOCK_ERROR         = 9
*   USER_INVALID              = 10
*   OTHERS                    = 11
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


LOOP AT gt_material INTO DATA(wa_material).


*perform open_group.

PERFORM bdc_dynpro      USING 'SAPLMGMM' '0060'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RMMG1-MTART'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM bdc_field       USING 'RMMG1-MATNR'
                                wa_material-matnr.
  PERFORM bdc_field       USING 'RMMG1-MBRSH'
                                wa_material-mbrsh.
  PERFORM bdc_field       USING 'RMMG1-MTART'
                                wa_material-mtart.
  PERFORM bdc_dynpro      USING 'SAPLMGMM' '0070'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'MSICHTAUSW-DYTXT(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM bdc_field       USING 'MSICHTAUSW-KZSEL(01)'
                                'X'.
  PERFORM bdc_dynpro      USING 'SAPLMGMM' '4004'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'MAKT-MAKTX'
                                wa_material-maktx.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'MARA-MEINS'.
  PERFORM bdc_field       USING 'MARA-MEINS'
                                wa_material-meins.
  PERFORM bdc_field       USING 'MARA-MTPOS_MARA'
                                'NORM'.


CALL FUNCTION 'BDC_INSERT'
 EXPORTING
   TCODE                  = 'MM01'
*   POST_LOCAL             = NOVBLOCAL
*   PRINTING               = NOPRINT
*   SIMUBATCH              = ' '
*   CTUPARAMS              = ' '
  TABLES
    dynprotab              = gt_bdcdata
* EXCEPTIONS
*   INTERNAL_ERROR         = 1
*   NOT_OPEN               = 2
*   QUEUE_ERROR            = 3
*   TCODE_INVALID          = 4
*   PRINTING_INVALID       = 5
*   POSTING_INVALID        = 6
*   OTHERS                 = 7
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.



*call TRANSACTION 'MM01' USING gt_bdcdata mode 'A' UPDATE 'A' MESSAGES INTO gt_messages.
*
CLEAR gt_bdcdata.

*perform bdc_transaction using 'MM01'.
*
*perform close_group.

ENDLOOP.


CALL FUNCTION 'BDC_CLOSE_GROUP'
 EXCEPTIONS
   NOT_OPEN          = 1
   QUEUE_ERROR       = 2
   OTHERS            = 3
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.




FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR wa_BDCDATA.
  wa_BDCDATA-PROGRAM  = PROGRAM.
  wa_BDCDATA-DYNPRO   = DYNPRO.
  wa_BDCDATA-DYNBEGIN = 'X'.
  APPEND wa_BDCDATA to gt_bdcdata.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.

    CLEAR wa_BDCDATA.
    wa_BDCDATA-FNAM = FNAM.
    wa_BDCDATA-FVAL = FVAL.
    APPEND wa_BDCDATA to gt_bdcdata.

ENDFORM.