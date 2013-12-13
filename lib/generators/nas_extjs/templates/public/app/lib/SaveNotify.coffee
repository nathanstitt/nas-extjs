Ext.define( 'App.lib.SaveNotify', {

    statics:
        createAndShow: (element)->
            sn = new App.lib.SaveNotify( element )
            return sn

    constructor: ( @element )->
        this.callParent()
        @mask = App.ux.Masking.createAndShow( @element, {
            message: 'Saving, Please Wait...'
            onDestroy: Ext.bind( this._callback, this )
        })

        this

    saveRecord: (opts={})->
        rec = @element.getForm().updateRecord().getRecord()
        this.save( rec, opts )

    save: (@model, @saveOptions={})->
        for grid in @element.query('grid')
            if grid.plugins && ( editor = grid.getPlugin('editor') )
                editor.cancelEdit()

        options=Ext.merge( Ext.clone(@saveOptions), {
            scope: this
            success: this._onSuccess
            failure: this._onFailure
        })
        @model.save( options )

    _onSuccess: (rec,op)->
        @status = 'success'
        @args = [ @model, op ]
        @mask.displaySuccess()


    _onFailure: (rec,op)->
        @status = 'failure'
        @args = [ @model, op ]
        @mask.displayFailure()

    _callback: ->
        if Ext.isFunction( @saveOptions[@status] )
            Ext.callback( @saveOptions[@status], @saveOptions.scope, @args )


})

App.SaveNotify = App.lib.SaveNotify.createAndShow
