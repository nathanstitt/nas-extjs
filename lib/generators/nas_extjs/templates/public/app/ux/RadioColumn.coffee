

Ext.define('App.ux.RadioColumn', {
    extend: 'Ext.grid.column.Column'
    alias: 'widget.radiocolumn'

    constructor: (opts)->
        @allowUnselect = opts.allowUselect || false
        this.addEvents( 'radiochange' );
        this.callParent(arguments);

    processEvent: (type, view, cell, recordIndex, cellIndex, e) ->
        if (type == 'mousedown' || (type == 'keydown' && (e.getKey() == e.ENTER || e.getKey() == e.SPACE)))
            record = view.panel.store.getAt(recordIndex)
            dataIndex = this.dataIndex

            val = record.get(dataIndex)
            if ! val
                view.panel.store.each (other)->
                    other.set(dataIndex,false)
            if ! val || @allowUnselect
                record.set(dataIndex, ! val)
                this.fireEvent('radiochange', this, recordIndex, val );

            return false;
        else
            return this.callParent(arguments);


    renderer : (value) ->
        cssPrefix = Ext.baseCSSPrefix
        cls = [ cssPrefix + 'grid-radioheader' ]
        if (value)
            cls.push(cssPrefix + 'grid-radioheader-radioed');
        return '<div class="' + cls.join(' ') + '">&#160;</div>';

})

