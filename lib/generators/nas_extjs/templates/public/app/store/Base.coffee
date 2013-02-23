Ext.define 'App.store.Base'

    extend   : 'Ext.data.Store'
    buffered : false
    pageSize : 150
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

        if options.filterBy?
            this.setFilter( options.filterBy )
            delete options.filterBy

        if options.queryScope?
            this.setQueryScope( options.queryScope )

        if options.includeOptionalFields
            this.setOptionalFields( options.includeOptionalFields )

        if options.includeAssociations?
            this.setAssociations.apply( this, options.includeAssociations )

        this.callParent(arguments)
        this.on( 'load', this._onLoad )

        this.model.prototype.associations.each( (assoc)->
            if assoc.alwaysInclude
                this.addAssociations( assoc.name )
        , this )

        this


    setFilter: ( filt )->
        this.getProxy().filterBy = filt
        this

    setAssociations: ( assoc... )->
        this.getProxy().includeAssociations = assoc
        this

    addFilter: ( filt )->
        prx = this.getProxy()
        if prx.filterBy
            Ext.apply( prx.filterBy, filt )
        else
            this.setFilter( filt )
        this

    addAssociations: ( assoc... )->
        prx = this.getProxy()
        if prx.includeAssociations
            prx.includeAssociations = Ext.Array.merge( prx.includeAssociations, assoc )
        else
            prx.includeAssociations = assoc
        this

    setOptionalFields: ( fields )->
        this.getProxy().includeOptionalFields = fields
        this

    setQueryScope: ( qs )->
        this.getProxy().queryScope = qs
        this

    isLoaded: ->
        ( 0 != this.count() ) || this._isLoaded
    # was
    # ! ( 0 == this.count() ) && ( ! this.owningRecord || ! this.owningRecord.phantom ) && ( ! this._isLoaded? || ! this._isLoading() )
    ensureLoaded: ->
        unless @isLoaded()
            this.load()
        this

    _onLoad: (a,b,c)->
        this._isLoaded = true
        this.removeListener('load', this._onLoad )
