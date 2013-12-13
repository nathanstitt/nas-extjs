Ext.define( 'App.lib.Notification', {

    requires: [
        'App.ux.Notification'
    ]

    statics:
        display: ( options )->
            this._ensureWidget()

            @widget.update( if options.message then options.message else '' )
            @widget.setTitle( if options.title then options.title else '' )
            @widget.setIconCls( if options.icon then "ux-notification-icon-#{options.icon}" else '' )
            @widget.show()
            return @widget

        displayError: ( options )->
            if Ext.isString( options ) then options = { message: options }
            this.display( Ext.merge({
                icon: 'error', title: 'Error'
            }, options ))

        _ensureWidget: ->
            return if @widget
            @widget = Ext.create('App.ux.Notification', {
                title: 'Notification'
                position: 't'
                minWidth: 200
                closeAction: 'hide'
                iconCls: 'ux-notification-icon-information'
                autoCloseDelay: 7000
                slideInDuration: 500
                spacing: 20
                html: ''
            })


})