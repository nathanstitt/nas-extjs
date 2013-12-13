Ext.define('App.ux.SelectedColumn', {
    extend: 'Ext.grid.column.Column'
    width: 55
    align: 'center'
    alias: 'widget.selectedcolumn'

    constructor: ->
        this.addEvents(
            'checkchange'
        );
        this.callParent(arguments)

    goodEventType: (type,e)->
        ( type == 'mousedown' || (type == 'keydown' && (e.getKey() == e.ENTER || e.getKey() == e.SPACE)) )

    processEvent: (type, view, cell, recordIndex, cellIndex, e)->
        if this.goodEventType( type,e )
            return false if this.readonly
            record = view.panel.store.getAt(recordIndex)
            dataIndex = this.dataIndex
            checked = !record.get(dataIndex);

            record.set(dataIndex, checked);
            this.fireEvent('checkchange', this, record, checked, recordIndex );
            # cancel selection.
            return false;
        else
            return this.callParent(arguments);



    renderer : (value)->
        cssPrefix = Ext.baseCSSPrefix
        cls = [cssPrefix + 'grid-selectheader'];

        if (value)
            cls.push(cssPrefix + 'grid-selectheader-checked')

        return '<div class="' + cls.join(' ') + '">&#160;</div>'

})

Ext.define('App.ux.ConditionalSelectedColumn', {
    extend: 'App.ux.SelectedColumn'
    alias: 'widget.conditional_selectedcolumn'

    conditionCheck: Ext.emptyFn

    renderer : (value,md,rec,rowIndex,colIndex,store,view)->
        me = this.columns[ colIndex ]
        if me.conditionCheck( rec )
           me.callParent( arguments )
        else
            ''

    processEvent: (type, view, cell, recordIndex, cellIndex, e)->
        if this.goodEventType( type, e ) && this.conditionCheck( view.getStore().getAt( recordIndex ) )
            this.callParent( arguments )
})
