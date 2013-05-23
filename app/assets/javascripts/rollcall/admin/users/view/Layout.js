
Ext.ns('Talho.Rollcall.admin.users.view');

Talho.Rollcall.admin.users.view.Layout = Ext.extend(Ext.Panel, {
  id: 'rollcall_admin_users',
  closable: true,
  layout: 'border',
  border: false,
  title: 'Rollcall Users',

  initComponent: function () {
    var me = this;
    this.findBubble = function () {
      return me;
    };

    this.editHolder = new Ext.Container({ region: 'center', margins: '5', layout: 'fit' });
    this.items = [
      new Talho.Rollcall.admin.users.view.Users({ region: 'west', width: 250, title: 'Users', margins: '5' }),
      this.editHolder
    ]

    Talho.Rollcall.admin.users.view.Layout.superclass.initComponent.call(this);
  }
});


Ext.reg('talho-rollcall-admin-users-layout', Talho.Rollcall.admin.users.view.Layout);
