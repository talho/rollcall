
Ext.namespace("Talho.Rollcall.ux");

Talho.Rollcall.ux.Filter = Ext.extend(Ext.FormPanel, {  
  border: false,
  cls: 'rollcall-filter',
  labelAlign: 'top',
  defaults: {
    labelStyle: 'font-weight:bold;'
  },
  
  initComponent: function () {
    Talho.Rollcall.ux.Filter.superclass.initComponent.call(this);
  },
  
  reset: function () {
    Ext.each(this.resetable, function (r) {
      if (r.reset) {
        r.reset(r.item)
      }
      else {
        r.clearValue();
      }
    });
  },
  
  loadOptions: function (data) {
    Ext.each(this.loadable, function (d) {
      if (!d.set) {
        d.item.store = new Ext.data.JsonStore({ fields: d.fields, data: data[d.key] });
      }
      else {
        d.set(d.item, data[d.key]);
      }
    });
  },
  
  getParameters: function () {
    var params = new Object;
    
    Ext.each(this.getable, function (item) {
      var value = item.get(item.param);
      if (this._includeParam(value)) {
        params[item.key] = value;
      }
    }, this);
    
    return params;
  },
  
  getListBoxParameters: function (listBox) {
    var records = [];
    
    Ext.each(listBox.getSelectedRecords(), function (selected) {
      records.push(selected.get('value'));
    });
    
    return records;
  },
  
  _includeParam: function (value) {
    if (value != undefined && value != null && value != "") {
      if (value instanceof Array) {
        if (value.length == 0) {
          return false
        }
      }      
      return true;
    }    
    return false;
  }
});