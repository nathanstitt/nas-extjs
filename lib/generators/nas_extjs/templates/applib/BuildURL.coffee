
Ext.define('App.lib.BuildURL', {
    singleton:true

    register: ->
        u = Ext.data.proxy.Server.prototype.buildUrl
        Ext.data.proxy.Server.prototype.buildUrl = (req)->
            qs=u.apply(this,[req] )
            include = []
            opt_fields = []
            delete req.params.filter
            if this.filterBy
                for k,v of this.filterBy
                    qs += "&filter[#{escape(k)}]=#{escape(v)}"
            if queryScope = req.operation.queryScope || this.queryScope
                for name,data of queryScope
                    qs += "&queryScope[#{escape(name)}]=#{escape(data)}"
            if req.operation.filterBy
                for k,v of req.operation.filterBy
                    qs += "&filter[#{escape(k)}]=#{escape(v)}"
            if req.operation.query
                for k,v of req.operation.query
                    qs += "&query[#{escape(k)}]=#{escape(v)}"

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
