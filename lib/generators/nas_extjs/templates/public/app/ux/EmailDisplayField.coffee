
Ext.define('App.ux.EmailDisplayField', {
    alias: 'widget.email_displayfield'
    extend: 'Ext.form.field.Display'

    renderer: (val)-> "<a href='mailto:#{val}'>#{val}</a>"
})
