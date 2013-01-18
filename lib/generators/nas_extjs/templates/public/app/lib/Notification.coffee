Ext.define 'App.lib.Notification'

    requires: [
        'App.ux.Notification'
    ]

    statics:
        display: ( options )->
            this._ensureWidget()

            @widget.update( options.message ) if options.message
            @widget.setTitle( options.title ) if options.title
            @widget.setIconCls( "ux-notification-icon-#{options.icon}" ) if options.icon
            @widget.show()
            return @widget

        displayError: ( options )->
            this.display( Ext.merge(options,{
                icon: 'error', title: 'Error'
            }))

        _ensureWidget: ->
            return if @widget
            @widget = Ext.create('App.ux.Notification', {
                title: 'Notification'
                position: 't'
                closeAction: 'hide'
                iconCls: 'ux-notification-icon-information'
                autoCloseDelay: 7000
                slideInDuration: 500
                spacing: 20
                html: ''
            })
