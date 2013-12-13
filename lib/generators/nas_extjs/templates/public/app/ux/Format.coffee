Ext.define( 'App.ux.Format', {
    singleton: true

    currency: Ext.util.Format.numberRenderer( '0,000.00' )

    positiveCurrency: (val)->
        App.ux.Format.currency( Math.abs( parseFloat(val) ) )

    shortTime: Ext.util.Format.dateRenderer( "Y-m-d h:ia" )
    shortDate: Ext.util.Format.dateRenderer( "Y-m-d" )


})