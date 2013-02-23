Ext.define 'App.lib.SaveNotify'

    statics:
        createAndShow: (element)->
            sn = new App.lib.SaveNotify( element )
            return sn

    constructor: ( @element )->
        this.callParent()
        @mask = new Ext.LoadMask( @element, { msg:"Saving, Please wait..."} )
        @mask.show()
        this

    saveRecord: (opts={})->
        rec = @element.getForm().updateRecord().getRecord()
        this.save( rec, opts )

    save: (model, @saveOptions={})->
        options=Ext.merge( Ext.clone(@saveOptions), {
            scope: this
            success: this._onSuccess
            failure: this._onFailure
        })
        model.save( options )

    _onSuccess: (rec,op)->
        @args   = arguments
        @status = 'success'
        this._sceduleDestruct()

    _onFailure: (rec,op)->
        @args   = arguments
        @status = 'failure'
        this._sceduleDestruct()

    _sceduleDestruct: ->
        @mask.hide()
        @mask.msg = Ext.String.capitalize( @status + '!')
        this.mask.msgEl.addCls( @status )
        @mask.show()
        ( new Ext.util.DelayedTask( this._destroyMask, this ) ).delay( 1500 )

    _destroyMask: ->
        @mask.destroy()
        if Ext.isFunction( @saveOptions[@status] )
            Ext.callback( @saveOptions[@status], @saveOptions.scope, @args )




App.SaveNotify = App.lib.SaveNotify.createAndShow
