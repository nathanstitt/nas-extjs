Ext.define( "App.ux.BoxSelect", {
    extend: "Ext.form.field.ComboBox"
    alias: ["widget.comboboxselect", "widget.boxselect"]
    requires: ["Ext.selection.Model", "Ext.data.Store", "App.ux.BoxSelectField"]
    multiSelect: true
    forceSelection: true
    createNewOnEnter: false
    createNewOnBlur: false
    encodeSubmitValue: false
    triggerOnClick: true
    stacked: false
    pinList: true
    filterPickList: false
    selectOnFocus: true
    grow: true
    growMin: false
    growMax: false
    fieldSubTpl: ["<div id=\"{cmpId}-listWrapper\" class=\"x-boxselect {fieldCls} {typeCls}\">", "<ul id=\"{cmpId}-itemList\" class=\"x-boxselect-list\">", "<li id=\"{cmpId}-inputElCt\" class=\"x-boxselect-input\">", "<input id=\"{cmpId}-inputEl\" type=\"{type}\" ", "<tpl if=\"name\">name=\"{name}\" </tpl>", "<tpl if=\"value\"> value=\"{[Ext.util.Format.htmlEncode(values.value)]}\"</tpl>", "<tpl if=\"size\">size=\"{size}\" </tpl>", "<tpl if=\"tabIdx\">tabIndex=\"{tabIdx}\" </tpl>", "<tpl if=\"disabled\"> disabled=\"disabled\"</tpl>", "class=\"x-boxselect-input-field {inputElCls}\" autocomplete=\"off\">", "</li>", "</ul>", "</div>",
        compiled: true
        disableFormats: true
    ]
    childEls: ["listWrapper", "itemList", "inputEl", "inputElCt"]
    componentLayout: "boxselectfield"
    initComponent: ->
        me = this
        typeAhead = me.typeAhead
        Ext.Error.raise "If typeAhead is enabled the combo must be editable: true -- please change one of those settings."    if typeAhead and not me.editable
        Ext.apply me,
            typeAhead: false

        me.callParent()
        me.typeAhead = typeAhead
        me.selectionModel = new Ext.selection.Model(
            store: me.valueStore
            mode: "MULTI"
            lastFocused: null
            onSelectChange: (record, isSelected, suppressEvent, commitFn) ->
                commitFn()
        )
        me.delimiterRegexp = new RegExp(String(me.delimiter).replace(/[$%()*+.?\[\\\]{|}]/g, "\\$&"))    if not Ext.isEmpty(me.delimiter) and me.multiSelect

    initEvents: ->
        me = this
        me.callParent arguments
        me.mon me.inputEl, "keydown", me.onKeyDown, me    unless me.enableKeyEvents
        me.mon me.inputEl, "paste", me.onPaste, me
        me.mon me.listWrapper, "click", me.onItemListClick, me
        me.mon me.selectionModel,
            selectionchange: (selModel, selectedRecs) ->
                me.applyMultiselectItemMarkup()
                me.fireEvent "valueselectionchange", me, selectedRecs

            focuschange: (selectionModel, oldFocused, newFocused) ->
                me.fireEvent "valuefocuschange", me, oldFocused, newFocused

            scope: me

    onBindStore: (store, initial) ->
        me = this
        if store
            me.valueStore = new Ext.data.Store(
                model: store.model
                proxy:
                    type: "memory"
            )
            me.mon me.valueStore, "datachanged", me.applyMultiselectItemMarkup, me
            me.selectionModel.bindStore me.valueStore    if me.selectionModel

    onUnbindStore: (store) ->
        me = this
        valueStore = me.valueStore
        if valueStore
            if me.selectionModel
                me.selectionModel.setLastFocused null
                me.selectionModel.deselectAll()
                me.selectionModel.bindStore null
            me.mun valueStore, "datachanged", me.applyMultiselectItemMarkup, me
            valueStore.destroy()
            me.valueStore = null
        me.callParent arguments

    createPicker: ->
        me = this
        picker = me.callParent(arguments)
        me.mon picker,
            beforerefresh: me.onBeforeListRefresh
            scope: me

        picker.addCls "x-boxselect-hideselections"    if me.filterPickList
        picker

    onDestroy: ->
        me = this
        Ext.destroyMembers me, "selectionModel", "valueStore"
        me.callParent arguments

    getSubTplData: ->
        me = this
        data = me.callParent()
        isEmpty = me.emptyText and data.value.length < 1
        if isEmpty
            data.value = me.emptyText
        else
            data.value = ""
        data.inputElCls = (if data.fieldCls.match(me.emptyCls) then me.emptyCls else "")
        data

    afterRender: ->
        me = this
        delete me.inputEl.dom.placeholder    if Ext.supports.Placeholder and me.inputEl and me.emptyText
        me.bodyEl.applyStyles "vertical-align:top"
        if me.grow
            me.listWrapper.applyStyles "min-height:" + me.growMin + "px"    if Ext.isNumber(me.growMin) and (me.growMin > 0)
            me.listWrapper.applyStyles "max-height:" + me.growMax + "px"    if Ext.isNumber(me.growMax) and (me.growMax > 0)
        me.itemList.addCls "x-boxselect-stacked"    if me.stacked is true
        me.itemList.addCls "x-boxselect-singleselect"    unless me.multiSelect
        me.applyMultiselectItemMarkup()
        me.callParent arguments

    findRecord: (field, value) ->
        ds = @store
        matches = undefined
        return false    unless ds
        matches = ds.queryBy((rec, id) ->
            rec.isEqual rec.get(field), value
        )
        (if (matches.getCount() > 0) then matches.first() else false)

    onLoad: ->
        me = this
        valueField = me.valueField
        valueStore = me.valueStore
        changed = false
        if valueStore
            me.setValue me.value, false, true    if not Ext.isEmpty(me.value) and (valueStore.getCount() is 0)
            valueStore.suspendEvents()
            valueStore.each (rec) ->
                r = me.findRecord(valueField, rec.get(valueField))
                i = (if r then valueStore.indexOf(rec) else -1)
                if i >= 0
                    valueStore.removeAt i
                    valueStore.insert i, r
                    changed = true

            valueStore.resumeEvents()
            valueStore.fireEvent "datachanged", valueStore    if changed
        me.callParent arguments

    isFilteredRecord: (record) ->
        me = this
        store = me.store
        valueField = me.valueField
        storeRecord = undefined
        filtered = false
        storeRecord = store.findExact(valueField, record.get(valueField))
        filtered = (storeRecord is -1) and (not store.snapshot or (me.findRecord(valueField, record.get(valueField)) isnt false))
        filtered = filtered or (not filtered and (storeRecord is -1) and (me.forceSelection isnt true) and (me.valueStore.findExact(valueField, record.get(valueField)) >= 0))
        filtered

    doRawQuery: ->
        me = this
        rawValue = me.inputEl.dom.value
        rawValue = rawValue.split(me.delimiter).pop()    if me.multiSelect
        @doQuery rawValue, false, true
        ov = me.selectOnFocus
        me.selectOnFocus = false
        me.inputEl.focus()
        me.selectOnFocus = ov

    onBeforeListRefresh: ->
        @ignoreSelection++

    onListRefresh: ->
        @callParent arguments
        --@ignoreSelection    if @ignoreSelection > 0

    selectHighlighted: ->

    onListSelectionChange: (list, selectedRecords) ->
        me = this
        valueStore = me.valueStore
        mergedRecords = []
        i = undefined
        if (me.ignoreSelection <= 0) and me.isExpanded
            valueStore.each (rec) ->
                mergedRecords.push rec    if Ext.Array.contains(selectedRecords, rec) or me.isFilteredRecord(rec)

            mergedRecords = Ext.Array.merge(mergedRecords, selectedRecords)
            i = Ext.Array.intersect(mergedRecords, valueStore.getRange()).length
            if (i isnt mergedRecords.length) or (i isnt me.valueStore.getCount())
                me.setValue mergedRecords, false
                Ext.defer me.collapse, 1, me    if not me.multiSelect or not me.pinList
                me.fireEvent "select", me, valueStore.getRange()    if valueStore.getCount() > 0
            me.inputEl.focus()
            me.inputEl.dom.value = ""    unless me.pinList
            me.inputEl.dom.select()    if me.selectOnFocus

    syncSelection: ->
        me = this
        picker = me.picker
        valueField = me.valueField
        pickStore = undefined
        selection = undefined
        selModel = undefined
        if picker
            pickStore = picker.store
            selection = []
            if me.valueStore
                me.valueStore.each (rec) ->
                    i = pickStore.findExact(valueField, rec.get(valueField))
                    selection.push pickStore.getAt(i)    if i >= 0
            me.ignoreSelection++
            selModel = picker.getSelectionModel()
            selModel.deselectAll()
            selModel.select selection    if selection.length > 0
            --me.ignoreSelection    if me.ignoreSelection > 0

    doAlign: ->
        me = this
        picker = me.picker
        aboveSfx = "-above"
        isAbove = undefined
        me.picker.alignTo me.listWrapper, me.pickerAlign, me.pickerOffset
        isAbove = picker.el.getY() < me.inputEl.getY()
        me.bodyEl[(if isAbove then "addCls" else "removeCls")] me.openCls + aboveSfx
        picker[(if isAbove then "addCls" else "removeCls")] picker.baseCls + aboveSfx

    alignPicker: ->
        me = this
        picker = me.picker
        pickerScrollPos = picker.getTargetEl().dom.scrollTop
        me.callParent arguments
        if me.isExpanded
            picker.setWidth me.listWrapper.getWidth()    if me.matchFieldWidth
            picker.getTargetEl().dom.scrollTop = pickerScrollPos

    getCursorPosition: ->
        cursorPos = undefined
        if Ext.isIE
            cursorPos = document.selection.createRange()
            cursorPos.collapse true
            cursorPos.moveStart "character", -@inputEl.dom.value.length
            cursorPos = cursorPos.text.length
        else
            cursorPos = @inputEl.dom.selectionStart
        cursorPos

    hasSelectedText: ->
        sel = undefined
        range = undefined
        if Ext.isIE
            sel = document.selection
            range = sel.createRange()
            range.parentElement() is @inputEl.dom
        else
            @inputEl.dom.selectionStart isnt @inputEl.dom.selectionEnd

    onKeyDown: (e, t) ->
        me = this
        key = e.getKey()
        rawValue = me.inputEl.dom.value
        valueStore = me.valueStore
        selModel = me.selectionModel
        stopEvent = false
        return    if me.readOnly or me.disabled or not me.editable
        if me.isExpanded and (key is e.A and e.ctrlKey)
            me.select me.getStore().getRange()
            selModel.setLastFocused null
            selModel.deselectAll()
            me.collapse()
            me.inputEl.focus()
            stopEvent = true
        else if (valueStore.getCount() > 0) and (rawValue is "") or (me.getCursorPosition() is 0) and not me.hasSelectedText()
            lastSelectionIndex = (if (selModel.getCount() > 0) then valueStore.indexOf(selModel.getLastSelected() or selModel.getLastFocused()) else -1)
            if (key is e.BACKSPACE) or (key is e.DELETE)
                if lastSelectionIndex > -1
                    lastSelectionIndex = -1    if selModel.getCount() > 1
                    me.valueStore.remove selModel.getSelection()
                else
                    me.valueStore.remove me.valueStore.last()
                selModel.clearSelections()
                me.setValue me.valueStore.getRange()
                selModel.select lastSelectionIndex - 1    if lastSelectionIndex > 0
                stopEvent = true
            else if (key is e.RIGHT) or (key is e.LEFT)
                if (lastSelectionIndex is -1) and (key is e.LEFT)
                    selModel.select valueStore.last()
                    stopEvent = true
                else if lastSelectionIndex > -1
                    if key is e.RIGHT
                        if lastSelectionIndex < (valueStore.getCount() - 1)
                            selModel.select lastSelectionIndex + 1, e.shiftKey
                            stopEvent = true
                        else unless e.shiftKey
                            selModel.setLastFocused null
                            selModel.deselectAll()
                            stopEvent = true
                    else if (key is e.LEFT) and (lastSelectionIndex > 0)
                        selModel.select lastSelectionIndex - 1, e.shiftKey
                        stopEvent = true
            else if key is e.A and e.ctrlKey
                selModel.selectAll()
                stopEvent = e.A
            me.inputEl.focus()
        if stopEvent
            me.preventKeyUpEvent = stopEvent
            e.stopEvent()
            return
        me.callParent arguments    if me.enableKeyEvents
        if not e.isSpecialKey() and not e.hasModifier()
            me.selectionModel.setLastFocused null
            me.selectionModel.deselectAll()
            me.inputEl.focus()
            true


    onKeyUp: (e, t) ->
        me = this
        rawValue = me.inputEl.dom.value
        if me.preventKeyUpEvent
            e.stopEvent()
            delete me.preventKeyUpEvent    if (me.preventKeyUpEvent is true) or (e.getKey() is me.preventKeyUpEvent)
            return
        if me.multiSelect and (me.delimiterRegexp and me.delimiterRegexp.test(rawValue)) or ((me.createNewOnEnter is true) and e.getKey() is e.ENTER)
            rawValue = Ext.Array.clean(rawValue.split(me.delimiterRegexp))
            me.inputEl.dom.value = ""
            me.setValue me.valueStore.getRange().concat(rawValue)
            me.inputEl.focus()
        me.callParent [e, t]

    onPaste: (e, t) ->
        me = this
        rawValue = me.inputEl.dom.value
        clipboard = (if (e and e.browserEvent and e.browserEvent.clipboardData) then e.browserEvent.clipboardData else false)
        if me.multiSelect and (me.delimiterRegexp and me.delimiterRegexp.test(rawValue))
            if clipboard and clipboard.getData
                if /text\/plain/.test(clipboard.types)
                    rawValue = clipboard.getData("text/plain")
                else rawValue = clipboard.getData("text/html")    if /text\/html/.test(clipboard.types)
            rawValue = Ext.Array.clean(rawValue.split(me.delimiterRegexp))
            me.inputEl.dom.value = ""
            me.setValue me.valueStore.getRange().concat(rawValue)
            me.inputEl.focus()

    onExpand: ->
        # Returning immediately here
        # ComboBox sets up an enter key handler that
        # mucks up everything - making it impossible to handle ourselves
        return
        # me = this
        # keyNav = me.listKeyNav
        # me.callParent arguments
        # return    if keyNav or not me.filterPickList
        # keyNav = me.listKeyNav
        # keyNav.highlightAt = (index) ->
        #     boundList = @boundList
        #     item = boundList.all.item(index)
        #     len = boundList.all.getCount()
        #     direction = undefined
        #     if item and item.hasCls("x-boundlist-selected")
        #         if (index is 0) or not boundList.highlightedItem or (boundList.indexOf(boundList.highlightedItem) < index)
        #             direction = 1
        #         else
        #             direction = -1
        #         loop
        #             index = index + direction
        #             item = boundList.all.item(index)
        #             break unless (index > 0) and (index < len) and item.hasCls("x-boundlist-selected")
        #         return    if item.hasCls("x-boundlist-selected")
        #     if item
        #         item = item.dom
        #         boundList.highlightItem item
        #         boundList.getTargetEl().scrollChildIntoView item, false

    onTypeAhead: ->
        me = this
        displayField = me.displayField
        inputElDom = me.inputEl.dom
        valueStore = me.valueStore
        boundList = me.getPicker()
        record = undefined
        newValue = undefined
        len = undefined
        selStart = undefined
        if me.filterPickList
            fn = @createFilterFn(displayField, inputElDom.value)
            record = me.store.findBy((rec) ->
                (valueStore.indexOfId(rec.getId()) is -1) and fn(rec)
            )
            record = (if (record is -1) then false else me.store.getAt(record))
        else
            record = me.store.findRecord(displayField, inputElDom.value)
        if record
            newValue = record.get(displayField)
            len = newValue.length
            selStart = inputElDom.value.length
            boundList.highlightItem boundList.getNode(record)
            if selStart isnt 0 and selStart isnt len
                inputElDom.value = newValue
                me.selectText selStart, newValue.length

    onItemListClick: (evt, el, o) ->
        me = this
        itemEl = evt.getTarget(".x-boxselect-item")
        closeEl = (if itemEl then evt.getTarget(".x-boxselect-item-close") else false)
        return    if me.readOnly or me.disabled
        evt.stopPropagation()
        if itemEl
            if closeEl
                me.removeByListItemNode itemEl
                me.fireEvent "select", me, me.valueStore.getRange()    if me.valueStore.getCount() > 0
            else
                me.toggleSelectionByListItemNode itemEl, evt.shiftKey
            me.inputEl.focus()
        else
            if me.selectionModel.getCount() > 0
                me.selectionModel.setLastFocused null
                me.selectionModel.deselectAll()
            me.onTriggerClick()    if me.triggerOnClick

    getMultiSelectItemMarkup: ->
        me = this
        unless me.multiSelectItemTpl
            unless me.labelTpl
                me.labelTpl = Ext.create("Ext.XTemplate", "{[values." + me.displayField + "]}")
            else me.labelTpl = Ext.create("Ext.XTemplate", me.labelTpl)    if Ext.isString(me.labelTpl) or Ext.isArray(me.labelTpl)
            me.multiSelectItemTpl = [
                "<tpl for=\".\">",
                "<li class=\"x-boxselect-item "
                "<tpl if=\"this.isSelected(values." + me.valueField + ")\">"
                " selected", "</tpl>",
                "\" qtip=\"{[typeof values === \"string\" ? values : values." + me.displayField + "]}\">"
                "<div class=\"x-boxselect-item-text\">{[typeof values === \"string\" ? values : this.getItemLabel(values)]}</div>"
                "<a class=\"x-tab-close-btn x-tab-default x-boxselect-item-close\"></a>"
                "</li>", "</tpl>",
                {
                    compile: true
                    disableFormats: true
                    isSelected: (value) ->
                        i = me.valueStore.findExact(me.valueField, value)
                        return me.selectionModel.isSelected(me.valueStore.getAt(i))    if i >= 0
                        false
                    getItemLabel: (values) ->
                        me.getTpl("labelTpl").apply values
                }
            ]
        @getTpl("multiSelectItemTpl").apply Ext.Array.pluck(@valueStore.getRange(), "data")

    applyMultiselectItemMarkup: ->
        me = this
        itemList = me.itemList
        item = undefined
        if itemList
            item.remove()    while (item = me.inputElCt.prev())?
            me.inputElCt.insertHtml "beforeBegin", me.getMultiSelectItemMarkup()
        Ext.Function.defer (->
            me.alignPicker()    if me.picker and me.isExpanded
            me.inputElCt.scrollIntoView me.listWrapper    if me.hasFocus
        ), 15

    getRecordByListItemNode: (itemEl) ->
        me = this
        itemIdx = 0
        searchEl = me.itemList.dom.firstChild
        while searchEl and searchEl.nextSibling
            break    if searchEl is itemEl
            itemIdx++
            searchEl = searchEl.nextSibling
        itemIdx = (if (searchEl is itemEl) then itemIdx else false)
        return false    if itemIdx is false
        me.valueStore.getAt itemIdx

    toggleSelectionByListItemNode: (itemEl, keepExisting) ->
        me = this
        rec = me.getRecordByListItemNode(itemEl)
        selModel = me.selectionModel
        if rec
            if selModel.isSelected(rec)
                selModel.setLastFocused null    if selModel.isFocused(rec)
                selModel.deselect rec
            else
                selModel.select rec, keepExisting

    removeByListItemNode: (itemEl) ->
        me = this
        rec = me.getRecordByListItemNode(itemEl)
        if rec
            me.valueStore.remove rec
            me.setValue me.valueStore.getRange()

    getRawValue: ->
        me = this
        inputEl = me.inputEl
        result = undefined
        me.inputEl = false
        result = me.callParent(arguments)
        me.inputEl = inputEl
        result

    setRawValue: (value) ->
        me = this
        inputEl = me.inputEl
        result = undefined
        me.inputEl = false
        result = me.callParent([value])
        me.inputEl = inputEl
        result

    addValue: (value) ->
        me = this
        me.setValue Ext.Array.merge(me.value, Ext.Array.from(value))    if value

    removeValue: (value) ->
        me = this
        me.setValue Ext.Array.difference(me.value, Ext.Array.from(value))    if value

    setValue: (value, doSelect, skipLoad) ->
        me = this
        valueStore = me.valueStore
        valueField = me.valueField
        record = undefined
        len = undefined
        i = undefined
        valueRecord = undefined
        h = undefined
        unknownValues = []
        value = null    if Ext.isEmpty(value)
        value = value.split(me.delimiter)    if Ext.isString(value) and me.multiSelect
        value = Ext.Array.from(value, true)
        i = 0
        len = value.length

        while i < len
            record = value[i]
            if not record or not record.isModel
                valueRecord = valueStore.findExact(valueField, record)
                if valueRecord >= 0
                    value[i] = valueStore.getAt(valueRecord)
                else
                    valueRecord = me.findRecord(valueField, record)
                    unless valueRecord
                        if me.forceSelection
                            unknownValues.push record
                        else
                            valueRecord = {}
                            valueRecord[me.valueField] = record
                            valueRecord[me.displayField] = record
                            valueRecord = new me.valueStore.model(valueRecord)
                    value[i] = valueRecord    if valueRecord
            i++
        if (skipLoad isnt true) and (unknownValues.length > 0) and (me.queryMode is "remote")
            params = {}
            params[me.valueField] = unknownValues.join(me.delimiter)
            me.store.load
                params: params
                callback: ->
                    me.itemList.unmask()    if me.itemList
                    me.setValue value, doSelect, true
                    me.autoSize()

            return false
        if not me.multiSelect and (value.length > 0)
            i = value.length - 1
            while i >= 0
                if value[i].isModel
                    value = value[i]
                    break
                i--
            value = value[value.length - 1]    if Ext.isArray(value)
        me.callParent [value, doSelect]

    getValueRecords: ->
        @valueStore.getRange()

    getSubmitData: ->
        me = this
        val = me.callParent(arguments)
        val[me.name] = Ext.encode(val[me.name])    if me.multiSelect and me.encodeSubmitValue and val and val[me.name]
        val

    mimicBlur: ->
        me = this
        me.inputEl.dom.value = ""    if me.selectOnTab and me.picker and me.picker.highlightedItem
        me.callParent arguments

    assertValue: ->
        me = this
        rawValue = me.inputEl.dom.value
        rec = (if not Ext.isEmpty(rawValue) then me.findRecordByDisplay(rawValue) else false)
        value = false
        if not rec and not me.forceSelection and me.createNewOnBlur and not Ext.isEmpty(rawValue)
            value = rawValue
        else value = rec    if rec
        me.addValue value    if value
        me.inputEl.dom.value = ""
        me.collapse()

    checkChange: (e)->
        if not @suspendCheckChange and not @isDestroyed
            me = this
            valueStore = me.valueStore
            lastValue = me.lastValue
            valueField = me.valueField
            newValue = Ext.Array.map(Ext.Array.from(me.value), (val) ->
                return val.get(valueField)    if val.isModel
                val
            , this)
            isEqual = me.isEqual(newValue, lastValue)
            if not isEqual or (newValue.length > 0 and valueStore.getCount() < newValue.length)
                newValue = newValue.join(@delimiter)

                valueStore.suspendEvents()
                valueStore.removeAll()
                valueStore.add me.valueModels    if Ext.isArray(me.valueModels)
                valueStore.resumeEvents()
                valueStore.fireEvent "datachanged", valueStore
                unless isEqual
                    me.lastValue = newValue
                    me.fireEvent "change", me, newValue, lastValue
                    me.onChange newValue, lastValue

    isEqual: (v1, v2) ->
        fromArray = Ext.Array.from
        valueField = @valueField
        i = undefined
        len = undefined
        t1 = undefined
        t2 = undefined
        v1 = fromArray(v1)
        v2 = fromArray(v2)
        len = v1.length
        return false    if len isnt v2.length
        i = 0
        while i < len
            t1 = (if v1[i].isModel then v1[i].get(valueField) else v1[i])
            t2 = (if v2[i].isModel then v2[i].get(valueField) else v2[i])
            return false    if t1 isnt t2
            i++
        true

    applyEmptyText: ->
        me = this
        emptyText = me.emptyText
        inputEl = undefined
        isEmpty = undefined
        if me.rendered and emptyText
            isEmpty = Ext.isEmpty(me.value) and not me.hasFocus
            inputEl = me.inputEl
            if isEmpty
                inputEl.dom.value = emptyText
                inputEl.addCls me.emptyCls
                me.listWrapper.addCls me.emptyCls
            else
                inputEl.dom.value = ""    if inputEl.dom.value is emptyText
                me.listWrapper.removeCls me.emptyCls
                inputEl.removeCls me.emptyCls
            me.autoSize()

    beforeFocus: ->
        me = this
        inputEl = me.inputEl
        emptyText = me.emptyText
        isEmpty = undefined
        if emptyText and inputEl.dom.value is emptyText
            inputEl.dom.value = ""
            isEmpty = true
            inputEl.removeCls me.emptyCls
            me.listWrapper.removeCls me.emptyCls
        inputEl.dom.select()    if me.selectOnFocus or isEmpty

    onFocus: ->
        me = this
        focusCls = me.focusCls
        itemList = me.itemList
        itemList.addCls focusCls    if focusCls and itemList
        me.callParent arguments

    onBlur: ->
        me = this
        focusCls = me.focusCls
        itemList = me.itemList
        itemList.removeCls focusCls    if focusCls and itemList
        me.callParent arguments

    renderActiveError: ->
        me = this
        invalidCls = me.invalidCls
        itemList = me.itemList
        hasError = me.hasActiveError()
        itemList[(if hasError then "addCls" else "removeCls")] me.invalidCls + "-field"    if invalidCls and itemList
        me.callParent arguments

    autoSize: ->
        me = this
        height = undefined
        if me.grow and me.rendered
            me.autoSizing = true
            me.updateLayout()
        me

    afterComponentLayout: ->
        me = this
        width = undefined
        if me.autoSizing
            height = me.getHeight()
            if height isnt me.lastInputHeight
                me.alignPicker()    if me.isExpanded
                me.fireEvent "autosize", me, height
                me.lastInputHeight = height
                delete me.autoSizing
})
