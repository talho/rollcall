
Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.AdvancedParameters = Ext.extend(Ext.Container, {
  title: "Advanced Query Select",
  id: "advanced_query_select",
  itemId: "advanced_query_select",
  layout: 'auto',
  hidden: true,
  boxMinHeight: 200,

  //TODO split it out to take data and bind from not init
  initComponent: function () {
    var data = this.options
    
    var type = new Ext.ListView({id: 'school_type_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
        columns: [{dataIndex: 'value', cls:'school-type-list-item'}], hideHeaders: true, height: 90,        
    });
    
    var zip = new Ext.ListView({id: 'zip_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls:'zipcode-list-item'}], hideHeaders: true, height: 90,      
    }); 
    
    var district = new Ext.ListView({id: 'school_district_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form', 
      columns: [{dataIndex: 'value', cls:'school-district-list-item'}], hideHeaders: true, height: 90,      
    });
    
    var school = new Ext.ListView({id: 'school_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls:'school-name-list-item'}], hideHeaders: true, height: 90,      
    });
    
    var age = new Ext.ListView({id: 'age_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls: 'age-list-item'}], hideHeaders: true, height: 90,      
    });
    
    var grade = new Ext.ListView({id: 'grade_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls: 'grade-list-item'}], hideHeaders: true, height: 90,      
    });
    
    var symptoms = new Ext.ListView({id: 'symptoms_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'name', width: 0.70, cls:'symptom-list-item'}, {dataIndex: 'value'}],
      hideHeaders: true, height: 160 
    });
    
    var gender = new Ext.form.ComboBox({id: 'gender_adv', fieldLabel: 'Gender', editable: false, emptyText: 'Select Gender...'});
    
    var absent = new Ext.form.ComboBox({id: 'absent_adv', fieldLabel: 'Absenteeism', editable: false, value: 'Gross'});
    
    var start = new Ext.form.DateField({fieldLabel: 'Start Date Adv', name: 'startdt_adv', id: 'startdt_adv',
      endDateField: 'enddt_adv', emptyText: 'Select Start Date...', allowBlank: true, ctCls: 'ux-combo-box-cls'
    });
    
    var end = new Ext.form.DateField({fieldLabel: 'End Date Adv', name: 'enddt_adv', id: 'enddt_adv',              startDateField: 'startdt_adv',
      emptyText: 'Select End Date...', allowBlank: true, ctCls: 'ux-combo-box-cls'
    });
    
    var func = new Ext.form.ComboBox({id: 'data_func_adv', editable: false, value: 'Raw'});
    
    this.loadable = [
      {item: type, fields: ['id', 'value'], key: 'school_type'}, 
      {item: zip, fields: ['id', 'value'], key: 'zipcode'},
      {item: district, fields: ['id', {name:'value', mapping:'name'}], key: 'school_districts'}, 
      {item: school, fields: ['id', {name:'value', mapping:'display_name'}], key: 'schools'},
      {item: age, fields: ['id', 'value'],  key: 'age'},
      {item: grade, fields: ['id', 'value'], key: 'grade'},
      {item: symptoms, fields: ['id', 'name', {name:'value', mapping:'icd9_code'}], key: 'symptoms'},
      {item: gender, fields: ['id', 'value'], key: 'gender'},
      {item: absent, fields: ['id', 'value'], key: 'absenteeism'}, 
      {item: func, fields: ['id', 'value'], key: 'data_functions_adv'}
    ];    
    this.clearable = [school, type, zip, age, grade, symptoms, district];    
    
    //TODO: Let's conditionalize this for School District & School
    var schoolFilter = {xtype: 'fieldset', layout: 'hbox', width: 262, title: 'School Filter',
      items: [
        {xtype: 'container', layout: 'vbox', width: 100, height: 230, defaults: { width:100 },
          items: [
            {xtype: 'label', html: 'School Type:'},
            type,
            {xtype: 'spacer', height: 5},
            {xtype: 'label', html: 'Zipcode:'},
            zip           
          ]          
        },
        {xtype: 'spacer', width: 5},
        {xtype: 'container', layout: 'vbox', width: 135, height: 230, defaults: { width:135 },
          items: [
            {xtype: 'label', html: 'School District:'},
            district,
            {xtype: 'spacer', height: 5},
            {xtype: 'label', html: 'School Name:'},
            school
          ]
        }
      ]
    };
    
    var iliFilter = {xtype: 'fieldset', layout: 'hbox', width: 328, title: 'ILI Data Filter',
      items: [
        {xtype: 'container', layout: 'vbox', width: 120, height: 230, defaults: { width:120 },
          items: [
            {xtype: 'label', html: 'Age:'},
            age,
            {xtype: 'spacer', height: 5},
            {xtype: 'label', html: 'Grade:'},
            grade
          ]
        },
        {xtype: 'spacer', width: 5},
        {xtype: 'container', layout: 'vbox', width: 180, height: 230, defaults: { width:180 },
          items: [
            {xtype: 'label', html: 'Symptoms:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ICD-9 Code'},
            symptoms,
            {xtype: 'spacer', height: 5},
            {xtype: 'label', html: 'Gender:'},
            gender
          ]
        }
      ]
    };
    
    var miscFilter = {xtype: 'fieldset', layout: 'hbox', width: 252, title: 'Data Types/Date Range',
      items: [
        {xtype: 'container', layout: 'vbox', width: 110, height: 230, defaults: { width:110 },
          items: [
            {xtype: 'label', html: 'Absenteeism:'},
            absent,
            {xtype: 'spacer', height: 10},
            {xtype: 'label', html: 'Start Date:'},
            start
          ]
        },
        {xtype: 'spacer', width: 10},
        {xtype: 'container', layout: 'vbox', width: 110, height: 230, defaults: { width:110 },
          items: [
            {xtype: 'label', html: 'Data Function:'},
            func,
            {xtype: 'spacer', height: 10},
            {xtype: 'label', html: 'End Date:'},
            end
          ]
        }
      ]
    };
       
    this.items = [
      {xtype: 'container', layout: 'hbox', height: 275, padding: '0 5', items: [
        {xtype: 'spacer', width: 5},
        schoolFilter,
        {xtype: 'spacer', width: 5},
        iliFilter,
        {xtype: 'spacer', width: 5},
        miscFilter        
      ]},
      {xtype: 'checkbox', id: 'return_individual_school_adv', cls: 'line-check', checked: true, boxLabel: "Return Individual School Results"},
      {xtype: 'button', cls: 'clear', text: 'Switch to Simple View >>', style: { margin: '6px 0px 5px 5px' },
        scope: this,
        //TODO handle this on Parameters
        handler: function(buttonEl, eventObj) {
          this.hide();
          // Ext.getCmp('rollcall_adst')._resetForm();
          // Ext.getCmp('simple_query_select').show();
        }
      }
    ];
    
    Talho.Rollcall.ADST.view.AdvancedParameters.superclass.initComponent.apply(this, arguments);
  },
  
  getParams: function (form_values) {
    var params = new Object;
    for (key in form_values) {
      if (form_values[key].indexOf('...') == -1) {
        params[key.replace(/_adv/,'')] = form_values[key].replace(/\+/g, " ");
      }
    }    
    
    return params;
  },
  
  reset: function () {
    Ext.each(this.clearable, function (item) {
      item.clearSelections();
    });
  },
  
  loadOptions: function (data) {
    Ext.each(this.loadable, function (d) {
      d.item.store = new Ext.data.JsonStore({fields: d.fields, data: data[d.key] })
    });
  }
});