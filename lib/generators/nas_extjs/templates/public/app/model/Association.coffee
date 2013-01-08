Ext.define 'App.model.Association'

    statics:
        AUTO_ID: 1000



    constructor: (config) ->
        Ext.apply(this, config);

        me               = this
        types            = Ext.ModelManager.types
        ownerName        = config.ownerModel
        associatedName   = config.associatedModel
        ownerModel       = types[ownerName]
        associatedModel  = types[associatedName]
        me.initialConfig = config;


        if ! ownerModel?
            Ext.Error.raise("The configured ownerModel was not valid (you tried " + ownerName + ")");

        if ! associatedModel?
            Ext.Error.raise("The configured associatedModel was not valid (you tried " + associatedName + ")");


        this.ownerModel = ownerModel;

        this.associatedModel = associatedModel;

        Ext.applyIf(this, {
            ownerName : ownerName,
            associatedName: associatedName
        })

        me.associationId = 'association' + (++me.statics().AUTO_ID);

    getReader: ->
        me = this
        reader = me.reader
        model = me.associatedModel

        if reader
            if Ext.isString(reader)
                reader = {
                    type: reader
                }

            if reader.isReader
                reader.setModel(model)
            else
                Ext.applyIf(reader, {
                    model: model,
                    type : me.defaultReaderType
                })

            me.reader = Ext.createByAlias('reader.' + reader.type, reader);

        return me.reader || null;
