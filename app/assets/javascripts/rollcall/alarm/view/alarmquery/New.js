
Ext.namespace("Talho.Rollcall.alarm.view.alarmquery");

Talho.Rollcall.alarm.view.alarmquery.New = Ext.extend(Ext.Window, { 
  layout: 'fit',  
  
  initComponent: function () {
    this.addEvents('cancelnewalarmquery', 'createnewalarmquery');
    this.enableBubble(['cancelnewalarmquery', 'createnewalarmquery']);
    
    this.width = 800;
    this.height = 225;
    
    var store = new Ext.data.JsonStore();
    
    this.name = new Ext.form.TextField({fieldLabel: 'Name'});
    this.deviation = new Ext.form.SliderField({minValue: 0, maxValue: 100, fieldLabel: 'Deviation', values: [0,100]});
    this.severity = new Ext.form.SliderField({minValue: 0, maxValue: 100, fieldLabel: 'Serverity', values: [0,100]});
    this.start_date = new Ext.form.DateField({fieldLabel: 'Start Date'});
    this.end_date = new Ext.form.DateField({fieldLabel: 'End Date'});
    this.school_district = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form', store: store,
      columns: [{dataIndex: 'value', cls:'school-district-list-item'}], hideHeaders: true, height: 110, fieldLabel: 'School District'        
    });
    
    this.school = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form', store: store,
      columns: [{dataIndex: 'value', cls:'school-name-list-item'}], hideHeaders: true, height: 110, fieldLabel: 'School'           
    });    
    
    this.items = [      
      {xtype: 'panel', layout: 'hbox', defaults: { border: false }, items: [
        {xtype: 'spacer', width: 20},
        {xtype: 'panel', cls: 'rollcall-alarm-query-new', layout: 'form', defaults: { width: 200 }, items: [
          this.name,
          this.deviation,
          this.severity,
          this.start_date,
          this.end_date
        ]},
        {xtype: 'spacer', width: 20},
        {xtype: 'panel', layout: 'form', labelAlign: 'top', defaults: { width: 200 }, cls: 'rollcall-alarm-query-new', items: [this.school]}, 
        {xtype: 'spacer', width: 20},
        {xtype: 'panel', layout: 'form', labelAlign: 'top', defaults: { width: 200 }, cls: 'rollcall-alarm-query-new', items: [this.school_district]},
        {xtype: 'spacer', width: 20}
      ]}
    ];
    
    this.addListener('afterrender', function () { this._loadWindow(); }, this);
    
    this.buttons = [
      {xtype: 'button', text: 'Cancel', handler: function () { this.fireEvent('cancelnewalarmquery'); }, scope: this},
      {xtype: 'button', text: 'Create Alarm Query', handler: function () { this.fireEvent('createnewalarmquery'); }, scope: this}
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
    this.end_date.setValue(data['end']);
  },
});