Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.AdvancedADSTContainer = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config, {
      title:       "Advanced Query Select",
      id:          "advanced_query_select",
      itemId:      "advanced_query_select",
      hidden:      true,
      padding:     '0 0 5 5',
      layout:     'auto',
      listeners: {
        'show': function()
        {
          this.ownerCt.getForm().setValues([{id: 'adv', value: true}]);
        },
        'hide': function()
        {
          this.ownerCt.getForm().setValues([{id: 'adv', value: false}]);
        }
      },
      defaults:{
        xtype: 'container',
        layout: 'form',
        cls: 'ux-layout-auto-float-item',
        style: {
          width: 'auto' ,
          minWidth: '200px'
        },
        defaults:{
          width: 200
        }
      },
      items: [{
        items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Absenteeism',
            emptyText:  'Gross',
            id: 'absent_adv',
            store: config.absenteeism
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel:    'Age',
            emptyText:     'Select Age...',
            id: 'age_adv',
            selectOnFocus: true,
            store: config.age
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Gender',
            emptyText:  'Select Gender...',
            id: 'gender_adv',
            store: config.gender
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Grade',
            emptyText:  'Select Grade...',
            id: 'grade_adv',
            store: config.grade
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'School',
            emptyText:  'Select School...',
            id: 'school_adv',
            store: config.schools
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'School Type',
            emptyText:  'Select School Type...',
            id: 'school_type_adv',
            store: config.school_type
          })
        },{
          items:{
            fieldLabel:    'Start Date',
            name:          'startdt_adv',
            id:            'startdt_adv',
            xtype:         'datefield',
            endDateField:  'enddt_adv',
            emptyText:     'Select Start Date...',
            selectOnFocus: true,
            ctCls: 'ux-combo-box-cls'
          }
        },{
          items:{
            fieldLabel:     'End Date',
            name:           'enddt_adv',
            id:             'enddt_adv',
            xtype:          'datefield',
            startDateField: 'startdt_adv',
            emptyText:      'Select End Date',
            selectOnFocus:  true,
            ctCls: 'ux-combo-box-cls'
          }
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Symptoms',
            emptyText:  'Select Symptoms...',
            id: 'symptoms_adv',
            store: config.symptoms
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Zipcode',
            emptyText:  'Select Zipcode...',
            id: 'zip_adv',
            store: config.zipcode
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Data Function',
            emptyText:  'Raw',
            id: 'data_func_adv',
            store: config.data_functions
          })
        },{
          items: {
            xtype: 'field',
            id: 'adv',
            value: false,
            hidden: true
          }
        },{
        cls: 'clear',
        items:{
          xtype:   'button',
          text:    "Switch to Simple View >>",
          style:   {
            margin: '0px 0px 5px 5px'
          },
          scope:   this,
          handler: function(buttonEl, eventObj){
            Ext.getCmp('advanced_query_select').hide();
            Ext.getCmp('simple_query_select').show();
          }
        }
      }]
    });
    Talho.Rollcall.AdvancedADSTContainer.superclass.constructor.call(this, config);
  }
});