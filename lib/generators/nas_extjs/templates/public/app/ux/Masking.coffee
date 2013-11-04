Ext.define 'App.ux.Masking'

    statics:
        createAndShow: (element, options={})->
            sn = new App.ux.Masking( element, options )
            return sn
    successMsg: "Success!"
    failureMsg: "Failed"
    constructor: ( @element, options={} )->
        this.callParent()
        Ext.merge( this, options )
        @mask = new Ext.LoadMask( { target:  @element, msg: options.message || "Please wait..." } )
        # hide in 30 seconds regardless
        ( new Ext.util.DelayedTask( this._failSafeDestruct, this ) ).delay( 27000 )

        @mask.show()
        this

    onRequestComplete: ( was_success, msg=null, opts={} )->
        if was_success then this.displaySuccess( msg, opts ) else this.displayFailure( msg, opts )

    displaySuccess: ( msg = this.successMsg, opts={}  )->
        this._sceduleDestruct( opts.timeOut )
        @mask.hide()
        @mask.msg = msg
        this.mask.msgEl.addCls('success')
        @mask.show()

    displayFailure: ( msg = this.failureMsg, opts={} )->
        this._sceduleDestruct( opts.timeOut )
        @mask.hide()
        @mask.msg = msg
        this.mask.msgEl.addCls('failure')
        @mask.show()

    _failSafeDestruct: ->
        this.displayFailure("Action Timed Out...", { timeOut: 3000 }) if @mask

    _sceduleDestruct: (time=750)->
        ( new Ext.util.DelayedTask( this.destroy, this ) ).delay( time )

    destroy: ->
        return unless @mask
        @mask.destroy()
        delete this.mask
        if Ext.isFunction( @onDestroy )
            Ext.callback( @onDestroy )



App.Mask = App.ux.Masking.createAndShow
