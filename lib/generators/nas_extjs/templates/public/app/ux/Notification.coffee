#
# *    Notification / Toastwindow extension for Ext JS 4.x
# *
# *	Copyright (c) 2011 Eirik Lorentsen (http://www.eirik.net/)
# *
# *	Examples and documentation at: http://www.eirik.net/Ext/ux/window/Notification.html
# *
# *	Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
# *	and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
# *
# *	Version: 2.1
# *	Last changed date: 2012-08-12
#
Ext.define( "App.ux.Notification", {
  extend: "Ext.window.Window"
  alias: "widget.uxNotification"
  cls: "ux-notification-window"
  autoClose: true
  autoHeight: true
  plain: false
  draggable: false
  shadow: false
  focus: Ext.emptyFn

  # For alignment and to store array of rendered notifications. Defaults to document if not set.
  manager: null
  useXAxis: false

  # Options: br, bl, tr, tl, t, l, b, r
  position: "br"

  # Pixels between each notification
  spacing: 6

  # Pixels from the managers borders to start the first notification
  paddingX: 30
  paddingY: 10
  slideInAnimation: "easeIn"
  slideBackAnimation: "bounceOut"
  slideInDuration: 1500
  slideBackDuration: 1000
  hideDuration: 500
  autoCloseDelay: 7000
  stickOnClick: true
  stickWhileHover: true

  # Private. Do not override!
  isHiding: false
  readyToHide: false
  destroyAfterHide: false
  closeOnMouseOut: false

  # Caching coordinates to be able to align to final position of siblings being animated
  xPos: 0
  yPos: 0
  statics:
    defaultManager:
      el: null

  initComponent: ->
    me = this

    # Backwards compatibility
    me.position = me.corner  if Ext.isDefined(me.corner)
    me.slideBackAnimation = me.slideDownAnimation  if Ext.isDefined(me.slideDownAnimation)
    me.autoCloseDelay = me.autoDestroyDelay  if Ext.isDefined(me.autoDestroyDelay)
    me.autoCloseDelay = me.autoHideDelay  if Ext.isDefined(me.autoHideDelay)
    me.autoClose = me.autoHide  if Ext.isDefined(me.autoHide)
    me.slideInDuration = me.slideInDelay  if Ext.isDefined(me.slideInDelay)
    me.slideBackDuration = me.slideDownDelay  if Ext.isDefined(me.slideDownDelay)
    me.hideDuration = me.fadeDelay  if Ext.isDefined(me.fadeDelay)

    # 'bc', lc', 'rc', 'tc' compatibility
    me.position = me.position.replace(/c/, "")
    me.updateAlignment me.position
    me.setManager me.manager
    me.callParent arguments

  onRender: ->
    me = this
    me.el.hover (->
      me.mouseIsOver = true
    ), (->
      me.mouseIsOver = false
      if me.closeOnMouseOut
        me.closeOnMouseOut = false
        me.close()
    ), me
    @callParent arguments

  updateAlignment: (position) ->
    me = this
    switch position
      when "br"
        me.paddingFactorX = -1
        me.paddingFactorY = -1
        me.siblingAlignment = "br-br"
        if me.useXAxis
          me.managerAlignment = "bl-br"
        else
          me.managerAlignment = "tr-br"
      when "bl"
        me.paddingFactorX = 1
        me.paddingFactorY = -1
        me.siblingAlignment = "bl-bl"
        if me.useXAxis
          me.managerAlignment = "br-bl"
        else
          me.managerAlignment = "tl-bl"
      when "tr"
        me.paddingFactorX = -1
        me.paddingFactorY = 1
        me.siblingAlignment = "tr-tr"
        if me.useXAxis
          me.managerAlignment = "tl-tr"
        else
          me.managerAlignment = "br-tr"
      when "tl"
        me.paddingFactorX = 1
        me.paddingFactorY = 1
        me.siblingAlignment = "tl-tl"
        if me.useXAxis
          me.managerAlignment = "tr-tl"
        else
          me.managerAlignment = "bl-tl"
      when "b"
        me.paddingFactorX = 0
        me.paddingFactorY = -1
        me.siblingAlignment = "b-b"
        me.useXAxis = 0
        me.managerAlignment = "t-b"
      when "t"
        me.paddingFactorX = 0
        me.paddingFactorY = 1
        me.siblingAlignment = "t-t"
        me.useXAxis = 0
        me.managerAlignment = "b-t"
      when "l"
        me.paddingFactorX = 1
        me.paddingFactorY = 0
        me.siblingAlignment = "l-l"
        me.useXAxis = 1
        me.managerAlignment = "r-l"
      when "r"
        me.paddingFactorX = -1
        me.paddingFactorY = 0
        me.siblingAlignment = "r-r"
        me.useXAxis = 1
        me.managerAlignment = "l-r"

  getXposAlignedToManager: ->
    me = this
    xPos = 0

    # Avoid error messages if the manager does not have a dom element
    if me.manager and me.manager.el and me.manager.el.dom
      unless me.useXAxis

        # Element should already be aligned verticaly
        return me.el.getLeft()
      else

        # Using getAnchorXY instead of getTop/getBottom should give a correct placement when document is used
        # as the manager but is still 0 px high. Before rendering the viewport.
        if me.position is "br" or me.position is "tr" or me.position is "r"
          xPos += me.manager.el.getAnchorXY("r")[0]
          xPos -= (me.el.getWidth() + me.paddingX)
        else
          xPos += me.manager.el.getAnchorXY("l")[0]
          xPos += me.paddingX
    xPos

  getYposAlignedToManager: ->
    me = this
    yPos = 0

    # Avoid error messages if the manager does not have a dom element
    if me.manager and me.manager.el and me.manager.el.dom
      if me.useXAxis

        # Element should already be aligned horizontaly
        return me.el.getTop()
      else

        # Using getAnchorXY instead of getTop/getBottom should give a correct placement when document is used
        # as the manager but is still 0 px high. Before rendering the viewport.
        if me.position is "br" or me.position is "bl" or me.position is "b"
          yPos += me.manager.el.getAnchorXY("b")[1]
          yPos -= (me.el.getHeight() + me.paddingY)
        else
          yPos += me.manager.el.getAnchorXY("t")[1]
          yPos += me.paddingY
    yPos

  getXposAlignedToSibling: (sibling) ->
    me = this
    if me.useXAxis
      if me.position is "tl" or me.position is "bl" or me.position is "l"

        # Using sibling's width when adding
        sibling.xPos + sibling.el.getWidth() + sibling.spacing
      else

        # Using own width when subtracting
        sibling.xPos - me.el.getWidth() - me.spacing
    else
      me.el.getLeft()

  getYposAlignedToSibling: (sibling) ->
    me = this
    if me.useXAxis
      me.el.getTop()
    else
      if me.position is "tr" or me.position is "tl" or me.position is "t"

        # Using sibling's width when adding
        sibling.yPos + sibling.el.getHeight() + sibling.spacing
      else

        # Using own width when subtracting
        sibling.yPos - me.el.getHeight() - sibling.spacing

  getNotifications: (alignment) ->
    me = this
    me.manager.notifications[alignment] = []  unless me.manager.notifications[alignment]
    me.manager.notifications[alignment]

  setManager: (manager) ->
    me = this
    me.manager = manager
    me.manager = Ext.getCmp(me.manager)  if typeof me.manager is "string"

    # If no manager is provided or found, then the static object is used and the el property pointed to the body document.
    unless me.manager
      me.manager = me.statics().defaultManager
      me.manager.el = Ext.getBody()  unless me.manager.el
    me.manager.notifications = {}  if typeof me.manager.notifications is "undefined"

  beforeShow: ->
    me = this
    if me.stickOnClick
      if me.body and me.body.dom
        Ext.fly(me.body.dom).on "click", (->
          me.cancelAutoClose()
          me.addCls "notification-fixed"
        ), me
    if me.autoClose
      me.task = new Ext.util.DelayedTask(me.doAutoClose, me)
      me.task.delay me.autoCloseDelay

    # Shunting offscreen to avoid flicker
    me.el.setX -10000
    me.el.setOpacity 1

  afterShow: ->
    me = this
    notifications = me.getNotifications(me.managerAlignment)
    if notifications.length
      me.el.alignTo notifications[notifications.length - 1].el, me.siblingAlignment, [0, 0]
      me.xPos = me.getXposAlignedToSibling(notifications[notifications.length - 1])
      me.yPos = me.getYposAlignedToSibling(notifications[notifications.length - 1])
    else
      me.el.alignTo me.manager.el, me.managerAlignment, [(me.paddingX * me.paddingFactorX), (me.paddingY * me.paddingFactorY)], false
      me.xPos = me.getXposAlignedToManager()
      me.yPos = me.getYposAlignedToManager()
    Ext.Array.include notifications, me
    me.el.animate
      to:
        x: me.xPos
        y: me.yPos
        opacity: 1

      easing: me.slideInAnimation
      duration: me.slideInDuration
      dynamic: true

    @callParent arguments

  slideBack: ->
    me = this
    notifications = me.getNotifications(me.managerAlignment)
    index = Ext.Array.indexOf(notifications, me)

    # Not animating the element if it already started to hide itself or if the manager is not present in the dom
    if not me.isHiding and me.el and me.manager and me.manager.el and me.manager.el.dom and me.manager.el.isVisible()
      if index
        me.xPos = me.getXposAlignedToSibling(notifications[index - 1])
        me.yPos = me.getYposAlignedToSibling(notifications[index - 1])
      else
        me.xPos = me.getXposAlignedToManager()
        me.yPos = me.getYposAlignedToManager()
      me.stopAnimation()
      me.el.animate
        to:
          x: me.xPos
          y: me.yPos

        easing: me.slideBackAnimation
        duration: me.slideBackDuration
        dynamic: true


  cancelAutoClose: ->
    me = this
    me.task.cancel()  if me.autoClose

  doAutoClose: ->
    me = this
    unless me.stickWhileHover and me.mouseIsOver

      # Close immediately
      me.close()
    else

      # Delayed closing when mouse leaves the component.
      me.closeOnMouseOut = true

  removeFromManager: ->
    me = this
    if me.manager
      notifications = me.getNotifications(me.managerAlignment)
      index = Ext.Array.indexOf(notifications, me)
      unless index is -1
        Ext.Array.erase notifications, index, 1

        # Slide "down" all notifications "above" the hidden one
        while index < notifications.length
          notifications[index].slideBack()
          index++

  hide: ->
    me = this

    # Avoids restarting the last animation on an element already underway with its hide animation
    if not me.isHiding and me.el
      me.isHiding = true
      me.cancelAutoClose()
      me.stopAnimation()
      me.el.animate
        to:
          opacity: 0

        easing: "easeIn"
        duration: me.hideDuration
        dynamic: false
        listeners:
          afteranimate: ->
            me.removeFromManager()
            me.readyToHide = true
            me.hide me.animateTarget, me.doClose, me


    # Calling parent's hide function to complete hiding
    if me.readyToHide
      me.isHiding = false
      me.readyToHide = false
      me.removeCls "notification-fixed"
      me.callParent arguments
      me.destroy()  if me.destroyAfterHide

  destroy: ->
    me = this
    unless me.hidden
      me.destroyAfterHide = true
      me.hide me.animateTarget, me.doClose, me
    else
      me.callParent arguments


#	Changelog:
# *
# *  2011-09-01 - 1.1: Bugfix. Array.indexOf not universally implemented, causing errors in IE<=8. Replaced with Ext.Array.indexOf.
# *  2011-09-12 - 1.2: Added config options: stickOnClick and stickWhileHover.
# *  2011-09-13 - 1.3: Cleaned up component destruction.
# *  2012-03-06 - 2.0: Renamed some properties ending with "Delay" to the more correct: "Duration".
# *                    Moved the hiding animation out of destruction and into hide.
# *                    Renamed the corresponding "destroy" properties to "hide".
# *                    (Hpsam) Changed addClass to addCls.
# *                    (Hpsam) Avoiding setting 'notification-fixed' when auto hiding.
# *                    (Justmyhobby) Using separate arrays to enable managers to mix alignments.
# *                    (Kreeve_ctisn) Removed default title.
# *                    (Jmaia) Center of edges can be used for positioning. Renamed corner property to position.
# *                    (Hpsam) Hiding or destroying manager does not cause errors.
# *  2012-08-12 - 2.1: Renamed autoHide to autoClose
# *                    (Dmurat) Enabled reuse of notifications (closeAction: 'hide')
# *                    (Idonofrio) Destroying notification by default (closeAction: 'destroy')
#
})