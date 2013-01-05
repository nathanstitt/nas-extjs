

Ext.define 'App.lib.Overrides'
    singleton:true

    register: ->
        Ext.override( Ext.form.field.ComboBox, {
            getSelectedRecord: ->
                v = this.getValue();
                this.findRecord( this.valueField || this.displayField, v)
        } )
