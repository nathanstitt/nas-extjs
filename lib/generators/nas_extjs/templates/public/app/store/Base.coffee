Ext.define 'App.store.Base'

    extend: 'Ext.data.Store'
    buffered: false
    pageSize: 50

    constructor: (options={})->
        this.setProxy( App.Util.makeProxy( this.api_key ) )

        if options.filterBy?
            this.setFilter( options.filterBy )

        if options.queryScope?
            this.setQueryScope( options.queryScope )

        if options.includeAssociations?
            this.setAssociations.apply( this, options.includeAssociations )

        this.callParent(arguments)
        this.on( 'load', this._onLoad )
        this


    setFilter: ( filt )->
        this.getProxy().filterBy = filt

    setAssociations: ( assoc... )->
        this.getProxy().includeAssociations = assoc

    addFilter: ( filt )->
        prx = this.getProxy()
        if prx.filterBy
            Ext.apply( prx.filterBy, filt )
        else
            this.setFilter( filt )

    addAssociations: ( assoc... )->
        prx = this.getProxy()
        if prx.includeAssociations
            prx.includeAssociations = Ext.Array.merge( prx.includeAssociations, assoc )
        else
            prx.includeAssociations = assoc

    setQueryScope: ( qs )->
        this.getProxy().queryScope = qs


    ensureLoaded: ->
        if ( 0 == this.count() ) && ( ! this.owningRecord || ! this.owningRecord.phantom ) && ( ! this.isLoaded? || ! this.isLoading() )
            this.load()

    _onLoad: (a,b,c)->
        this.isLoaded = true
        this.removeListener('load', this._onLoad )


# Ext.define('App.store.Base', {

#     extend: 'Ext.data.Store'
#     buffered: false
#     pageSize: 50

#     setFilter: ( filt )->
#         this.getProxy().filterBy = filt

#     setAssociations: ( assoc... )->
#         this.getProxy().includeAssociations = assoc

#     addFilter: ( filt )->
#         this.getProxy()
#         if prx.filterBy
#             Ext.apply( prx.filterBy, filt )
#         else
#             this.setFilter( filt )

#     addAssociations: ( assoc... )->
#         prx = this.getProxy()
#         if prx.includeAssociations
#             prx.includeAssociations = Ext.Array.merge( prx.includeAssociations, assoc )
#         else
#             prx.includeAssociations = assoc

#     constructor: (options={})->
#         if options.filterBy?
#             this.setFilter( options.filterBy )
#             delete options.filterBy
#         Ext.apply( this, options )

#         if options.queryScope? || options.includeAssociations?
#             proxy = this.setProxy( App.Util.makeProxy( this.proxy.api_key ) )
#             if options.queryScope?
#                 proxy.queryScope = options.queryScope

#             if options.includeAssociations?
#                 this.setAssociations.apply( this, options.includeAssociations )
#                 delete options.includeAssociations

#         this.callParent(arguments)
#         this.on( 'load', this._onLoad )
#         this


#     ensureLoaded: ->
#         if ( 0 == this.count() ) && ( ! this.owningRecord || ! this.owningRecord.phantom ) && ( ! this.isLoaded? || ! this.isLoading() )
#             this.load()

#     _onLoad: (a,b,c)->
#         this.isLoaded = true
#         this.removeListener('load', this._onLoad )


# })
