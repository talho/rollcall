//= rollcall/ux/ComboBox.js

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.SimpleParameters = Ext.extend(Ext.Container, {
  id: "simple_query_select",
  itemId: "simple_query_select",
  layout: 'auto',
  defaults: {
    xtype:  'container',
    layout: 'form',
    cls:    'ux-layout-auto-float-item',
    style:  {
      width:    '200px',
      minWidth: '200px'
    },
    defaults: {
      width: 200
    }
  },
  boxMinHeight: 100,
  
  //TODO clean up _simple stuff
  initComponent: function () {    
    var absent = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'Absenteeism', emptyText:'Gross', id: 'absent_simple', editable: false});
        
    var district = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'School District', emptyText:'Select School District...',
      allowBlank: true, id: 'school_district_simple', itemId: 'school_district_simple',
      displayField: 'name', editable: false,      
      listeners: {
        scope: this,
        select: function(comboBox, record, index){
          this.clearOptions(comboBox.id);
        }
      }
    });
    
    var school = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'School', emptyText:'Select School...', allowBlank: true, 
      id: 'school_simple', itemId: 'school_simple', displayField: 'display_name', editable: false,      
      listeners: {
        scope: this,
        select: function(comboBox, record, index){
          this.clearOptions(comboBox.id);
        }
      }
    });    
    
    var type = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'School Type', emptyText:'Select School Type...', allowBlank: true,
      id: 'school_type_simple', itemId: 'school_type_simple', editable: false,      
      listeners: {
        scope: this,
        select: function(comboBox, record, index){
          this.clearOptions(comboBox.id);
        }
      }
    });
    
    var func = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'Data Function', emptyText: 'Raw', id: 'data_func_simple', editable: false });
    
    this.loadable = [
      {item: absent, fields: ['id', 'value'], key: 'absenteeism'},
      {item: district, fields: ['id', 'name'], key: 'school_districts'},
      {item: school, fields: ['id', 'display_name'], key: 'schools'},
      {item: type, fields: ['id', 'value'], key: 'school_type'},
      {item: func, fields: ['id', 'value'], key: 'data_functions'}
    ];
    
    this.clearable = [school, district, type];
    
    this.items = [
      {items: absent},
      {items: district},
      {items: school},
      {items: type},
      {items:
        {xtype: 'datefield', fieldLabel: 'Start Date', name: 'startdt_simple', id: 'startdt_simple',
          endDateField: 'enddt_simple', emptyText:'Select Start Date...', allowBlank: true,
          selectOnFocus:true, ctCls: 'ux-combo-box-cls'
        }
      },
      {items:
        {xtype: 'datefield', fieldLabel: 'End Date', name: 'enddt_simple', id: 'enddt_simple',
          startDateField: 'startdt_simple', emptyText:'Select End Date...', allowBlank: true,
          selectOnFocus:true, ctCls: 'ux-combo-box-cls'
        }
      },
      {items: func },
      {items:
        {xtype: 'container', cls: 'line-check-simple', items:[
          {xtype: 'checkbox', id: 'return_individual_school_simple', checked: true, 
            boxLabel: "Return Individual School Results"
          }]
        }
      },
    ];
    
    Talho.Rollcall.ADST.view.SimpleParameters.superclass.initComponent.apply(this, arguments);
    this.doLayout();
  },
  
  getParams: function (form_values) {
    var params = new Object;
    for (key in form_values) {
      if (form_values[key].indexOf('...') == -1) {
        params[key.replace(/_simple/,'')] = form_values[key].replace(/\+/g, " ");
      }
    }    
    
    return params;
  },
  
  loadOptions: function (data) {
    Ext.each(this.loadable, function (d) {
      d.item.store = new Ext.data.JsonStore({fields: d.fields, data: data[d.key] });
    });
  },
  
  clearOptions: function (id) {
    Ext.each(this.clearable, function (item) {
      if (id != item.id) {
        item.clearValue();
      }
    });
  }
});
