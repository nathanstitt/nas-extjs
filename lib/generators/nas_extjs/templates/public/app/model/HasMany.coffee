
Ext.define 'App.model.HasMany'

    extend   : 'App.model.Association'
    alias    : 'association.hasmany'
    requires : [
        'Ext.util.Inflector'
    ]

    constructor: (config) ->
        me = this

        unless config.model?
            config.model = 'App.model.' +
                Ext.string.capitialize( Ext.util.Inflector.singularize( config.associatedName ) )

        me.callParent(arguments);

        me.name = me.name || Ext.util.Inflector.pluralize(me.associatedName.toLowerCase());

        ownerProto = me.ownerModel.prototype;
        name = me.name;

        Ext.applyIf(me, {
            storeName : name + "Store",
            foreignKey: Util.baseClassName( me.ownerName ).underscore() + "_id"
            primaryKey: 'id'
        });

        ownerProto[name] = me.createStore();
        this

    createStore: ->
        that            = this
        associatedModel = that.associatedModel
        storeClass      = that.storeClass ||
           'App.store.' +   Ext.util.Inflector.pluralize( Util.baseClassName( that.model ) )

        storeName       = that.storeName
        foreignKey      = that.foreignKey
        primaryKey      = that.primaryKey
        filterProperty  = that.filterProperty
        autoLoad        = that.autoLoad
        storeConfig     = that.storeConfig || {}

        return ->
            me = this
            modelDefaults = {}

            if ! me[storeName]?

                modelDefaults[foreignKey] = me.get(primaryKey);
                config = Ext.apply({}, storeConfig, {
                    model        : associatedModel,
                    remoteFilter : true,
                    modelDefaults: modelDefaults
                    owningRecord : me
                });

                if that.setFilter && Ext.isFunction( that.setFilter )
                    Ext.apply( config, that.setFilter.apply( this, [that] ) )
                else
                    fb = {}
                    fb[ foreignKey ] = me.get(primaryKey)
                    config['filterBy'] = fb

                me[storeName] = Ext.create( storeClass, config);

                if (autoLoad)
                    me[storeName].load();

            return me[storeName]

    read: (record, reader, associationData)->
        store = record[this.name]()

        store.add(reader.read(associationData).records)

        # now that we've added the related records to the hasMany association, set the inverse belongsTo
        # association on each of them if it exists
        if this.inverse_of

            inverse = this.associatedModel.prototype.associations.findBy(  (assoc)->
                return assoc.type == 'belongsTo' && assoc.associatedName == this.inverse_of
            ,this )

            if inverse
                store.data.each( (associatedRecord)->
                    associatedRecord[ inverse.instanceName ] = record;
                )
