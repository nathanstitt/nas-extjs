Ext.define('App.ux.CodeField', {
    alias: 'widget.code_field'
    extend: 'App.ux.FindingField'
    onlyValidRecords: true
    enableKeyEvents: true
    searchKey: 'code'
    allowBlank: false


    initComponent: ->
        this.callParent()
        if ! this.baseName && ( this.name && matches = this.name.match(/(.*)_\w+$/) )
            this.baseName = matches[1]

        if this.allowAnyValues
            this.validator = this.allowAnyValidator
        if this.allowAnyCharacters
            this.on({ change: Util.changeListenerUpCaseField } )
        else if ! this.allowLowerCase
            this.on({ change: Util.changeListenerCodeField } )

    validator: (value)->
        if @unfound_values[ value ]
            return "#{value} not found"
        else
            return true

    allowAnyValidator: ->
        return true
})
