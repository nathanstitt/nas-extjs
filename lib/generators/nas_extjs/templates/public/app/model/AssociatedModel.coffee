Ext.define('App.model.Base', {
    extend: 'App.model.Base'

    require: [
        'App.model.BelongsTo'
    ]

    constructor: (options={})->
        if options[ 'setAssociations' ]
            this.setAssociations( options['setAssociations' ] )
            delete options.setAssociations
        Ext.apply( this, options )
        this.callParent(arguments)

})
