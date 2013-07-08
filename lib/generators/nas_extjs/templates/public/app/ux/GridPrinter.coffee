###
@class Ext.ux.grid.Printer
@author Ed Spencer (edward@domine.co.uk)
Helper class to easily print the contents of a grid. Will open a new window with a table where the first row
contains the headings from your column model, and with a row for each item in your grid's store. When formatted
with appropriate CSS it should look very similar to a default grid. If renderers are specified in your column
model, they will be used in creating the table. Override headerTpl and bodyTpl to change how the markup is generated

Usage:

1 - Add Ext.Require Before the Grid code
Ext.require([
'Ext.ux.grid.GridPrinter',
]);

2 - Declare the Grid
var grid = Ext.create('Ext.grid.Panel', {
columns: //some column model,
store   : //some store
});

3 - Print!
Ext.ux.grid.Printer.mainTitle = 'Your Title here'; //optional
Ext.ux.grid.Printer.print(grid);

Original url: http://edspencer.net/2009/07/printing-grids-with-ext-js.html

Modified by Loiane Groner (me@loiane.com) - September 2011 - Ported to Ext JS 4
http://loianegroner.com (English)
http://loiane.com (Portuguese)

Modified by Bruno Sales - August 2012

Modified by Paulo Goncalves - March 2012

Modified by Beto Lima - March 2012

Modified by Beto Lima - April 2012

Modified by Paulo Goncalves - May 2012

Modified by Nielsen Teixeira - 2012-05-02

Modified by Joshua Bradley - 2012-06-01

Modified by Loiane Groner - 2012-09-08

Modified by Loiane Groner - 2012-09-24

Modified by Loiane Groner - 2012-10-17
FelipeBR contribution: Fixed: support for column name that cotains numbers
Fixed: added support for template columns

Modified by Loiane Groner - 2013-Feb-26
Fixed: added support for row expander plugin
Tested using Ext JS 4.1.2
###
Ext.define "App.ux.GridPrinter",
    requires: "Ext.XTemplate"
    statics:

        ###
        Prints the passed grid. Reflects on the grid's column model to build a table, and fills it using the store
        @param {Ext.grid.Panel} grid The grid to print
        ###


        writeRow: (win,tmpl,columns,record,row,grid)->
            data = {}
            data['class'] = if ( row % 2 == 0 ) then "even" else "odd"
            if Ext.isFunction( grid.viewConfig.getRowClass )
                data['class'] += ( ' ' + grid.viewConfig.getRowClass( record, row, {}, grid.store) )
            col = 0

            for column in columns
                col += 1
                data.align = 'center'

                value = record.data[column.dataIndex]
                found = false
                if column.xtype is "rownumberer"
                    varName = Ext.String.createVarName(column.id)
                    data[varName] = (row + 1)
                    found = true
                else if column.xtype is "templatecolumn"
                    value = (if column.tpl then column.tpl.apply(record.data) else value)
                    varName = Ext.String.createVarName(column.id)
                    data[varName] = value
                    found = true
                else
                    meta = { item: "", tdAttr: "", style: "" }
                    value = ( if column.renderer
                        column.renderer.call(grid, value, meta, record, row, col, grid.store, grid.view)
                    else
                        value )
                    varName = Ext.String.createVarName(column.dataIndex or column.text)
                    data[varName] = value
                    found = true

            win.document.write tmpl.apply( data )


        print: (grid) ->

            #We generate an XTemplate here by using 2 intermediary XTemplates - one to create the header,
            #the other to create the body (see the escaped {} below)
            columns = []

            #account for grouped columns
            Ext.each grid.columns, (c) ->
                return    if "actioncolumn" is c.xtype
                if c.items.length > 0
                    columns = columns.concat(c.items.items)
                else
                    columns.push c


            #get Styles file relative location, if not supplied
            if @stylesheetPath is null
                @stylesheetPath = '/assets/gridprinter.css'

            #use the headerTpl and bodyTpl markups to create the main XTemplate below
            headings = Ext.create("Ext.XTemplate", @headerTpl).apply(columns)

            htmlMarkup = [
                "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">",
                "<html class=\"" + Ext.baseCSSPrefix + "ux-grid-printer\">",
                "<head>",
                    "<meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\" />",
                    "<link href=\"" + @stylesheetPath + "\" rel=\"stylesheet\" type=\"text/css\" />",
                    "<title>" + @mainTitle + "</title>",
                "</head>",
                "<body class=\"" + Ext.baseCSSPrefix + "ux-grid-printer-body\">",
                    "<div class=\"" + Ext.baseCSSPrefix + "ux-grid-printer-noprint " + Ext.baseCSSPrefix + "ux-grid-printer-links\">",
                        "<a class=\"" + Ext.baseCSSPrefix + "ux-grid-printer-linkprint\" href=\"javascript:void(0);\" onclick=\"window.print();\">" + @printLinkText + "</a>",
                        "<a class=\"" + Ext.baseCSSPrefix + "ux-grid-printer-linkclose\" href=\"javascript:void(0);\" onclick=\"window.close();\">" + @closeLinkText + "</a>",
                    "</div>",
                    "<h1>" + @mainTitle + "</h1>",
                    "<table><thead><tr>", headings, "</tr></thead><tbody>"
            ]
            html = Ext.create("Ext.XTemplate", htmlMarkup).apply()

            #open up a new printing window, write to it, print it and close
            win = window.open("", "printgrid")

            #document must be open and closed
            win.document.open()
            win.document.clear()
            win.document.write html

            body = Ext.create("Ext.XTemplate", @bodyTpl).apply(columns)

            rowMarkup = Ext.create("Ext.XTemplate", [
                "<tr class=\"{class}\">"
                "<tpl for=\".\">"
                 body
                "</tpl>"
                "</tr>"
            ])

            store = grid.getStore().clone({ buffered: false })

            rowNum   = 0
            loadAndAppend = (page,last)->
                if page == last
                    win.document.write "</tbody></table></body></html>"
                    win.document.close()
                else
                    store.loadPage( page, {
                        scope: this
                        callback: (rows)->
                            this.writeRow(win, rowMarkup, columns, row, rowNum+=1, grid) for row in rows
                            loadAndAppend( page+1, last )
                    })

            loadAndAppend = loadAndAppend.bind(this)
            loadAndAppend( 1, Math.ceil( store.getTotalCount() / store.pageSize ) + 1 )

        stylesheetPath: null

        printAutomatically: false

        closeAutomaticallyAfterPrint: false

        mainTitle: ""

        printLinkText: "[print]"

        closeLinkText: "[close]"

        headerTpl: ["<tpl for=\".\">", "<th align=\"{align}\">{text}</th>", "</tpl>"]

        bodyTpl: [
            "<tpl for=\".\">",
            "<td align=\"{align}\" class=\"{tdCls}\">{{[Ext.String.createVarName(values.dataIndex||values.text )]}}</td>",
            "</tpl>"
        ]
