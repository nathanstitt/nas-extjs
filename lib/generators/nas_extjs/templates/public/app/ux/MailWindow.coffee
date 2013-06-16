

Ext.define 'App.ux.MailWindow'

    extend: 'Ext.window.Window'
    title: "Send Email"
    requires:[
        'App.store.EmailArray'
        'App.ux.BoxSelect'
        'App.model.Message'
    ]

    alias: 'widget.mail_window'
    height: 400

    closeAction: 'hide'

    width: 400

    layout: 'fit'

    formConfig: {
        xtype:'form', border: false, labelAlign: 'right', labelWidth: 70, layout: {type:'vbox',align:'stretch' }
        defaults:{ labelWidth: 70, margin:'3 8', labelAlign:'right', border: false }
        items:[
            {
                layout:{ type: 'hbox', align: 'stretch' }, defaults: {labelAlign: 'right', labelWidth: 70}, margin: '8'
                items: [
                    { name: 'sender',  fieldLabel: 'From', xtype: 'textfield', flex: 1 }
                    { name: 'cc_self', fieldLabel: 'Copy Self', xtype: 'checkbox' }

                ]
            },
            { name: 'recipient',  fieldLabel: 'To', xtype: 'textfield' }
            {
                name: 'cc', fieldLabel: 'CC'
                xtype: 'boxselect', queryMode: 'local', displayField: 'email'#, store:'EmailArray'
                valueField:'email', forceSelection:false, createNewOnEnter: true
                createNewOnBlur: true, hideTrigger:true
            }
            { name: 'subject',  fieldLabel: 'Subject', xtype: 'textfield' }
            { name: 'message', xtype: 'textarea',flex: 1, height: 55, margin:'8' }
            {
                layout:{ type: 'hbox', align: 'center', pack:'center' }, defaults: {margin: '0 8'}, margin: '0 0 8 0'
                items: [
                    { xtype:'button', name:'cancel', text: 'Cancel' }
                    { xtype:'button', name:'send',   text: 'Send', iconCls:'icon-email_go' }
                ]
            }
        ]
    }

    listeners:
        show:(win)->
            win.down('field[name=subject]').focus(true,true)

    setValues: (obj)->
        this.down('form').getForm().setValues( obj )

        this.setCCs( if Ext.isArray(obj.cc) then obj.cc else [] )
        if ! obj.sender
            this.setSenderToCurrentUser()

    setCCs:( emails )->
        fld = this.down('field[name=cc]')
        store = fld.getStore()
        fld.setValue( emails )
        store.removeAll()
        for email in emails
            store.add( { email: email } )

    setRecord:( rec )->
        this.down('form').getForm().loadRecord( rec )
        this.setCCs( if Ext.isArray(rec.get('cc')) then rec.get('cc') else [] )
        if ! rec.get('sender')
            this.setSenderToCurrentUser()

    setSenderToCurrentUser: ->
        this.down('field[name=sender]').setValue(Application.current_user.getEmailWithName() )

    getRecord: ()->
        this.down('form').getForm().getRecord()

    updateRecord: (rec)->
        this.down('form').getForm().updateRecord(rec)
        this

    getValues: ->
        this.down('form').getForm().getValues()


    onSend: ->
        this.hide( @dest_element, ->
            this.fireCustomEvent('msg_send')
        ,this )


    onCancel: ->
        this.hide( @dest_element, ->
            this.fireCustomEvent('msg_cancel')
        ,this )

    show: ( @dest_element )->
        this.callParent( arguments )

    fireCustomEvent:(name)->
        this.fireEvent(name,this)
        if @dest_element
            @dest_element.fireEvent( name, @dest_element, this )

    onHidden: ->
        this.fireCustomEvent('msg_cancel')

    initComponent: ->
        this.items = [ Ext.clone(this.formConfig) ]
        if this.xtraFields
            this.items[0].items.splice( 3, 0, {
                items: this.xtraFields
                name:'xtraFields', baseCls: 'x-plain', border: false
                layout:{ type: 'hbox', align: 'stretch' }
                defaults: {labelAlign: 'right', labelWidth: 70}
            })

        this.items[0].items[2].store = Ext.create('App.store.EmailArray')
        this.callParent(arguments)
        this.addEvents('msg_cancel','msg_send')
        if this.values
            this.setValues( this.values )
        this.down('button[name=send]').on('click',this.onSend, this )
        this.down('button[name=cancel]').on('click',this.onCancel, this )
        this.on('hide', this.onHidden, this )


if window.Application
    win = null
    console.clear()
    Ext.ComponentManager.all.each (key,obj)->
        win = obj if 'mail_window' == obj.xtype
    if win
        win.close()


    win = Ext.create('App.ux.MailWindow',{
        xtraFields: [
            { name: 'attach', fieldLabel: 'Attach PO', xtype: 'checkbox'}
            { name: 'use_generic', fieldLabel: 'Std Msg', xtype: 'checkbox'}
        ]
        values: {
            sender:'bob@test.com', cc_self: true
            cc:['nathan@stitt.org','bob@here.com','foo@bar.com']
            attach: true
        }
    })
    console.dir win.getValues()
    win.show()
