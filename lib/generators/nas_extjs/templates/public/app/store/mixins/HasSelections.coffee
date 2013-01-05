Ext.define 'App.store.mixins.HasSelections'

    _isSelected: (rec )->
        rec.get('is_selected') == true

    selectedRecords: ->
        @data.filterBy( this._isSelected )

    hasSelection: ->
        this.findRecord('is_selected', true )
