*&---------------------------------------------------------------------*
*& Report ZHIR_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIR_REPORT.




TABLES: vbak, vbap.


SELECT-OPTIONS:
  s_vbeln FOR vbak-vbeln,
  s_vkorg FOR vbak-vkorg.


* Types

TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbak-vbeln,   "Sales Doc
         erdat TYPE vbak-erdat,   "Created On
         auart TYPE vbak-auart,   "Doc Type
         vkorg TYPE vbak-vkorg,   "Sales Org
       END OF ty_vbak.

TYPES: BEGIN OF ty_vbap,
         vbeln TYPE vbap-vbeln,   "Sales Doc
         posnr TYPE vbap-posnr,   "Item
         matnr TYPE vbap-matnr,   "Material
         kwmeng TYPE vbap-kwmeng, "Order Qty
       END OF ty_vbap.


* Data

DATA:
  gt_vbak     TYPE STANDARD TABLE OF ty_vbak,
  gt_vbap     TYPE STANDARD TABLE OF ty_vbap,
  it_fieldcat TYPE slis_t_fieldcat_alv,
  ls_fieldcat TYPE slis_fieldcat_alv,
  ls_key      TYPE slis_keyinfo_alv.


* START-OF-SELECTION

START-OF-SELECTION.


* Select Header Data (VBAK)

SELECT vbeln
       erdat
       auart
       vkorg
  FROM vbak
  INTO TABLE gt_vbak
  WHERE vbeln IN s_vbeln
    AND vkorg IN s_vkorg.

IF gt_vbak IS INITIAL.
  MESSAGE 'No sales orders found' TYPE 'I'.
  EXIT.
ENDIF.


* Select Item Data (VBAP)

SELECT vbeln
       posnr
       matnr
       kwmeng
  FROM vbap
  INTO TABLE gt_vbap
  FOR ALL ENTRIES IN gt_vbak
  WHERE vbeln = gt_vbak-vbeln.

IF gt_vbap IS INITIAL.
  MESSAGE 'No items found for selected orders' TYPE 'I'.
  EXIT.
ENDIF.


* Ensure Item → Header Consistency (CRITICAL)

SORT gt_vbak BY vbeln.
SORT gt_vbap BY vbeln.



* Build Field Catalog

PERFORM add_fieldcat USING 'GT_VBAK' 'VBELN' 'Sales Order'.
PERFORM add_fieldcat USING 'GT_VBAK' 'ERDAT' 'Created On'.
PERFORM add_fieldcat USING 'GT_VBAK' 'AUART' 'Order Type'.
PERFORM add_fieldcat USING 'GT_VBAK' 'VKORG' 'Sales Org'.

PERFORM add_fieldcat USING 'GT_VBAP' 'POSNR'  'Item'.
PERFORM add_fieldcat USING 'GT_VBAP' 'MATNR'  'Material'.
PERFORM add_fieldcat USING 'GT_VBAP' 'KWMENG' 'Order Qty'.


* Key Info

ls_key-header01 = 'VBELN'.
ls_key-item01   = 'VBELN'.


* Display Hierarchical ALV

CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
  EXPORTING
    it_fieldcat      = it_fieldcat
    i_tabname_header = 'GT_VBAK'
    i_tabname_item   = 'GT_VBAP'
    is_keyinfo       = ls_key
  TABLES
    t_outtab_header  = gt_vbak
    t_outtab_item    = gt_vbap.


* FORMS

FORM add_fieldcat USING p_tab p_field p_text.
  CLEAR ls_fieldcat.
  ls_fieldcat-tabname   = p_tab.
  ls_fieldcat-fieldname = p_field.
  ls_fieldcat-seltext_m = p_text.
  APPEND ls_fieldcat TO it_fieldcat.
ENDFORM.