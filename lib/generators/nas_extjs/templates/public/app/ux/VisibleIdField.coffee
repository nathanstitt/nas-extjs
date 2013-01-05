Ext.define 'App.ux.VisibleIdField'
    extend: 'App.ux.CodeField'
    alias: 'widget.visible_id_field'
    searchKey: 'visible_id'

    fieldLabel: 'ID'
    vtype: 'visibleId'
    allowBlank: false
    minLength: 1
