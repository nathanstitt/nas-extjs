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
        this._sceduleDestruct()
        @mask.hide()
        @mask.msg = "Success!"
        this.mask.msgEl.addCls('success')
        @mask.show()
        if Ext.isFunction( @saveOptions.success )
            Ext.callback( @saveOptions.success, @saveOptions.scope,[ rec, op ] )

    _onFailure: (rec,op)->
        this._sceduleDestruct()
        @mask.hide()
        @mask.msg = "Failed"
        this.mask.msgEl.addCls('failure')
        @mask.show()
        if @saveOptions.failure
           Ext.callback( @saveOptions.failure, @saveOptions.scope,[ rec, op ] )


    _sceduleDestruct: ->
        ( new Ext.util.DelayedTask( this._destroyMask, this ) ).delay( 1500 )

    _destroyMask: ->
        @mask.destroy()


App.SaveNotify = App.lib.SaveNotify.createAndShow
