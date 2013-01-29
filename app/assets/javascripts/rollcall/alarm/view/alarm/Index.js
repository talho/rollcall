
Ext.namespace("Talho.Rollcall.alarm.view.alarm");

Talho.Rollcall.alarm.view.alarm.Index = Ext.extend(Ext.Panel, { 
  layout: 'fit',
  autoScroll: true,
  
  initComponent: function () {
    this.title = "All My Alarms";
    
    this.addEvents('alarmshow');
    this.enableBubble('alarmshow');
    
    if (this.alarm_query_id) {
      var url = 'rollcall/alarms/' + this.alarm_query_id;
    }
    else {
      var url = 'rollcall/alarms';
    }
    
    this.store = new Ext.data.JsonStore({
      url: url,
      method: 'GET',
      root: 'results',
      fields: ['school_name', 'school_id', 'report_date', 'reason', 'id'],
      autoLoad: true,
      params: {page: 1, start: 0, limit: 15},
      totalProperty: 'total_results',
      writer: new Ext.data.JsonWriter({encode: false}),      
      restful: true,
    });
    
    var tpl = new Ext.XTemplate(
      '<div class="forum-wrap" style="padding: 20px;">',
        '<div class="forum-header">',
          '<span class="forum-header-title">School</span>',
          '<span class="forum-header-threads">Date</span>',
        '</div>',
        '<div class="forum-divider">&nbsp;</div>',
        '<ul class="forum-list" alarmid="{id}">',
          '<tpl for=".">',
            '<li class="forum-index-selector">',
              '<div class="forum-wrap" alarmid="{id}">',
                '<div class="forum-left" alarmid="{id}"><table>',
                  '<tr>',
                    '<td><span class="forum-title" alarmid="{id}">{school_name}</span></td>',
                  '</tr>',
                  '<tr>',
                    '<td>{reason}</td>',
                  '</tr>',
                '</table></div>',
                '<div class="forum-reply-count">{report_date}</div>',
                '<div class="forum-clear"></div>',       
              '</div>',               
            '</li>',          
          '</tpl>',
        '</ul>',
      '</div>'
    );
    
    this.bbar = new Ext.PagingToolbar({displayInfo: true, prependButtons: true, store: this.store, items: ['->'], pageSize: 15});
    
    this.items = [
      {xtype: 'dataview', store: this.store, tpl: tpl, scope: this, listeners: {
        'click': function (div, index, node, e) {
          if (node.attributes['alarmid']) {
            this.fireEvent('alarmshow', parseInt(node.attributes['alarmid'].value), this);
          }        
        },
        scope: this
      }}
    ]
    
    Talho.Rollcall.alarm.view.alarm.Index.superclass.initComponent.call(this);
  },
  
  refresh: function () {
    this.store.reload();
  }
});