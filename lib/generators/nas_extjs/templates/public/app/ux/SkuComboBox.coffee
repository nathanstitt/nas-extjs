Ext.define 'App.ux.SkuComboBox'

    alias: 'widget.sku_combobox'
    extend: 'App.ux.CodeComboBox'
    valueField: 'id'
    displayField: 'code'
    queryParam: 'query[code]'
    queryMode: 'remote'
    queryDelay: 300
    remoteFilter: true
    caseSensitive: false
    editable: true
    typeAhead: true
    store: 'Skus'
    minChars: 1
    listConfig:
        getInnerTpl: ->
            "<strong>{code}</strong><br/>{description}"

    fixupQuery: (q, opts )->
        q.query=q.query.toUpperCase() + '%'
        true

    initComponent: ->
        this.callParent()
        this.on('beforequery', this.fixupQuery )
