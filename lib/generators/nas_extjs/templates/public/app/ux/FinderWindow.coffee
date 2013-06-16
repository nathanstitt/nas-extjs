Ext.define 'App.ux.FinderWindow'

    title: "Find"
    alias: 'widget.finder_window'
    extend: 'Ext.window.Window'
    height: 350
    autoDestroy: false
    closeAction: 'hide'
    width: 600
    modal: true

    layout:
        type: 'vbox'
        align: 'stretch'

    gridConfig: {}

    gridColumns: [ 'code', 'name' ]

    searchKey: 'code'
    dataType: 'string'

    initComponent: ->
        cols = []
        @items = [{
            name: 'search'
            value: @field_value
            xtype: 'textfield',
            enableKeyEvents: true
            listeners:
                scope: this
                keyup: this.onSearchKey
        }]

        for colConf in @gridColumns
            if ! Ext.isObject( colConf )
                colConf = { name: colConf }
            Ext.applyIf( colConf, {
                dataIndex: colConf.name
                queryBy: colConf.name
                sortable: true
                text: colConf.name.titleize()
            })
            cols.push( colConf )

        lastconf = cols[ cols.length-1 ]
        lastconf['flex'] = 1 unless lastconf['width'] || lastconf['flex']

        gridconfig = Ext.merge( {
            columns: cols
            store: @store
            loadMask: true
            flex: 1
        }, @gridConfig )
        @grid = Ext.create( 'Ext.grid.Panel', gridconfig )

        @grid.on('sortchange', (header,col, dir, opts )->
            @searchKey = col.queryBy
        , this )
        @grid.on('select', this.onRowSelected, this );
        this.on('hide', this.onHidden, this )

        @items.push( @grid )

        this.callParent()

    setTempStore: ( @temp_store )->
        @grid.reconfigure( @temp_store || @store)

    setTempQueryScope: ( @temp_scope )->
        @grid.getStore().setQueryScope( @temp_scope )

    setTempFilter: ( filter )->
        @temp_filter = filter
        @grid.getStore().addFilter( filter )

    setTempAssociations: ( names... )->
        @temp_associations = names
        store = @grid.getStore()
        store.addAssociations.apply( store, @temp_associations )

    onHidden:( win, opts) ->
        store = @grid.getStore()
        if @temp_filter
            for key in Object.keys(@temp_filter)
                store.removeFilter( key )
            store.removeAll()
            @temp_filter = false
        if @temp_scope
            store.removeQueryScope( @temp_scope ).removeAll()
            @temp_scope = false
        if @temp_associations
            store.removeAssociations.apply( store, @temp_associations ).removeAll()
            @temp_associations=false
        if @temp_store
            @grid.reconfigure( @store )
            store = @temp_store
            @temp_store=false
        if @dest_element
            @dest_element.fireEvent('searchhidden', @dest_element, this )
        this

    setDestinationElement: ( @dest_element)->

    setStore: (@store)->
        @grid.reconfigure( @store )
        this

    listeners:
        show: ->
            @grid.getSelectionModel().deselectAll()
            this.down('field[name=search]').focus(true,true)

    show: ( @dest_element, options={} )->
        store = @grid.getStore()
        if @dest_element
            @dest_element.fireEvent('showingsearch', @dest_element, this, options )
        if options.temporary_store
            this.setTempStore( options.temporary_store )
        if options.temporary_associations
            this.setTempAssociations.apply( this, options.temporary_associations )
        if options.temporary_filter
            this.setTempFilter( options.temporary_filter )
        store.clearFilter() if @clearFilterOnShow
        if @localFilter then  store.ensureLoaded() else store.load()

        this.callParent( arguments )
        Ext.Function.defer( @defaultSorter, 1, this )

    defaultSorter: ->
        column = @grid.columns[ 0 ]
        column.setSortState('DESC')

    shake: ->
        x=this.getPosition()[0]
        this.animate({
            to: { x: x-10 }
        }).animate({
            to: { x: x+20 }
        }).animate({
            to: { x: x-20 }
        }).animate({
            to: { x: x+10 }
        })

    onSearchKey: ( fld, e, opts ) ->
        if e.getKey() != e.ENTER
            this.setFilter( fld.getValue() )
        else
            store=@grid.getStore()
            if store.count()
                this.didSelectRecord( @grid.getStore().getAt(0) )
            else
                this.shake()
                fld.focus(true)

    onRowSelected: (rm,rec,indx, opts )->
        this.didSelectRecord( rec )

    didSelectRecord: ( rec )->
        this.hide( @dest_element, ->
            @dest_element.fireEvent('recordselected', @dest_element, rec, this )
        , this )

    setFilter: (val, opts = {} )->
        store = @grid.getStore()
        if @localFilter
            sk = @searchKey
            regex = new RegExp( '^' + val, "i");
            store.filterBy (rec,id)-> return rec.get(sk).match( regex )
        else
            filter = {}
            if val
                condition = filter[ @searchKey ] = { value: val }
                if 'int' != @dataType
                    condition['op']     = 'like'
                    condition['value'] += '%'
                Ext.apply( opts, {
                    filterBy: filter
                } )
            store.cancelLoad()
            store.load( opts )
