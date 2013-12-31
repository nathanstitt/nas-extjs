Ext.define('App.model.Base', {

    extend   : 'Ext.data.Model'
    requires : [
        'App.lib.Util'
        'App.model.BelongsTo'
        'Ext.data.reader.Json'
        'Ext.data.writer.Json'
        'Ext.data.proxy.Ajax'
        'Ext.util.Inflector'
    ]
    statics:
        callAction: (me,opts)->
            me=this
            cb=opts.callback
            Ext.Ajax.request( Ext.merge( {}, opts, {
                method: 'POST',
                callback: (op,success, resp )->
                    msg = Ext.JSON.decode( resp.responseText )
                    Ext.callback( cb.callback, cb.scope || me, [ msg.data,
                        { success: msg.success, record: me, response: msg, operation: op }
                    ])
            }) )

    constructor: (options={})->
        if ! this.proxy and this.api_key
            this.setProxy( App.Util.makeProxy( this.api_key ) )

        if options.includeAssociations?
            this.setAssociations.apply( this, options.includeAssociations )

        this.callParent(arguments)

        this.associations.each( (assoc)->
            if assoc.alwaysInclude
                this.addAssociations( assoc.name )
        , this )

        for name, obj of this.mixins
            obj.initialize( this ) if obj.initialize

        this.recordIdentifier = this._recordIdentifier unless this.recordIdentifier

        this

    addAssociations: ( assoc... )->
        prx = this.getProxy()
        if prx.includeAssociations
            prx.includeAssociations = Ext.Array.merge( prx.includeAssociations, assoc )
        else
            prx.includeAssociations = assoc
        this

    setAssociations: ( names )->
        this.getProxy().includeAssociations = names.slice(0)
        this


    recordTypeName: ->
        Util.baseClassName(this)

    getTitle:->
        this.toString()

    _getRecordTypeName:->
        if Ext.isFunction( this.recordTypeName ) then this.recordTypeName() else this.recordTypeName

    toString:->
        this._getRecordTypeName() + ' ' + ( if this.phantom then "(new)" else String(this.recordIdentifier()) )


    prepareAssociatedData: (seenKeys, depth) ->
        data = this.callParent(arguments)
        if Ext.isObject(data)
             for name, assoc_data of data
                data[ Util.underscore(name) + '_attributes' ] = assoc_data
                delete data[name]
        data

    callAction: ( action, opts )->
        url = this.proxy.url + '/' + this.getId() + '/' + action
        me = this
        Ext.Ajax.request( Ext.merge( {}, opts, {
            method: 'POST', url: url
            callback: (op,success, resp )->
                msg = Ext.JSON.decode( resp.responseText )
                if opts.apply_data
                    me.set(msg.data)
                    me.commit()
                if opts.callback
                    Ext.callback( opts.callback, opts.scope || me, [ msg.data,
                        { success: msg.success, record: me, response: msg, operation: op }
                    ])
        } ) )

    copyFrom: (sourceRecord) ->
        this.callParent( arguments )
        for name, obj of this.mixins
            obj.copyModelDataFrom( this, sourceRecord ) if obj.copyModelDataFrom

        this.associations.each( (assoc)->
            if "belongsTo" == assoc.type
                is_loaded =  "is#{assoc.accessorName}Loaded"
                if sourceRecord[ is_loaded ]()
                    getter = "get#{assoc.accessorName}"
                    if this[ is_loaded ]()
                        this[ getter ]().copyFrom( sourceRecord[ getter ]() )
                    else
                        this[ "set#{assoc.accessorName}" ]( sourceRecord[ getter ]() )
            else if "hasMany" == assoc.type
                new_records = sourceRecord[ assoc.associatedName ]().data
                if this[ "sync_#{assoc.associatedName}"]
                    delete this["sync_#{assoc.associatedName}"]
                    this[ assoc.associatedName ]().loadRecords( new_records.getRange(), { addRecords: false } )
                else
                    for our_rec in this[ assoc.associatedName ]().getRange()
                        if ( new_rec = new_records.get( our_rec.getId() ) )
                            our_rec.copyFrom( new_rec )
        , this )

    save: ( options={} )->
        options.includeAssociations ||= []
        this.proxy.url = this.store.nestedUrl() if this.store && this.store.nestedUrl
        if options.syncAssociations
            for opt in options.syncAssociations
                opt = Ext.Object.getKeys(opt)[0] if Ext.isObject( opt )
                if -1 == this.associations.findIndex("associatedName", opt )
                    throw "#{opt} isn't present in associations for #{this.$className}"
                this[ "sync_#{opt}" ] = true
            options.includeAssociations = Ext.Array.union( options.includeAssociations, options.syncAssociations )
            delete options.syncAssociations
        this.callParent( [options] )

    attrValues:( names... )->
        ret = {}
        for name in names
            ret[ name ] = this.get( name )
        ret

    _recordIdentifier: ->
        this.getId()

    prefixedAttrs: (names...)->
        [ names, opts ] = Util.extractOptions( names )
        prefix = opts.prefix || ( Util.underscore( Util.baseClassName( this ) ) + '_' )
        ret = {}
        for name in names
            ret[ prefix+name ] = this.get( name )
        ret
})
