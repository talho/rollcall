
Ext.namespace("Talho.Rollcall.admin.users.view");

Talho.Rollcall.admin.users.view.Users = Ext.extend(Ext.Panel, {
  layout: 'fit',
  constructor: function(){
    Talho.Rollcall.admin.users.view.Users.superclass.constructor.apply(this, arguments);
    this.addEvents('userselect');
    this.enableBubble('userselect');
  },

  getBubbleTarget: function(){
    if(!this.layoutParent){ // bubble up to the layout class way up above
      this.layoutParent = this.findParentByType('talho-rollcall-admin-users-layout');
    }
    return this.layoutParent;
  },

  initComponent: function(){
    var grid = new Ext.grid.GridPanel({
        autoScroll: true,
        store: new Ext.data.JsonStore({
          fields: ['name', 'id'],
          url: '/rollcall/users.json',
          restful: true,
          root: 'results',
          autoLoad: true
        }),
        columns: [{id: 'name', dataIndex: 'name'}],
        autoExpandColumn: 'name',
        hideHeaders: true,
        border: false
    });
    this.items = [
      grid
    ]

    Talho.Rollcall.admin.users.view.Users.superclass.initComponent.apply(this, arguments);

    grid.getSelectionModel().on('rowselect', this.user_selected, this)
  },

  user_selected: function(sm, i, record){
    this.fireEvent('userselect', record.get('id'), record.get('name'));
  }
});
