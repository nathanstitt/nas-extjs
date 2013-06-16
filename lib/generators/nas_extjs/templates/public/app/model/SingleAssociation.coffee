Ext.define('App.model.SingleAssociation', {
    extend: 'App.model.Association'

    constructor: (config) ->
        associatedName = config.associatedName

        Ext.applyIf( config, {
            model: 'App.model.' + associatedName.camelize()
        } )

        this.callParent(arguments)
        me             = this
        ownerProto     = me.ownerModel.prototype
        Ext.applyIf(me, {
            name           : associatedName,
            accessorName   : associatedName.camelize(),
            foreignKey     : associatedName.toLowerCase() + "_id",
            instanceName   : associatedName.camelize() + 'BelongsToInstance',
            associationKey : associatedName.toLowerCase()
        })

        methods   = {}
        methods[ me.getterName || "get#{me.accessorName}" ] = me.createGetter()
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