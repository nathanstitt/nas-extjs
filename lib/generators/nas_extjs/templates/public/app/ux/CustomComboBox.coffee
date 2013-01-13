Ext.define 'App.ux.CustomComboBox'
    alias: 'widget.custom_combobox'
    extend: 'Ext.form.field.ComboBox'

    getSelectedRecord: ->
        v = this.getValue();
        this.findRecord( this.valueField || this.displayField, v)

    listeners:
        select:(cb,recs,opts)->
            if ( form = cb.up('form') ) && ( editor = form.editingPlugin ) && editor.grid
                editor.grid.fireEvent( 'combobox_select', recs[0], {
                    combobox:cb
                    record: editor.getEditor().getRecord(),
                    form: form,
                    editor: editor,
                    grid: editor.grid
                })
