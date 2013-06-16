Ext.define 'App.model.Message'

    extend: 'App.model.Base'

    fields: [
        { name:'id', type: 'int', useNull: true }
        { name:'source_id', type: 'int', useNull: true }
        { name:'source', type: 'auto' }
        { name:'source_type', type: 'auto' }
        { name:'sender', type: 'auto' }
        { name:'recipient', type: 'auto' }
        { name:'cc', type: 'auto' }
        { name:'subject', type: 'auto' }
        { name:'tracking_number', type: 'auto'  }
        { name:'message', type: 'auto'  }
        { name:'attach', type: 'bool', defaultValue: true }
        { name:'transmitted_at', type: 'date', dateFormat:'c' }
        { name:'created_at', type: 'date', persist: false, dateFormat:'c' }
        { name:'created_by_id', type: 'int', useNull: true }
    ]

    proxy: App.Util.makeProxy( 'messages' )


    associations: [
        { associatedName: 'attachments',  type: 'hasMany',   model: 'App.model.Attachment', foreignKey: 'message_id', primary_key: 'id' }
    ]

    mixins:
        polysrc: 'App.model.mixins.PolymorphicSource'

    defaultMessages:
        PurchaseOrder: new Ext.Template('Attached please find Purchase Order # {visible_id}\n\nThank You!',{ compiled: true})
        SalesOrder: new Ext.Template('',{ compiled: true})
        Invoice: new Ext.Template('',{ compiled: true})

    defaultSubjects:
        PurchaseOrder: new Ext.Template('Purchase Order # {visible_id}',{ compiled: true})
        SalesOrder: new Ext.Template('Sales Order # {visible_id}',{ compiled: true})
        Invoice: new Ext.Template('Invoice # {visible_id}',{ compiled: true})

    setSource:(obj)->
        this.mixins.polysrc.setSource.call( this, obj)
        if ! this.get('message')
            this.set( 'message', @defaultMessages[ Util.baseClassName(obj) ].apply( obj.data ) )

        if ! this.get('subject')
            this.set( 'subject', @defaultSubjects[ Util.baseClassName(obj) ].apply( obj.data ) )

        this

    send:(options)->
        this.save({
            scope: this
            success: (rec)->
                if rec.data.source && ( src = this.getSource() )
                    src.set( rec.data.source )
                Ext.callback( options.success, options.scope, [this])
        })