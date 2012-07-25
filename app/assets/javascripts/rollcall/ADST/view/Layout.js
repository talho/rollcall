//= require rollcall/ADST/view/AlarmQueries
//= require rollcall/ADST/view/Alarms
//= require rollcall/ADST/view/SearchForm

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Layout = Ext.extend(Ext.Panel, {
  id: 'adst',
  closable: true,
  layout: 'fit',
  border: false,
  title: "Rollcall ADST",
  
  initComponent: function () {
    var alarm_queries = new Talho.Rollcall.ADST.view.AlarmQueries();
    
    
    this.items = [
      {id: 'adst_layout', layout: 'border', autoScroll: true, scope: this, 
        defaults: {collapsible: false, split: true},
        items: [          
          {xtype: 'panel', itemId: 'alarm_queries', title: 'Alarm Queries', region: 'south', height: 120, minSize: 120,
            maxSize: 120, autoScroll: true, layout: 'fit',
            items: [alarm_queries]
          },
          {itemId: 'alarms', region: 'west', title: 'Alarms', layout: 'fit', bodyStyle: 'padding: 0px',
            width: 140, minSize: 140, maxSize: 140, hideBorders: true,
            // items: new Talho.Rollcall.ADST.view.Alarms(),
            bbar: [
              {text: 'refresh', iconCls: 'x-tbar-loading',
                handler: function (btn, event) {
                  //TODO fix this so no ownerCt and move to Controller
                  //this.ownerCt.ownerCt.getComponent('alarm_panel').alarms_store.load();
                }
              },
              '->',
              {text: 'GIS', id: 'gis_button', itemId: 'gis_button', iconCls: 'x-tbar-gis', disabled: true,
                handler: function () {
                  //TODO fix this so no ownerCt and move to Controller
                  //this.ownerCt.ownerCt.getComponent('alarm_panel')._load_alarm_gmap_window();
                } 
              }
            ]
          },
          {xtype: 'container', region: 'center', title: 'Advanced Disease Surveillance Tool'}
          // {itemId: 'adst_panel', title: 'Advanced Disease Surveillance Tool', border: false, collapsible: false,
            // region: 'center', autoScroll: true, scope: this,
            // items: 
            // {xtype: 'container', itemId: 'query_container', layout: 'column', scope: this, hideBorders: true,
              // items: new Talho.Rollcall.ADST.view.SearchForm()
            // }            
          // }
        ]
      }
    ];   
    Talho.Rollcall.ADST.view.Layout.superclass.initComponent.apply(this, arguments);
    
     
  }
});
