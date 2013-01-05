Ext.define 'App.model.mixins.StateModel'

    isSaved:->
        this.get('state') == 'saved'

    isPending: ->
        this.get('state') == 'pending'

    isApproved:->
        this.get('state') == 'approved'


    markSaved:->
        this.set('state_event', 'mark_saved' ) if this.isPending()

    markApproved:->
        this.set('state_event', 'mark_approved' )
