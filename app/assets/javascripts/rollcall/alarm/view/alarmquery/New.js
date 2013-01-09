
Ext.namespace("Talho.Rollcall.alarm.view.alarmquery");

Talho.Rollcall.alarm.view.alarmquery.New = Ext.extend(Ext.Window, { 
  layout: 'fit',
  
  initComponent: function () {
    var windowSize = Ext.getBody().getViewSize();
    this.width = windowSize.width - 40;
    this.height = windowSize.height - 40;
    
    this.items = [
      {xtype: 'panel', layout: 'form', items: [
        {xtype: 'textfield', fieldLabel: 'Name'},
        {xtype: 'listview', fieldLabel: 'School'},
        {xtype: 'listview', fieldLabel: 'School District'},
      ]}
    ];
    
    this.bbar = new Ext.Toolbar({
      items: [
        '->',
        {xtype: 'button', text: 'Cancel', handler: function () { this.fireEvent('cancelnewalarmquery'); }, scope: this},
        {xtype: 'button', text: 'Create Alarm Query', handler: function () { this.fireEvent('createnewalarmquery'); }, scope: this}
      ]
    });
    
    Talho.Rollcall.alarm.view.alarmquery.New.superclass.initComponent.call(this);
  }
});