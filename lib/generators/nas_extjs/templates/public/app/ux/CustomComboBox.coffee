Ext.define 'App.ux.CustomComboBox'
    alias: 'widget.custom_combobox'
    extend: 'Ext.form.field.ComboBox'

    getSelectedRecord: ->
        v = this.getRawValue()
        this.findRecord( this.valueField, v) || this.findRecord( this.displayField, v)

    _onSelect: (cb,recs,opts)->
        if ( form = cb.up('form') ) && ( editor = form.editingPlugin ) && editor.grid
            editor.grid.fireEvent( 'combobox_select', recs[0], {
                combobox:cb
                record: editor.getEditor().getRecord()
                form: form.getForm()
                editor: editor
                grid: editor.grid
            })


    initComponent: ->
        this.callParent()
        this.on( 'select', this._onSelect )
