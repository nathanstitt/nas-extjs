Ext.define 'App.ux.FindingField'
    alias: 'widget.finding_field'
    extend: 'Ext.form.field.Trigger',
    triggerCls: 'x-form-search-trigger'

    onTriggerClick: ()->
        this.fireEvent('searchclicked', this )

    setStore: (@store)->
        this

    initComponent: ->
        this.callParent()
        this.unfound_values = {}
        this.setRecord( @record ) if @record
        if this.allowAnyValues
            this.validator = this.allowAnyValidator
        this.setupSearchListers() unless this.finderSearchOnly

    findMatchingRecord: ( value )->
        return this.setRecord( null ) if ! value || ! @store

        if ( rec = @store.findRecord( @searchKey, value ) )
            this.setRecord( rec )
        else
            q={}
            q[ @searchKey ]=value
            @store.load({
                filterBy: q
                scope: this
                callback: (recs,op,success)->
                    this.setRecord( recs[0] )
                    @unfound_values[ value ] = ( 0 == recs.length )
                    this.validate()
            })

    setFromId: (id)->
        if ( id && @store && rec = @store.findRecord('id', id ) )
            return this.setRecord( rec )
        else
            return this.setRecord( null )

    setValue: (value)->
        this.callParent( arguments )
        if ! @suspendValueSet
            this.fireEvent('valueset', this, value  )

    setupSearchListers: ->
        this.on({
            scope:this
            specialkey:(fld,e,opts)->
                if e.getKey() == e.ENTER
                    this.findMatchingRecord( fld.getValue() )
            blur: (fld) ->
                if ( ( ! @record && fld.getValue() ) || ( ! @record || fld.getValue() != @record.get(@searchKey) ) )
                    this.findMatchingRecord( fld.getValue() )
        })

    getRecord: ->
        return @record

    getSelectedRecord: ->
        return @record

    setRecord: (@record)->
        @suspendValueSet=true
        if @record
            this.setValue( @record.get( @searchKey ) )
            this.fireEvent('recordset', this, @record  )
        else if ! @allowAnyValues
            this.setValue( '' )

        @suspendValueSet=false

    listeners:
        recordselected:(fld,rec,win)->
            this.setRecord( rec )
