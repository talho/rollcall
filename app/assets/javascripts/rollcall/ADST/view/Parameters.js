//= require rollcall/ADST/view/SimpleParameters
//= require rollcall/ADST/view/AdvancedParameters

Ext.namespace("Talho.Rollcall.ADST.view");

//TODO fix type
Talho.Rollcall.ADST.view.Parameters = Ext.extend(Ext.Panel, {
  id: 'parameters',

  initComponent: function (config) {    
    this.items = [];
    
    
    //TODO if sotre fails no auth and keel everytin up on controller
    this.store = new Ext.data.JsonStore({
      root:     'options',
      fields:   ['absenteeism', 'age', 'data_functions', 'data_functions_adv', 'gender', 'grade', 'school_districts','school_type', 'schools', 'symptoms', 'zipcode'],
      url:      '/rollcall/query_options',
      autoLoad: true,
    });
    
    this.store.addListener('load', function (store, records) {
      this.items.add(new Talho.Rollcall.ADST.view.SimpleParameters({options: records[0].data}));
      this.items.add(new Talho.Rollcall.ADST.view.AdvancedParameters({options: records[0].data, hidden: true}));
    }, this);
    
    Talho.Rollcall.ADST.view.Parameters.superclass.initComponent.apply(this, config);        
  },
  
  //TODO make it toggle between simple and advanced
  toggle: function () {
    
  }
});