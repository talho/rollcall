//= require rollcall/ADST/view/ADSTAlarmsPanel

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Alarms = Ext.extend(Ext.Panel, {
  hideBorders: true,

  constructor: function (config) {
    Talho.Rollcall.ADST.view.Alarms.superclass.constructor.apply(this, config);
    
    // this.items = [
      // //TODO: Fill with ADSTAlarmsPanel
      // new Talho.Rollcall.ADST.view.ADSTAlarmsPanel({}),
    // ];
    
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
