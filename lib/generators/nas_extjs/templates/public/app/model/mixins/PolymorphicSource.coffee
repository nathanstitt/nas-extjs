Ext.define('App.model.mixins.PolymorphicSource', {

    setSource: ( @polymorphicSource )->
        this.set({
            source_id: @polymorphicSource.getId()
            source_type: Util.baseClassName( @polymorphicSource )
        })
        this

    getSource:->
        @polymorphicSource
})
