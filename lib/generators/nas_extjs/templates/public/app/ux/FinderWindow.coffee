

Ext.define 'App.ux.FinderWindow'

    title: "Find"
    alias: 'widget.finder_window'
    extend: 'Ext.window.Window'
    height: 200
    autoDestroy: false
    closeAction: 'hide'
    width: 400
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

        cols[ cols.length-1 ]['flex']=1

        gridconfig = Ext.merge( @gridConfig, {
            columns: cols
            store: @store
            loadMask: true
            flex: 1
        } )
        @grid = Ext.create( 'Ext.grid.Panel', gridconfig )

        @grid.on('sortchange', (header,col, dir, opts )->
            @searchKey = col.queryBy
        , this )
        @grid.on('select', this.onRowSelected, this );
        @grid.on('hide', this.onHidden, this )
        @items.push( @grid )

        this.callParent()

    setTempStore: ( @temp_store )->
        @grid.reconfigure( @temp_store || @store)


    onHidden:( win, opts) ->
        if @temp_store
            @grid.reconfigure( @store )
            @temp_store=false

    setDestinationElement: ( @dest_element)->

    setStore: (@store)->
        @grid.reconfigure( @store )
        this

    listeners:
        show: ->
            @grid.getSelectionModel().deselectAll()
            this.down('field[name=search]').focus(true,true)

    show: ( @dest_element )->
        @store.clearFilter() if @clearFilterOnShow
        if @localFilter then  @store.ensureLoaded() else @store.load()

        this.callParent( arguments )
        Ext.Function.defer( ->
            column = @grid.columns[ 0 ]
            column.setSortState('ASC')
        ,1, this )


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
            store.load( opts )
