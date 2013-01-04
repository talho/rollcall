
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Common = Ext.extend(Talho.Rollcall.ux.Filter, {
  cls: 'rollcall-filter rollcall-filter-common',
  
  initComponent: function () {
    this.enableBubble(['submitquery', 'reset'])
    
    this.individual = true;
    
    var start = new Ext.form.DateField({name: 'startdt', fieldLabel: 'Start Date',
      endDateField: 'enddt', emptyText:'Select Start Date...', allowBlank: true,
      selectOnFocus: true, ctCls: 'ux-combo-box-cls', width: 200
    });
    
    var end = new Ext.form.DateField({name: 'enddt', fieldLabel: 'End Date',
      startDateField: 'startdt', emptyText:'Select End Date...', allowBlank: true,
      selectOnFocus: true, ctCls: 'ux-combo-box-cls', width: 200
    });
    
    var data_function = new Talho.Rollcall.ux.ComboBox({editable: false, emptyText: 'Data Function...', fieldLabel: 'Data Function'});
         
    var absent = new Talho.Rollcall.ux.ComboBox({editable: false, emptyText: 'Absenteeism...', fieldLabel: 'Absenteeism'});
    
    this.school = new Ext.Button({text: 'School', toggleGroup: 'individual', pressed: true, scope: this, handler: function () { this.individual = true; }});  
    
    this.district = new Ext.Button({text: 'School District', toggleGroup: 'individual', scope: this, handler: function () { this.individual = false; }});     
    
    this.items = [start, end, data_function, absent, {xtype: 'container', html: "<span style='font-weight:bold'>Mode:</span>"}, 
      {xtype: 'spacer', height: 5}, {xtype: 'container', border: false, layout: 'hbox', items: [this.school, {xtype: 'spacer', width: 5}, this.district]}
    ];
    
    this.loadable = [
      {item: absent, fields: ['id', 'value'], key: 'absenteeism'}, 
      {item: data_function, fields: ['id', 'value'], key: 'data_functions'},
      {item: start, set: this.reset_starts, key: 'start', set: function (item, value) { item.setValue(value); }},
      {item: end, set: this.reset_end, key: 'end', set: function (item, value) { item.setValue(value); }}
    ];
    
    this.resetable = [
      {item: start},
      {item: end},
      {item: data_function},
      {item: absent}
    ];
    
    this.getable = [
      {key: 'startdt', get: function () { return start.getValue(); }},
      {key: 'enddt', get: function () { return end.getValue(); }},
      {key: 'data_func', get: function () { return data_function.getValue(); }},
      {key: 'absent', get: function () { return absent.getValue(); }}      
    ];
    
    Talho.Rollcall.graphing.view.filter.Common.superclass.initComponent.call(this);
  },
  
  getIndividual: function () {
    return (this.individual ? 'on' : null);
  },
  
  getParameters: function () {
    var params = Talho.Rollcall.graphing.view.filter.Common.superclass.getParameters();
    if (this.individual) {
      params['return_individual_school'] = 'on';
    }
    return params;
  },
  
  reset: function () {
    this.individual = true;
    this.school.toggle(true, true);
    this.district.toggle(false, true);
    
    Talho.Rollcall.graphing.view.filter.Common.superclass.reset();
  }
    
});