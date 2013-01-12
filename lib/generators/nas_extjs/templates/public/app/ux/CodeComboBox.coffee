Ext.define 'App.ux.CodeComboBox'
    alias: 'widget.code_combobox'
    extend: 'Ext.form.field.ComboBox'
    valueField: 'code'
    displayField: 'code'
    listeners:
        select:(cb,recs,opts)->
            editor=cb.up('form')
            if ( editor = editor.editingPlugin ) && editor.grid
                editor.grid.fireEvent( 'combobox_select', cb, recs[0], editor.getRecord(), editor, grid )
