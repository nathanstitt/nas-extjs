
Ext.define('App.model.BelongsTo', {
    extend: 'App.model.Association'
    alias: 'association.belongsto'

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


        ownerProto[ "get#{me.accessorName}" ] = me.createGetter()
        ownerProto[ "set#{me.accessorName}" ] = me.createSetter()
        ownerProto[ "is#{me.accessorName}Loaded" ] = me.checkLoaded()
        this

    checkLoaded:->
        me = this
        return ->
            this[ me.instanceName ]?

    createGetter: ->
        me = this

        setFromStore = (model,fk)->
            name = Util.baseClassName( me.associatedModel.getName() ).pluralize()
            store = Application.getStore(name)
            if store
                rec = store.getById( parseInt(fk) )
                if rec
                    return model[me.instanceName] = rec
            return false


        return (options,scope) ->
            options = options || {};
            model = this
            foreignKeyId = model.get( me.foreignKey )

            if (typeof options == 'function')
                options = {
                    scope: scope||model
                    callback: options
                }

            if foreignKeyId && ! ( model[ me.instanceName ]? || model.data[ me.associationKey ]? ) && ! setFromStore(model,foreignKeyId)

                overridden_cb = options.success;

                options.success = ( rec, op )->
                    model[me.instanceName] = rec;
                    Ext.callback(overridden_cb, options.scope,[ rec, op ] );

                me.associatedModel.load(foreignKeyId, options);
            else

                if ! model[ me.instanceName ]?
                    model[ me.instanceName ] = new me.associatedModel( model.data[ me.associationKey ] )
                    delete model.data[ me.associationKey ]

                args = [ model[ me.instanceName ] ]

                Ext.callback(options, options.scope, args.concat( { success: true } ) )

                Ext.callback(options.success, options.scope, args)

                if ( ! foreignKeyId )
                    Ext.callback(options.failure, options.scope, args)

                Ext.callback(options.callback, options.scope, args)
            ret = model[ me.instanceName ]

            # if me.inverse_of
            #     me.inverse_of
            return ret;

    read: (record, reader, associationData)->
        record[this.instanceName] = reader.read([associationData]).records[0];

    createSetter: ->
        me = this

        return (value, options, scope) ->
            model = this;

            if ( method = model[ 'beforeSet' + me.accessorName ] ) && Ext.isFunction( method )
                method.apply( model, [ value, options, scope ] )

            if ( Ext.isObject( value ) )
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
                return model.save(options);

            if ( method = model[ 'afterSet' + me.accessorName ] ) && Ext.isFunction( method )
                method.apply( model, [ value, options, scope ] )


})
