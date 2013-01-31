
Ext.namespace("Talho.Rollcall.alarm.view.alarmquery");

Talho.Rollcall.alarm.view.alarmquery.Index = Ext.extend(Ext.Panel, { 
  layout: 'fit',
  title: 'Alarm Queries',
  autoScroll: true,
  
  initComponent: function () {
    this.addEvents('createalarmquery', 'alarmgis', 'queryedit', 'querydelete', 'querytoggle', 'refresh');
    this.enableBubble(['createalarmquery', 'alarmgis', 'queryedit', 'querydelete', 'querytoggle', 'refresh']);
    
    var tpl = new Ext.XTemplate(
      '<ul style="padding: 20px;">',
        '<tpl for=".">',
          '<li class="rollcallalarmquery-click" queryid="{id}"><div>',
            '<h3 class="rollcallalarmquery-header">{name}</h3>',
            '<div class="forum-divider">&nbsp;</div>',
            '<span class="forum-actions query-toggle {[ this.toggleClass(values) ]}" queryid="{id}">&nbsp;&laquo;{[ this.toggleText(values) ]}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>',
            '<span class="forum-actions query-edit" queryid="{id}">&laquo;Edit&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>',
            '<span class="forum-actions query-delete" queryid="{id}">&laquo;Delete</span><br /><br />',
            '<table>',
              '<tr><td>Deviation: </td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>{deviation}</td></tr><tr><td>&nbsp;</td></tr>',
              '<tr><td>Severity: </td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>{severity}</td></tr><tr><td>&nbsp;</td></tr>',
              '<tr><td>Starting on: </td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>{start_date}</td></tr><tr><td>&nbsp;</td></tr>',
              '<tr><td>Schools: </td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>{[ this.catSchools(values) ]}</td></tr><tr><td>&nbsp;</td></tr>',
              '<tr><td>School Districts: </td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>{[ this.catSchoolDistricts(values) ]}</td></tr><tr><td>&nbsp;</td></tr>',                         
            '</table>',
          '</li><br />',
        '</tpl>',
      '</ul>',
      {
        catSchools: function (values) {
          if (values.schools.length == 0) {
            return 'None';  
          }
          
          var names = [];
          for (var i = 0; i < values.schools.length; i++) {
            names.push(values.schools[i].display_name)
          }
          
          return names.join(", ");
        },
        
        catSchoolDistricts: function (values) {
          if (values.school_districts.length == 0) {
            return 'None';  
          }
          
          var names = [];
          for (var i = 0; i < values.school_districts.length; i++) {
            names.push(values.school_districts[i].name)
          }
          
          return names.join(", ");
        },
        
        toggleText: function (values) {
          if (values.alarm_set) {
            return "Turn Off";
          }
          
          return "Turn On";
        },
        
        toggleClass: function (values) {
          if (values.alarm_set) {
            return "toggle";
          }                    
        }
      }
    );
    
    this.store = new Ext.data.JsonStore({
      url: '/rollcall/alarm_query',
      root: 'results',
      fields: ['id', 'user_id', 'name', 'alarm_set', 'deviation', 'severity', 'start_date', 'schools', 'school_districts'],
      autoLoad: true,
      autoDestroy: true
    });
    
    var indexView = new Ext.DataView({
      store: this.store,
      tpl: tpl,
      listeners: {
        scope: this,
        'click': {
          fn: function (div, index, node, e) {
            if (node.classList.contains('query-toggle')) {
              this.fireEvent('querytoggle', parseInt(node.attributes['queryid'].value), node.classList.contains('toggle'));
            }
            if (node.classList.contains('query-edit')) {
              this.fireEvent('queryedit', parseInt(node.attributes['queryid'].value));
            }
            if (node.classList.contains('query-delete')) {
              Ext.MessageBox.confirm("Confirm Delete", "Would you like to delete this?", function (btn) {
                if (btn == 'yes') {
                  this.fireEvent('querydelete', parseInt(node.attributes['queryid'].value));
                } 
              }, this);
            }
          }
        }
      }      
    });
    
    this.items = [
      indexView
    ];
    
    this.bbar = [      
      '->',
      {xtype: 'button', text: 'Refresh', scope: this, handler: function () {
          this.fireEvent('refresh');     
        }
      },
      {xtype: 'button', text: 'GIS', id: 'gis_button', itemId: 'gis_button', iconCls: 'x-tbar-gis', scope: this,
        handler: function() {
          this.fireEvent('alarmgis');
        }
      },
      {xtype: 'button', text: 'Create New Alarm Query', handler: function () { this.fireEvent('createalarmquery'); }, scope: this}      
    ];
    
    Talho.Rollcall.alarm.view.alarmquery.Index.superclass.initComponent.call(this);
  },

  refresh: function () {
    this.store.reload();
  }
});