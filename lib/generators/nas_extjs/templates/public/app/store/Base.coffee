Ext.define('App.store.Base', {

    extend   : 'Ext.data.Store'
    buffered : false
    pageSize : 70
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

        if options.summaryFields?
            this.setSummaryFields( options.summaryFields )

        if options.includeAssociations?
            this.setAssociations.apply( this, options.includeAssociations )

        this.callParent(arguments)

        if this.defaultFilters
            this.setFilter( this.defaultFilters )

        this.on( 'load', this._onLoad )
        this.on( 'beforeload', this._onBeforeLoad )

        this.model.prototype.associations.each( (assoc)->
            if assoc.alwaysInclude
                this.addAssociations( assoc.name )
        , this )

        this

    clone: (options={})->
        prx = this.getProxy()
        store = Ext.create( this.$className, Ext.Object.merge({
            buffered: this.buffered, pageSize: this.pageSize, remoteSort: this.remoteSort
            filterBy: prx.filterBy,
            includeAssociations: prx.includeAssociations,
            queryScope: prx.queryScope
        }, options ) )
        store.proxy      = prx
        store.sorters    = this.sorters
        store.totalCount = this.totalCount
        store

    setSummaryFields: (fields)->
        this.getProxy().summaryFields = fields
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

    removeFilter: (filter_name)->
        prx = this.getProxy()
        if prx.filterBy
            delete prx.filterBy[ filter_name ]
        this

    removeQueryScope: ( qs )->
        prx = this.getProxy()
        delete prx.queryScope
        this

    removeAssociations: ( names... )->
        prx = this.getProxy()
        if prx.includeAssociations
            prx.includeAssociations.splice(index, 1) for index, value of prx.includeAssociations when value in names
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
        !! ( 0 != this.count() ) || this._isLoaded || this.isLoading()

    ensureLoaded: (cb)->
        if @isLoaded() || ( this.owningRecord && this.owningRecord.phantom )
            Ext.callback(cb.callback, cb.scope, [this] ) if cb
        else
            this.load(cb)
        this

    unFilteredData: ->
        (this.snapshot || this.data)

    cancelLoad: ->
        Ext.Ajax.abort( this._current_operation.request ) if this._current_operation

    _onBeforeLoad: ( me, operation )->
        this._current_operation = operation;
        true

    _onLoad: (a,b,c)->
        this._isLoaded = true
        this.removeListener('load', this._onLoad )
})
