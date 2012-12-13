
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Filter = Ext.extend(Ext.Panel, {
  layout: 'form',
  border: false,
  
  initComponent: function () {
    Talho.Rollcall.graphing.view.filter.Filter.superclass.initComponent.call(this);
  },
  
  reset: function () {
    Ext.each(this.resetable, function (r) {
      if (r.reset) {
        r.reset(r.item)
      }
      else {
        r.item.clearValue();
      }
    });
  },
  
  loadOptions: function (data) {
    Ext.each(this.loadable, function (d) {
      d.item.store = new Ext.data.JsonStore({fields: d.fields, data: data[d.key] });
    });
  },
  
  getParameters: function () {
    
  }
});