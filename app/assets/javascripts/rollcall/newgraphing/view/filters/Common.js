
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Common = Ext.extend(Talho.Rollcall.ux.Filter, {
  anchor: '100% 25%',
  
  initComponent: function () {
    var start = {xtype: 'datefield', fieldLabel: 'Start Date', name: 'startdt',
      endDateField: 'enddt_simple', emptyText:'Select Start Date...', allowBlank: true,
      selectOnFocus:true, ctCls: 'ux-combo-box-cls'
    };
    
    var end = {xtype: 'datefield', fieldLabel: 'End Date', name: 'enddt',
      startDateField: 'startdt_simple', emptyText:'Select End Date...', allowBlank: true,
      selectOnFocus:true, ctCls: 'ux-combo-box-cls'
    };
    
    var data_function = new Talho.Rollcall.ux.ComboBox({ editable: false, fieldLabel: 'Data Function'});
         
    var absent = new Talho.Rollcall.ux.ComboBox({id: 'absent', fieldLabel: 'Absenteeism', editable: false});
    
    var school = new Ext.Button({text: 'School', toggleGroup: 'individual', pressed: true, scope: this, handler: function () { this._setIndividualValue(true); }});  
    
    var district = new Ext.Button({text: 'School District', toggleGroup: 'individual', scope: this, handler: function () { this._setIndividualValue(false); }}); 
    
    var submit = {xtype: 'button', text: "Submit"};
    
    var reset = {xtype: 'button', text: "Reset"};
    
    this.items = [start, end, data_function, absent, school, district, submit, reset];
    
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
      
    ];
    
    Talho.Rollcall.graphing.view.filter.Common.superclass.initComponent.call(this);
  }
});