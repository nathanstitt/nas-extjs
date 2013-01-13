# Utils for ExtJS

proxy_eh = (proxy, request, operation) ->
    title = 'Error id: ' + request.status
    if request.responseText
        responseObj = Ext.decode(request.responseText,true);
        if responseObj and responseObj.message?
            Ext.Msg.alert( title,responseObj.message);
        else
            Ext.Msg.alert( title, 'Unknown error: Operation did not succeed');
    else
        Ext.Msg.alert( title, 'Unknown response code: Unable to understand the response from the server');

proxy_sorters = ( sorters )->
    str = for sorter in sorters
        "[#{sorter.property}]=#{sorter.direction}"
    str.join('&')

window.Util =
    underscore: (str)->
            str.replace(/::/g, '/')
               .replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2')
               .replace(/([a-z\d])([A-Z])/g, '$1_$2')
               .replace(/-/g, '_')
               .toLowerCase()

    humanize: (str)->
            str.replace(/::/g, '/')
               .replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2')
               .replace(/([a-z\d])([A-Z])/g, '$1_$2')
               .replace(/-/g, '_')
               .toLowerCase()

    baseClassName: ( name ) ->
        if Ext.isObject( name )
            name = Ext.getClassName( name )
        els = name.split('.')
        els[ els.length - 1 ]

    makeProxy: (name,options={})->
        return {
            api_key: name
            type: 'rest',
            url : '/api/' + name
            setAssociations: options['setAssociations'] || []
            encodeSorters: proxy_sorters
            includeOptionalFields: options['includeOptionalFields'] || []
            setFilter: options['setFilter']
            reader:
                type: 'json'
                root: 'data'
            listeners: { exception: proxy_eh }
            writer:
                type: 'json'
                root: 'data'
                writeAllFields: false
                getRecordData: (record) ->
                    for name,data of record.getAssociatedData()
                        delete data.id unless data.id?
                        record.data[ Util.underscore( name) + '_attributes' ] = data
                        delete record.data[ name ]
                    return record.data;
        }

    normalizeCode:(code)->
            code.toUpperCase().replace(/[^a-zA-Z0-9]+/g,'')

    getStore: (name)->
        Ext.data.StoreManager.lookup( name ) || Ext.create( "App.store.#{name}", { storeId: name } )

    relayEventsToGrid: (names...)->
        events={}
        for name in names
            events[ name ] = (field)->
                if ( form = field.up('form') ) && ( editor = form.editingPlugin ) && editor.grid
                    editor.grid.fireEvent( 'edit_' + field.name + '_' + name, field, {
                        arguments: Array.prototype.slice.call(arguments,1)
                        record: editor.getEditor().getRecord()
                        form: form.getForm()
                        editor: editor
                        grid: editor.grid
                    })
        events

    changeListenerUpCaseField : (f,nv,ov,opts)->
        f.setValue( nv.toUpperCase() ) if nv

    changeListenerCodeField : (f,nv,ov,opts)->
        f.setValue( App.Util.normalizeCode( nv ) ) if nv

    extractOptions: ( args )->
        if Ext.isObject( args[ args.length-1 ] )
            return [ args[ 0 .. args.length ],  args[ args.length-1 ] ]
        else
            return [ args, {} ]

    reloadView:(name)->
        return if ! window.Application || Util.is_reloading
        Application.reloadView( name ) if Application.reloadView

    reloadController: (controller_name)->
        return if ! window.Application || Util.is_reloading
        console.clear()
        old = Application.controllers.get( controller_name )
        if old
            for name, scope of Application.eventbus.bus
                for cl, evs of scope
                    for tree, ary of evs
                        old_evs = []
                        for i in [0...ary.length]
                            event = ary[i]
                            old_evs.push( i ) if event.observable.id == old.id
                        for indx in old_evs
                            ary.splice(indx,1)
            Application.controllers.remove( old )
        Application.getController( controller_name );


assoc = (association)->
    if (association.isAssociation)
        return association

    if (Ext.isString(association))
        association = { type: association }

    switch (association.type)
        when 'belongsTo' then return Ext.create('App.model.BelongsTo', association)
        when 'hasMany' then return Ext.create('App.model.HasMany', association)
        else
            #<debug>
            Ext.Error.raise('Unknown Association type: "' + association.type + '"');
            #</debug>
    return association

if Ext.ClassManager.isCreated( 'Ext.data.Association' )
    Ext.data.Association.create = assoc
else
    Ext.require(['Ext.data.Association'], ->
        Ext.data.Association.create = assoc
    )


Ext.define( 'App.Util', { statics: window.Util } )
