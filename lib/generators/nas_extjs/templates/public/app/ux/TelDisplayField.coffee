Ext.define( 'App.ux.TelDisplayField', {
    alias: 'widget.tel_displayfield'
    extend: 'Ext.form.field.Display'

    renderer: (val)-> "<a href='tel:#{val}'>#{val}</a>"


})