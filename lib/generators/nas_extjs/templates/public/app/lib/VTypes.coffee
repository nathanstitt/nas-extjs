
Ext.define('App.lib.VTypes', {
    singleton:true

    register: ->
        for name, obj of this.types
            Ext.apply( Ext.form.field.VTypes, obj )

    types:[
        {
            Last4SSN:  (v)-> /^\d{4}$/.test(v)
            Last4SSNText: 'Last 4 of SSN Must be 4 digits'
            Last4SSNMask: /[\d\.]/i
        },{
            phone:     (v,field)-> /^(\d{3}[-]?){1,2}(\d{4})$/.test(v)
            phoneMask: /[\d-]/
            phoneText: 'Not a valid phone number.  Must be in the format 123-4567 or 123-456-7890 (dashes optional)'

        },{
            zip:     (v,field)->/^\d{5}(\-\d{4})?$/.test(v)
            zipMask: /[\d\-]/
            zipText: 'Must be in the format xxxxx or xxxxx-xxxx'

        },{
            visibleId:  (v) ->
                return /^\d+$/.test(v);
            visibleIdText: 'Must be a number',
            visibleIdMask: /[\d]/i
        }
    ]

})
