
Ext.define('App.lib.BuildURL', {
    singleton:true

    filter_to_url_frag:( filter )->
        qs = ''
        for k,v of filter
            if Ext.isObject(v)
                for query_key,query_val of v
                    qs += "&query[#{escape(k)}][#{escape(query_key)}]=#{escape(query_val)}"
            else
                qs += "&query[#{escape(k)}]=#{escape(v)}"
        qs


    register: ->
        u = Ext.data.proxy.Server.prototype.buildUrl
        Ext.data.proxy.Server.prototype.buildUrl = (req)->
            qs=u.apply(this,[req] )

            include = []
            opt_fields = []
            delete req.params.filter

            if queryScope = req.operation.queryScope || this.queryScope
                for name,data of queryScope
                    qs += "&scope[#{escape(name)}]=#{escape(data)}"

            if this.filterBy
                qs += App.lib.BuildURL.filter_to_url_frag( this.filterBy )

            if req.operation.filterBy
                qs += App.lib.BuildURL.filter_to_url_frag( req.operation.filterBy )

            if req.operation.summaryFields
                qs += "&summaryFields[]=#{escape(field)}" for field in req.operation.summaryFields
            if this.summaryFields
                qs += "&summaryFields[]=#{escape(field)}" for field in this.summaryFields

            if req.operation.sorters
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
