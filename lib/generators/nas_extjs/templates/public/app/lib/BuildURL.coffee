
Ext.define('App.lib.BuildURL', {
    singleton:true

    to_url_frag:( filter, name )->
        qs = ''
        for flk,flv of filter # FIXME - rewrite this to be recursive so it can handle arbitray depth
            if Ext.isObject(flv)
                for slk,slv of flv
                    if Ext.isObject(slv)
                        for tlk,tlv of slv
                            qs += "&#{name}[#{escape(flk)}][#{escape(slk)}][#{escape(tlk)}]=#{escape(tlv)}"
                    else
                        qs += "&#{name}[#{escape(flk)}][#{escape(slk)}]=#{escape(slv)}"
            else
                qs += "&#{name}[#{escape(flk)}]=#{escape(flv)}"
        qs


    register: ->
        u = Ext.data.proxy.Server.prototype.buildUrl
        Ext.data.proxy.Server.prototype.buildUrl = (req)->
            qs=u.apply(this,[req] )
            include = []
            opt_fields = []
            delete req.params.filter

            if queryScope = req.operation.queryScope || this.queryScope
                qs += App.lib.BuildURL.to_url_frag( queryScope, 'scope' )

            if this.filterBy
                qs += App.lib.BuildURL.to_url_frag( this.filterBy, 'query' )

            if req.operation.filterBy
                qs += App.lib.BuildURL.to_url_frag( req.operation.filterBy, 'query' )

            if req.operation.summaryFields
                qs += "&summaryFields[]=#{escape(field)}" for field in req.operation.summaryFields
            if this.summaryFields
                qs += "&summaryFields[]=#{escape(field)}" for field in this.summaryFields

            if req.operation.sorters && req.operation.sorters.length
                delete req.params['sort']
                sort = for sorter in req.operation.sorters
                    "sort[#{sorter.property}]=#{sorter.direction}"
                qs += '&' + sort.join('&')

            include = include.concat( req.operation.includeAssociations ) if req.operation.includeAssociations
            include = include.concat(  this.includeAssociations ) if this.includeAssociations

            opt_fields = opt_fields.concat( req.operation.includeOptionalFields ) if req.operation.includeOptionalFields
            opt_fields = opt_fields.concat(  this.includeOptionalFields ) if this.includeOptionalFields
            for field in opt_fields
                qs += "&optfields[]=#{field}"

            for val in include
                if Ext.isObject( val )
                    for key,subval of val
                        for incname in subval
                            qs += "&include[][#{key}][]=#{incname}"
                else
                    qs += "&include[]=#{val}"
            return qs

})
