Ext.define 'App.model.Base'

    extend   : 'Ext.data.Model'
    requires : [
        'App.model.BelongsTo'
        'Ext.data.reader.Json'
        'Ext.data.writer.Json'
        'Ext.data.proxy.Ajax'
        'Ext.util.Inflector'
    ]

    constructor: (options={})->
        if ! this.proxy and this.api_key
            this.setProxy( App.Util.makeProxy( this.api_key ) )

        if options.includeAssociations?
            this.setAssociations.apply( this, options.includeAssociations )

        this.callParent(arguments)

    setAssociations: ( names )->
        prx = this.getProxy()
        if prx.setAssociations
            prx.setAssociations.concat( names )
        else
            prx.setAssociations = names.slice(0)


    copyFrom: (sourceRecord) ->
        this.callParent( arguments )

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
                    this[ assoc.associatedName ]().each ( our_rec )->
                        if ( new_rec = new_records.get( our_rec.getId() ) )
                            our_rec.copyFrom( new_rec )


        , this )

    save: ( options={} )->
        if options.syncAssociations
            for opt in options.syncAssociations
                opt = Ext.Object.getKeys(opt)[0] if Ext.isObject( opt )
                if -1 == this.associations.findIndex("associatedName", opt )
                    throw "#{opt} isn't present in associations for #{this.$className}"
                this[ "sync_#{opt}" ] = true
            options.includeAssociations = if Ext.isArray( options.includeAssociations ) then Ext.concat( options.includeAssociations, options.syncAssociations ) else options.syncAssociations
            delete options.syncAssociations
        this.callParent( [options] )

    attrValues:( names... )->
        ret = {}
        for name in names
            ret[ name ] = this.get( name )
        ret

    recordIdentifier: ->
        this.getId()

    prefixedAttrs: (names...)->
        [ names, opts ] = Util.extractOptions( names )
        prefix = ( opts.prefix || Util.baseClassName( this ).underscore() ) + '_'
        ret = {}
        for name in names
            ret[ prefix+name ] = this.get( name )
        ret
