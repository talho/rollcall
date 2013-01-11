
Ext.namespace("Talho.Rollcall.alarm.view.alarm");

Talho.Rollcall.alarm.view.alarm.Index = Ext.extend(Ext.Panel, { 
  layout: 'fit',
  
  initComponent: function () {
    if (this.alarm_query_id) {
      var url = 'rollcall/alarms/' + this.alarm_query_id;
    }
    else {
      var url = 'rollcall/alarms';
    }
    
    var store = new Ext.data.JsonStore({
      url: url,
      root: 'results',
      fields: ['school_name', 'school_id', 'report_date', 'reason'],
      autoLoad: true
    });
    
    var tpl = new Ext.XTemplate(
      '<table>',
        '<tpl for=".">',
          '<tr>',
            '<td>{school_id}</td>',
            '<td>{report_date}</td>',
            '<td>{reason}</td>',
          '</tr>',
        '</tpl>',
      '</table>'
    );    
    
    this.items = [
      {xtype: 'dataview', store: store, tpl: tpl}
    ]
    
    Talho.Rollcall.alarm.view.alarm.Index.superclass.initComponent.call(this);
  }
});