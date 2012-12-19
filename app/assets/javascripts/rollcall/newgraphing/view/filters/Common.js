
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Common = Ext.extend(Talho.Rollcall.ux.Filter, {
  anchor: '100% 25%',
  
  initComponent: function () {
    this.enableBubble(['submitquery', 'reset'])
    
    this.individual = true;
    
    var start = new Ext.form.DateField({fieldLabel: 'Start Date', name: 'startdt',
      endDateField: 'enddt_simple', emptyText:'Select Start Date...', allowBlank: true,
      selectOnFocus:true, ctCls: 'ux-combo-box-cls'
    });
    
    var end = new Ext.form.DateField({ fieldLabel: 'End Date', name: 'enddt',
      startDateField: 'startdt_simple', emptyText:'Select End Date...', allowBlank: true,
      selectOnFocus:true, ctCls: 'ux-combo-box-cls'
    });
    
    var data_function = new Talho.Rollcall.ux.ComboBox({editable: false, fieldLabel: 'Data Function'});
         
    var absent = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'Absenteeism', editable: false});
    
    this.school = new Ext.Button({text: 'School', toggleGroup: 'individual', pressed: true, scope: this, handler: function () { this.individual = true; }});  
    
    this.district = new Ext.Button({text: 'School District', toggleGroup: 'individual', scope: this, handler: function () { this.individual = false; }}); 
    
    var submit = {xtype: 'button', text: "Submit", scope: this, handler: function () { this.fireEvent('submitquery'); }};
    
    var reset = {xtype: 'button', text: "Reset", scope: this, handler: function () { this.fireEvent('reset'); }};
    
    this.items = [start, end, data_function, absent, this.school, this.district, submit, reset];
    
    this.loadable = [
      {item: absent, fields: ['id', 'value'], key: 'absenteeism'}, 
      {item: data_function, fields: ['id', 'value'], key: 'data_functions'}
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
      {key: 'absent', get: function () { return absent.getValue() }},
      {key: 'return_individual_school', get: function (individual) { return (individual ? 'on' : null); }, param: this.individual}
    ];
    
    Talho.Rollcall.graphing.view.filter.Common.superclass.initComponent.call(this);
  },
  
  reset: function () {
    this.individual = true;
    this.school.toggle(true, true);
    this.district.toggle(false, true);
    
    Talho.Rollcall.graphing.view.filter.Common.superclass.reset();
  }  
  
});