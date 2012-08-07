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
    var me = this,
      findBubble = function () {
        return me;
    }
    
    this.alarm_queries = new Talho.Rollcall.ADST.view.AlarmQueries({
      itemId: 'alarm_queries', getBubbleTarget: findBubble
    });
    
    var search_form = new Talho.Rollcall.ADST.view.SearchForm({getBubbleTarget: findBubble});
    
    this.getSearchForm = function () { return search_form };
    
    var results_store = this.getSearchForm().getResults().getResultsStore();
    
    this.items = [
      {id: 'adst_layout', layout: 'border', autoScroll: true, scope: this, 
        defaults: {collapsible: false, split: true},
        items: [   
          {xtype: 'panel', region: 'south', height: 120, title: 'Alarm Queries', layout: 'fit', padding: '2px 2px 4px 2px', items: this.alarm_queries},
          // {xtype: 'panel', itemId: 'alarms', region: 'west', title: 'Alarms', layout: 'fit', bodyStyle: 'padding: 0px',
            // width: 140, minSize: 140, maxSize: 140, hideBorders: true,
            // items: [new Talho.Rollcall.ADST.view.Alarms({getBubbleTarget: findBubble})],
            // bbar: [
              // {text: 'refresh', iconCls: 'x-tbar-loading',
                // handler: function (btn, event) {
                  // //TODO fix this so no ownerCt and move to Controller
                  // //this.ownerCt.ownerCt.getComponent('alarm_panel').alarms_store.load();
                // }
              // },
              // '->',
              // {text: 'GIS', id: 'gis_button', itemId: 'gis_button', iconCls: 'x-tbar-gis', disabled: true,
                // handler: function () {
                  // //TODO fix this so no ownerCt and move to Controller
                  // //this.ownerCt.ownerCt.getComponent('alarm_panel')._load_alarm_gmap_window();
                // } 
              // }
            // ]
          // },
          {xtype: 'panel', id: 'adst_panel', title: 'Advanced Disease Surveillance Tool', border: false, collapsible: false,
            region: 'center', autoScroll: true, scope: this,
            items: [
              search_form              
            ],
            bbar: [new Ext.PagingToolbar(
              {displayInfo: true, prependButtons: true, pageSize: 6, store: results_store }
            )]          
          }
        ]
      }
    ];   
    Talho.Rollcall.ADST.view.Layout.superclass.initComponent.apply(this, arguments);
  }
});
