Ext.ns('App.ux');


Ext.define('App.ux.NumericField', {
    extend:'Ext.form.field.Number'
    alias: 'widget.numericfield'

    currencySymbol        : null
    useThousandSeparator  : true
    alwaysDisplayDecimals : false
    thousandSeparator     : ','
    fieldBodyCls          : 'rightAlign'

    initComponent: ->
        this.callParent()
        if this.useThousandSeparator && this.decimalSeparator == ',' && ! config.thousandSeparator?
            this.thousandSeparator = '.'
        else if ( this.allowDecimals && this.thousandSeparator == '.' && Ext.isEmpty(config.decimalSeparator) )
                this.decimalSeparator = ','

#        this.onFocus = Ext.Function.createSequence(this.onFocus);

    setLocked:(v)->
        this.setReadOnly(v)



    setValue: (v)->
        this.callParent([ v ])
        this.setRawValue(this.getFormattedValue(this.getValue()));

    getFormattedValue:(v)->
        if Ext.isEmpty(v) || !this.hasFormat()
            return v
        else
            neg = null
            v = if (neg = v < 0) then v * -1 else v;
            v = this.allowDecimals and ( if this.alwaysDisplayDecimals then v.toFixed(this.decimalPrecision) else v )

            if this.useThousandSeparator
                if this.useThousandSeparator && Ext.isEmpty(this.thousandSeparator)
                    return 'NumberFormatException: invalid thousandSeparator, property must has a valid character.'

                if(this.thousandSeparator == this.decimalSeparator)
                    return 'NumberFormatException: invalid thousandSeparator, thousand separator must be different from decimalSeparator.'

                v = String(v);

                ps = v.split('.');
                ps[1] = if ps[1] then ps[1] else null;

                whole = ps[0];

                r = /(\d+)(\d{3})/;

                ts = this.thousandSeparator;

                while (r.test(whole))
                    whole = whole.replace(r, '$1' + ts + '$2');

                    v = whole + ( if ps[1] then this.decimalSeparator + ps[1] else '');

            return Ext.String.format('{0}{1}{2}', (if neg then '-' else ''), ( if Ext.isEmpty(this.currencySymbol) then '' else this.currencySymbol + ' '), v);

    parseValue: (v)->
        this.callParent( [ this.removeFormat(v) ] )

    removeFormat: (v)->
        if (Ext.isEmpty(v) || !this.hasFormat() || !Ext.isString(v) )
            return v
        else
            v = v.replace(this.currencySymbol + ' ', '')
            v = if this.useThousandSeparator then v.replace(new RegExp('[' + this.thousandSeparator + ']', 'g'), '') else v
            return v
    getErrors:(v)->
        this.callParent([ this.removeFormat(v) ] )

    hasFormat: ->
        this.decimalSeparator != '.' or this.useThousandSeparator == true or !Ext.isEmpty(this.currencySymbol) or this.alwaysDisplayDecimals

    onFocus: ->
        this.setRawValue( this.removeFormat(this.getRawValue()) )
})

#Ext.reg('numericfield', App.ux.NumericField )
