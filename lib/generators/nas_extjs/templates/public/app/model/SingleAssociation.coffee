Ext.define('App.model.SingleAssociation', {
    extend: 'App.model.Association'

    constructor: (config) ->
        associatedName = config.associatedName

        Ext.applyIf( config, {
            model: 'App.model.' + App.Util.camelize( associatedName )
        } )

        this.callParent(arguments)
        me             = this
        ownerProto     = me.ownerModel.prototype
        Ext.applyIf(me, {
            name           : associatedName,
            accessorName   : App.Util.camelize( associatedName ),
            foreignKey     : associatedName.toLowerCase() + "_id",
            instanceName   : App.Util.camelize( associatedName ) + 'BelongsToInstance',
            associationKey : associatedName.toLowerCase()
        })

        methods   = {}
        this.getterName ||= me.getterName || "get#{me.accessorName}"
        methods[ this.getterName ] = me.createGetter()
        methods[ me.setterName || "set#{me.accessorName}" ] = me.createSetter()
        methods[ me.loadedName || "is#{me.accessorName}Loaded" ] = me.checkLoaded()
        Ext.apply( ownerProto, methods )

        this

    isLoaded: (model)->
        model[this.instanceName]?

    setFromStore: (model,fk)->
        name = Util.baseClassName( this.associatedModel.getName() ).pluralize()
        store = Application.getStore(name)
        if store
            rec = store.getById( parseInt(fk) )
            if rec
                rec[ model.inverseAssociationName ] = model if model.inverseAssociationName?
                return model[this.instanceName] = rec
        return false

    checkLoaded:->
        me = this
        return ->
            this[ me.instanceName ]?



})