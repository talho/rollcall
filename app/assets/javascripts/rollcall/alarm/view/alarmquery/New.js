
Ext.namespace("Talho.Rollcall.alarm.view.alarmquery");

Talho.Rollcall.alarm.view.alarmquery.New = Ext.extend(Ext.Window, { 
  layout: 'fit',    
  
  initComponent: function () {
    this.title = 'New Alarm Query'
    
    this.addEvents('cancelnewalarmquery', 'createnewalarmquery');
    this.enableBubble(['cancelnewalarmquery', 'createnewalarmquery']);
    
    this.width = 800;
    this.height = 300; 
    
    var store = new Ext.data.JsonStore();
    
    this.name = new Ext.form.TextField({fieldLabel: 'Name', allowBlank: false});
    
    this.deviation = new Ext.slider.MultiSlider({minValue: 0, maxValue: 4, fieldLabel: 'Deviation', 
      listeners: {
        scope: this,
        'change': function (obj, newValue, oldValue) {
          if (newValue == 0) {
            this.deviation_tip.setText('- This alarm will not activate based on the deviation', false);
          }
          else {
            this.deviation_tip.setText('- When any school has deviation greater than ' + newValue + ' standard deviation' + (newValue > 1 ? 's' : ''), false);
          }
        }    
      },
      plugins: new Ext.slider.Tip() 
    });
    
    this.severity = new Ext.slider.MultiSlider({minValue: 0, maxValue: 100, values: [0], fieldLabel: 'Serverity %',
      listeners: {
        scope: this,
        'change': function (obj, newValue, oldValue) {
          if (newValue == 0) {
            this.severity_tip.setText('- This alarm will not activate based on severity (percent of students absent)', false);
          }
          else {
           this.severity_tip.setText('- When any school has severity (percent of students absent) over ' + newValue + '%', false); 
          }          
        }        
      },
      plugins: new Ext.slider.Tip()          
    });
    
    this.start_date = new Ext.form.DateField({fieldLabel: 'Start Date'});    
    this.school_district = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form', store: store,
      columns: [{dataIndex: 'value', cls:'school-district-list-item'}], hideHeaders: true, height: 110, fieldLabel: 'School District'        
    });    
    this.school = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form', store: store,
      columns: [{dataIndex: 'value', cls:'school-name-list-item'}], hideHeaders: true, height: 110, fieldLabel: 'School'           
    });
    this.deviation_tip = new Ext.form.Label({text: '- This alarm will not activate based on the deviation',});
    this.severity_tip = new Ext.form.Label({text: '- This alarm will not activate based on severity (percent of students absent)'});
    this.error_label = new Ext.form.Label({hidden: true});
    
    this.items = [
      {xtype: 'panel', items: [ 
        {xtype: 'panel', border: false, layout: 'hbox', defaults: { border: false }, items: [
          {xtype: 'spacer', width: 20},
          {xtype: 'panel', cls: 'rollcall-alarm-query-new', layout: 'form', defaults: { width: 200 }, items: [
            this.name,
            this.deviation,
            this.severity,
            this.start_date       
          ]},
          {xtype: 'spacer', width: 20},
          {xtype: 'panel', layout: 'form', labelAlign: 'top', defaults: { width: 200 }, cls: 'rollcall-alarm-query-new', items: [this.school]}, 
          {xtype: 'spacer', width: 20},
          {xtype: 'panel', layout: 'form', labelAlign: 'top', defaults: { width: 200 }, cls: 'rollcall-alarm-query-new', items: [this.school_district]},
          {xtype: 'spacer', width: 20}
        ]},
        {xtype: 'panel', border: false, defaults: { border: false }, cls: 'rollcall-alarm-query-new-reason', items: [
          {xtype: 'panel', items: [ new Ext.form.Label({text: 'This alarm query will trigger when'}) ]}, 
          {xtype: 'panel', cls: 'rollcall-alarm-query-new-tip', items: [ this.deviation_tip ]},
          {xtype: 'panel', cls: 'rollcall-alarm-query-new-tip', items: [ this.severity_tip ]}          
        ]},
        {xtype: 'panel', border: false, defaults: {border: false}, cls: 'rollcall-alarm-query-new-reason', items: [
          {xtype: 'panel', items: [ new Ext.form.Label({text: 'Please fix the following to save changes'})  ]},
          {xtype: 'panel', cls: 'rollcall-alarm-query-new-tip', items: [ this.error_label ]}
        ]}
      ]}
    ];
    
    this.addListener('afterrender', function () { this._loadWindow(); }, this);
    
    this.buttons = [
      {xtype: 'button', text: 'Cancel', handler: function () { this.close(); }, scope: this},
      {xtype: 'button', text: 'Create Alarm Query', handler: function () { this._validate(); }, scope: this}
    ];
    
    Talho.Rollcall.alarm.view.alarmquery.New.superclass.initComponent.call(this);
  },
  
  _loadWindow: function () {
    var mask = new Ext.LoadMask(this.getEl(), {msg: "Loading..."});
    mask.show();
    
    Ext.Ajax.request({
      url: '/rollcall/query_options',
      method: 'GET',
      scope: this,
      success: function (response) {
        var data = Ext.decode(response.responseText);
        this._loadOptions(data);    
        this.doLayout();
        mask.hide();        
      }
    });
  },
  
  _loadOptions: function (data) {
    this.school.bindStore(new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'display_name'}], data: data['schools']}));
    this.school_district.bindStore(new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'name'}], data: data['school_districts']}));
    this.start_date.setValue(data['start']);    
  },
  
  _validate: function () {
    this.error_label.hide();
    
    var errors = []
    
    if (!this.name.validate()) {
      errors.push('Please specify an alarm name');  
    }
    
    if (this.deviation.getValues()[0] == 0 && this.severity.getValues()[0] == 0) {
      errors.push('Please set the deviation or severity slider');
    }
    
    if (this.school.getSelectionCount() == 0 && this.school_district.getSelectionCount() == 0) {
      errors.push('Please select a school or school district');
    }
    
    if (errors.length == 0) {      
      this.setHeight(300);
      this.error_label.hide();
      this.fireEvent('createnewalarmquery', this._getParams());
    }
    else {
      this.error_label.setText(errors.join(', '));
      this.error_label.show();
      this.setHeight(350);
    }
  },
  
  _getParams: function () {
    var params = {};
    var school_ids = [];
    var school_district_ids = [];
    
    Ext.each(this.school_district.getSelectedRecords(), function (record) {      
      school_district_ids.push(record.get('id'));
    });
    
    Ext.each(this.school.getSelectedRecords(), function (record) {
      school_ids.push(record.get('id'));        
    });
    
    if (school_ids.length != 0) {
      params['alarm_query[school_ids][]'] = school_ids;
    }
    
    if (school_district_ids.length != 0) {
      params['alarm_query[school_district_ids][]'] = school_district_ids;
    }
    
    params['alarm_query[severity]'] = this.severity.getValues()[0];
    params['alarm_query[deviation]'] = this.deviation.getValues()[0];
    params['alarm_query[start_date]'] = this.start_date.getValue();
    params['alarm_query[name]'] = this.name.getValue();
    
    return params;
  }
});