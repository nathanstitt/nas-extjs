

Ext.define 'App.controller.Base'
    extend: 'Ext.app.Controller'

    viewForTab:( tabs, defaults )->
        return this.getRef( this.refs[0].ref, this.refs[0], defaults )

    createNewView: ->
        return this.getRef( this.refs[0].ref, this.refs[0], { forceCreate: true} )

    editRecord: Ext.emptyFn

    init: ->
        for name, obj of this.mixins
            if obj.initialize
                options = if this.mixinOptions then this.mixinOptions[ name ] || {} else {}
                obj.initialize(this, options )
        this.callParent()

    getMixinOption: (mixin,option)->
        if ( this.mixinOptions && this.mixinOptions[mixin] ) then return this.mixinOptions[mixin][option] else null

    getFR: (comp)->
        view = @root(comp)
        [ view, view.getForm().updateRecord().getRecord() ]

    getUpdatedRecord: (comp)->
        @root(comp).getForm().updateRecord().getRecord()

    root: (comp)->
        if comp.xtype == @refs[0].xtype then comp else comp.up( @refs[0].selector )

    grid: (comp)->
        comp.up( 'gridpanel' )

    openAndDisplay: ( args...)->
        view = this.getController('Tabs').display(this)
        this.setRecord( view, args... )

    setRecord: ( view, record )->
        this.disableIfPhantom( view, record )
        this.updateAuthorFields( view, record )
        this

    updateAuthorFields: (view,record)->
        return if record.phantom
        for field_name in ['updated_by','created_by']
            method = "get#{field_name.camelize()}"
            if record[method] && ( field = view.down("displayfield[name=#{field_name}]") )
                field.setValue( record[method]().get('username') )
        for field_name in ['created_at', 'updated_at' ]
            if ( field = view.down("displayfield[name=#{field_name}]") ) && ( date = record.get(field_name) )
                field.setValue( App.ux.Format.shortTime( date ) )


    disableIfPhantom: (view,rec)->
        for comp in view.query('[noPhantom=true]')
            comp.setDisabled( rec.phantom )
        this