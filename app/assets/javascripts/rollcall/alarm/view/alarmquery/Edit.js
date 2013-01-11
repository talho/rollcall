//= require rollcall/alarm/view/alarmquery/New

Ext.namespace("Talho.Rollcall.alarm.view.alarmquery");

Talho.Rollcall.alarm.view.alarmquery.Edit = Ext.extend(Talho.Rollcall.alarm.view.alarmquery.New, { 
  layout: 'fit',
  
  _initComponent: function () {
    Talho.Rollcall.alarm.view.alarmquery.Edit.superclass.initComponent.call(this);
    
    this.addEvents('createnewalarmquery');
    this.enableBubble('editalarmquery');    
  },
  
  _loadOptions: function (data) {
    Talho.Rollcall.alarm.view.alarmquery.Edit.superclass._loadOptions(data);
    
    this.title = 'Edit Alarm Query';
    
    for (key in this.params) {
      
    }
  }
});