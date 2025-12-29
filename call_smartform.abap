REPORT zcall_sf_matnr_one_file.

*---------------------------------------------------------------------*
* Input
*---------------------------------------------------------------------*
PARAMETERS: p_matnr TYPE matnr.

*---------------------------------------------------------------------*
* Table line type (ONLY required fields)
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_item,
         posnr   TYPE posnr_va,   "Item number
         matnr   TYPE matnr,      "Material
         qty     TYPE kwmeng,     "Quantity
         amount  TYPE netwr,      "Net amount
       END OF ty_item.

*---------------------------------------------------------------------*
* Internal table
*---------------------------------------------------------------------*
DATA: gt_items TYPE TABLE OF ty_item.

*---------------------------------------------------------------------*
* Fetch data from VBAP
*---------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT posnr
         matnr
         kwmeng AS qty
         netwr  AS amount
    FROM vbap
    WHERE matnr = @p_matnr
    INTO TABLE @gt_items.

  IF gt_items IS INITIAL.
    MESSAGE 'No data found for given material' TYPE 'I'.
    EXIT.
  ENDIF.

*---------------------------------------------------------------------*
* Call Smart Form
*---------------------------------------------------------------------*
  PERFORM call_smartform.

*---------------------------------------------------------------------*
* Form to call Smart Form
*---------------------------------------------------------------------*
FORM call_smartform.

  DATA: lv_fm_name TYPE rs38l_fnam.

  "Get generated FM name of Smart Form
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = 'ZSF_MATERIAL_ITEMS'   "Smart Form name
    IMPORTING
      fm_name  = lv_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE 'Unable to get Smart Form FM name' TYPE 'E'.
  ENDIF.

  "Call Smart Form – pass ONLY internal table
  CALL FUNCTION lv_fm_name
    TABLES
      it_items = gt_items
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
      OTHERS           = 5.

  IF sy-subrc <> 0.
    MESSAGE 'Error while calling Smart Form' TYPE 'E'.
  ENDIF.

ENDFORM.