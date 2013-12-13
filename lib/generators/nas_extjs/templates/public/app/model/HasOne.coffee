Ext.define( "App.model.HasOne", {
    extend: 'App.model.SingleAssociation'
    alias: "association.hasone"

    constructor: (config={}) ->
        Ext.applyIf(this, {
            foreignKey     : config.foreignKey || Util.baseClassName( config.ownerModel ).underscore() + '_id'
            associationKey : config.associatedName.toLowerCase()
            instanceName   : App.Util.camelize( config.associatedName ) + 'HasOneInstance'
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



})
