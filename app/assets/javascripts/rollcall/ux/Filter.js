
Ext.namespace("Talho.Rollcall.ux");

Talho.Rollcall.ux.Filter = Ext.extend(Ext.Panel, {
  layout: 'form',
  border: false,
  
  initComponent: function () {
    Talho.Rollcall.ux.Filter.superclass.initComponent.call(this);
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