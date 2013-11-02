Ext.define 'App.ux.CustomComboBox'
    alias: 'widget.custom_combobox'
    extend: 'Ext.form.field.ComboBox'

    _onSelect: (cb,recs,opts)->
        if ( form = cb.up('form') ) && ( editor = form.editingPlugin ) && editor.grid
            editor.grid.fireEvent( 'combobox_select', recs[0], {
                combobox:cb
                record: editor.getEditor().getRecord()
                form: form.getForm()
                editor: editor
                grid: editor.grid
            })


    wildCardRemoteQuery: (q, opts )->
        q.query=q.query.toUpperCase() + '%'
        true

    initComponent: ->
        this.callParent()
        this.on( 'select', this._onSelect )
        if 'remote' == this.queryMode
            this.on('beforequery', this.wildCardRemoteQuery )
        this
