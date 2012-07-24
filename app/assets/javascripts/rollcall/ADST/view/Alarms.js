//= require rollcall/ADST/view/ADSTAlarmsPanel

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Alarms = Ext.extend(Ext.Panel, {
  title: 'Alarms',
  itemId: 'alarms_c',
  id: 'alarms_c',
  region: 'west',
  layout: 'fit',
  bodyStyle: 'padding:0px',
  width: 140,
  minSize: 140,
  maxSize: 140,
  hideBorders: true,

  constructor: function (config) {
    Talho.Rollcall.ADST.view.Alarms.superclass.constructor.apply(this, config);
    
    this.items = [
      //TODO: Fill with ADSTAlarmsPanel
      new Talho.Rollcall.ADST.view.ADSTAlarmsPanel({}),
    ];
    
    this.bbar = [
      { text:    'Refresh',
        iconCls: 'x-tbar-loading',
        handler: function(btn,event)
        {
          //TODO: Controllerize
          this.ownerCt.ownerCt.getComponent('alarm_panel').alarms_store.load();
        }
      },
      { text:     'GIS',
        id:       'gis_button',
        itemId:   'gis_button',
        iconCls:  'x-tbar-gis',
        disabled: true,
        handler:  function()
        {
          //TODO: Controllerize
          this.ownerCt.ownerCt.getComponent('alarm_panel')._load_alarm_gmap_window();
        }
      }
    ];
  }
});
