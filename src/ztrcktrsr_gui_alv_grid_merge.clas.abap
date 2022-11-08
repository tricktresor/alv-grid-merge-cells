class ZTRCKTRSR_GUI_ALV_GRID_MERGE definition
  public
  inheriting from CL_GUI_ALV_GRID
  create public .

public section.

  methods Z_SET_MERGE_HORIZ
    importing
      !ROW type I
      !TAB_COL_MERGE type LVC_T_CO01 .
  methods Z_SET_MERGE_VERT
    importing
      !ROW type I
      !TAB_COL_MERGE type LVC_T_CO01 .
  methods Z_DISPLAY .
  methods Z_SET_CELL_STYLE
    importing
      !ROW type I optional
      !COL type I optional
      !STYLE type LVC_STYLE
      !STYLE2 type LVC_STYLE optional .
  methods Z_SET_FIXED_COL_ROW
    importing
      !COL type I
      !ROW type I .
  methods Z_INIT_CELL_STYLES .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTRCKTRSR_GUI_ALV_GRID_MERGE IMPLEMENTATION.


  METHOD Z_DISPLAY.

    DATA lv_stable TYPE lvc_s_stbl.
    DATA lv_soft   TYPE c.

**** Prepare refresh
*  lv_stable-row = 'X'.
*  lv_stable-col = 'X'.
*  lv_soft       = 'X'.
*
**** Refresh table because Z_SET_CELL_STYLE adds style-values
**** Refresh initializes mt_data
*  CALL METHOD refresh_table_display
*    EXPORTING
*      is_stable      = lv_stable
*      i_soft_refresh = lv_soft
*    EXCEPTIONS
*      OTHERS         = 1.

* Jetzt noch  übertragen der geänderten Daten
    me->set_data_table( CHANGING data_table = mt_data[] ).

    set_auto_redraw( enable = 1 ).

  ENDMETHOD.


  METHOD Z_INIT_CELL_STYLES.

    FIELD-SYMBOLS <data> TYPE lvc_s_data.
* Nur Spalte setze komplette Spalte
    LOOP AT mt_data ASSIGNING <data>.
      <data>-style = 0.
    ENDLOOP.

  ENDMETHOD.


  METHOD Z_SET_CELL_STYLE.

    FIELD-SYMBOLS <data> TYPE lvc_s_data.
    IF row IS INITIAL.
      IF col IS INITIAL.
* Beides leer -> nichts zu tun.
        EXIT.
      ELSE.
* Nur Spalte setze komplette Spalte
        LOOP AT mt_data ASSIGNING <data>
              WHERE col_pos = col.
          <data>-style  = <data>-style + style.
          <data>-style2 = <data>-style2 + style2.
        ENDLOOP.
      ENDIF.
    ELSE.
      IF col IS INITIAL.
* Nur Zeile eingegeben -> komplette Zeile setzen
        LOOP AT mt_data ASSIGNING <data>
              WHERE row_pos = row.
          <data>-style  = <data>-style + style.
          <data>-style2 = <data>-style2 + style2.
        ENDLOOP.
      ELSE.
        READ TABLE mt_data ASSIGNING <data>
            WITH KEY row_pos = row
                     col_pos = col.
        IF sy-subrc EQ 0.
          <data>-style  = <data>-style + style.
          <data>-style2 = <data>-style2 + style2.
        ELSE.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD Z_SET_FIXED_COL_ROW.

    me->set_fixed_cols( col ).
    me->set_fixed_rows( row ).

  ENDMETHOD.


  METHOD z_set_merge_horiz.

* ROW - Zeile deren Spalten zusammengeführt werden sollen
* tab_col_merge - Spalten, die zusammengeführt werden sollen
    FIELD-SYMBOLS <data> TYPE lvc_s_data.
    DATA outputlen TYPE i.

    DATA(cols) = tab_col_merge.

    SORT cols.

* Die Spalten, die zusammengeführt werden sollen
    LOOP AT cols INTO DATA(col) WHERE col_id > 0.
* ein paar Prüfungen
      IF col-outputlen <= col-col_id.
        CONTINUE.
      ENDIF.
      outputlen = col-outputlen - col-col_id.
      LOOP AT mt_data ASSIGNING <data>
           WHERE row_pos = row  AND
                 ( col_pos BETWEEN col-col_id AND
                                   col-outputlen ).
* Setze wie weit soll gemerged werden Von Spalte in Länge
* und zwar wird bei der 1 Spalte angefangen
        IF <data>-col_pos = col-col_id.
          <data>-mergehoriz = outputlen.
* bei allen anderen, die zusammangehören
* muss der Wert raus, da er aus der 1. Spalte kommt
* und das mergekennzeichen muss auch weg !
        ELSE.
          CLEAR <data>-mergehoriz.
          CLEAR <data>-value.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD Z_SET_MERGE_VERT.

* ROW - Zeile deren Spalten zusammengeführt werden sollen
* tab_col_merge - Spalten, die zusammengeführt werden sollen
    FIELD-SYMBOLS <data> TYPE lvc_s_data.
    DATA outputlen TYPE i.

    data(cols) = tab_col_merge.
    sort cols.

* Die Spalten, die zusammengeführt werden sollen
    LOOP AT cols into data(col) where col_id > 0.
* ein paar Prüfungen
      IF col-outputlen <= col-col_id.
        CONTINUE.
      ENDIF.
      outputlen = col-outputlen - col-col_id.
      LOOP AT mt_data ASSIGNING <data>
           WHERE row_pos = row  AND
                 ( col_pos BETWEEN col-col_id AND
                                   col-outputlen ).
* Setze wie weit soll gemerged werden Von Spalte in Länge
* und zwar wird bei der 1 Spalte angefangen
        IF <data>-col_pos = col-col_id.
          <data>-mergevert = outputlen.
* bei allen anderen, die zusammangehören
* muss der Wert raus, da er aus der 1. Spalte kommt
* und das mergekennzeichen muss auch weg !
        ELSE.
          CLEAR <data>-mergevert.
          CLEAR <data>-value.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
