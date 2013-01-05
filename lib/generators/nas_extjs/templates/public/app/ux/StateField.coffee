
Ext.ns('App.ux')



Ext.define 'App.ux.StateField'
    alias: 'widget.state_field'
    extend: 'Ext.form.field.ComboBox'
    allowBlank: true
    foceSelection: true
    store:  [ ['',''] ]
    fieldLabel: 'State'
    hidden: true
    queryMode: 'local'
    name: 'state'

    listeners:
        change: (cb,nv,ov,opts)->
            rec = cb.up('form').getForm().getRecord()
            if rec && ! ov # set for first time
                vals = []
                for state in ( rec.get('valid_state_events') || [] )
                    vals.push( [ state, state.humanize() ] )
                cb.getStore().loadRawData( vals )




        select: (cb,recs,opts)->
            parent = cb.up('form').getForm().getRecord()
            parent.set( 'state_event', recs[0].get('field1') )
