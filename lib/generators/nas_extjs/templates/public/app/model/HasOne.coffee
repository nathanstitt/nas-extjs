Ext.define "App.model.HasOne"
    extend: 'App.model.SingleAssociation'
    alias: "association.hasone"

    constructor: (config={}) ->
        Ext.applyIf(this, {
            foreignKey     : config.foreignKey || Util.baseClassName( config.ownerModel ).underscore() + '_id'
            associationKey : config.associatedName.toLowerCase()
            instanceName   : config.associatedName.camelize() + 'HasOneInstance'
        })
        this.callParent(arguments)

    loadModel: (foreignKeyId,options)->
        filter = {}
        filter[ this.foreignKey ] = foreignKeyId
        options.limit = 1
        this.store || = Ext.create( 'App.store.' + Ext.util.Inflector.pluralize( Util.baseClassName( this.model ) ) )
        this.store.setFilter(filter)
        this.store.load(options)

    createGetter: ->
        me = this

        return (options,scope) ->
            options = options || {};
            model = this

            pkId = model.getId()

            if (typeof options == 'function')
                options = {
                    scope: scope||model
                    callback: options
                }

            if pkId && ! ( model[ me.instanceName ]? || model.data[ me.associationKey ]? ) && ! me.setFromStore(model,pkId)

                overridden_cb = options.callback;

                options.callback = ( recs, op )->
                    rec=recs[0]
                    rec[ model.inverseAssociationName ] = model if model.inverseAssociationName?
                    model[me.instanceName] = rec;
                    Ext.callback(overridden_cb, options.scope,[ rec, op ] );

                me.loadModel( pkId, options )

            else

                if ! model[ me.instanceName ]?
                    model[ me.instanceName ] = rec = new me.associatedModel( model.data[ me.associationKey ] )
                    rec[ me.inverseAssociationName ] = model if me.inverseAssociationName?
                    delete model.data[ me.associationKey ]

                record = model[ me.instanceName ]
                if pkId && ! record.getId()
                    record.setId( pkId )

                args = [ record ]
                Ext.callback(options, options.scope, args.concat( { success: true } ) )
                Ext.callback(options.success, options.scope, args)
                if ( ! pkId )
                    Ext.callback(options.failure, options.scope, args)

                Ext.callback(options.callback, options.scope, args)
            ret = model[ me.instanceName ]
            return ret

    read: (record, reader, associationData)->
        if ( data = reader.read([associationData]).records[0] )
            data[ record.inverseAssociationName ] = record if record.inverseAssociationName?
            record[this.instanceName] = data

    createSetter: ->
        me = this
        return (value, options, scope) ->
            model = this;
            if ( method = model[ 'beforeSet' + me.accessorName ] ) && Ext.isFunction( method )
                method.apply( model, [ value, options, scope ] )

            if ( Ext.isObject( value ) )
                value[ me.inverseAssociationName ] = me if me.inverseAssociationName?
                model[me.instanceName] = value;
                model.set( me.foreignKey, value.getId() );
                if me.delegate
                    for field in me.delegate
                        model.set( "#{me.name}_#{field}", value.get( field ) )
            else
                model.set( me.foreignKey, value);
                model[ me.instanceName ] = null;


            if (typeof options == 'function')
                options = {
                    callback: options,
                    scope: scope || model
                };

            if (Ext.isObject(options))
                model.save(options);

            if ( method = model[ 'afterSet' + me.accessorName ] ) && Ext.isFunction( method )
                method.apply( model, [ value, options, scope ] )

            return value


    # createSetter: ->
    #     me = this
    #     foreignKey = me.foreignKey
    #     instanceName = me.instanceName

    #     #'this' refers to the Model instance inside this function
    #     (value, options, scope) ->

    #         # If we were passed a record, the value to set is the key of that record.
    #         setByRecord = value and value.isModel
    #         valueToSet = (if setByRecord then value.getId() else value)

    #         # Setter was passed a record.
    #         if setByRecord
    #             this[instanceName] = value

    #         # Otherwise, if the key of foreign record !== passed value, delete the cached foreign record
    #         else delete this[instanceName]    if this[instanceName] instanceof Ext.data.Model and not @isEqual(@get(foreignKey), valueToSet)

    #         # Set the forign key value
    #         @set foreignKey, valueToSet
    #         if Ext.isFunction(options)
    #             options =
    #                 callback: options
    #                 scope: scope or this
    #         @save options    if Ext.isObject(options)


    # createGetter: ->
    #     me = this
    #     ownerModel = me.ownerModel
    #     associatedName = me.associatedName
    #     associatedModel = me.associatedModel
    #     foreignKey = me.foreignKey
    #     primaryKey = me.primaryKey
    #     instanceName = me.instanceName

    #     #'this' refers to the Model instance inside this function
    #     return (options, scope) ->
    #         debugger
    #         options = options or {}
    #         model = this
    #         foreignKeyId = model.get(foreignKey)
    #         success = undefined
    #         instance = undefined
    #         args = undefined
    #         if options.reload is true or model[instanceName] is `undefined`
    #             instance = Ext.ModelManager.create({}, associatedName)
    #             instance.set primaryKey, foreignKeyId
    #             if typeof options is "function"
    #                 options =
    #                     callback: options
    #                     scope: scope or model

    #             # Overwrite the success handler so we can assign the current instance
    #             success = options.success
    #             options.success = (rec) ->
    #                 model[instanceName] = rec
    #                 success.apply this, arguments    if success

    #             associatedModel.load foreignKeyId, options

    #             # assign temporarily while we wait for data to return
    #             model[instanceName] = instance
    #             instance
    #         else
    #             instance = model[instanceName]
    #             args = [instance]
    #             scope = scope or options.scope or model

    #             #TODO: We're duplicating the callback invokation code that the instance.load() call above
    #             #makes here - ought to be able to normalize this - perhaps by caching at the Model.load layer
    #             #instead of the association layer.
    #             Ext.callback options, scope, args
    #             Ext.callback options.success, scope, args
    #             Ext.callback options.failure, scope, args
    #             Ext.callback options.callback, scope, args
    #             instance


    # read: (record, reader, associationData) ->
    #     inverse = @associatedModel::associations.findBy((assoc) ->
    #         assoc.type is "belongsTo" and assoc.associatedName is record.$className
    #     )
    #     newRecord = reader.read([associationData]).records[0]
    #     record[@instanceName] = newRecord

    #     #if the inverse association was found, set it now on each record we've just created
    #     newRecord[inverse.instanceName] = record    if inverse
