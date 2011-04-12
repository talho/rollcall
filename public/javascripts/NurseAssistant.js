Ext.ns("Talho.Rollcall");

Talho.Rollcall.NurseAssistant = Ext.extend(function(){}, {
  constructor: function(config){
    this.init_store = new Ext.data.JsonStore({
      root:      'options',
      fields:    ['race', 'age', 'gender', 'grade', 'symptoms', 'zip', 'total_enrolled_alpha', 'app_init'],
      url:       '/rollcall/nurse_assistant_options',
      autoLoad:  true,
      listeners: {
        scope: this,
        load:  function(this_store, records){
          this.getPanel().get(0).getBottomToolbar().getComponent('new_student_btn').enable();
        }
      }
    });

    this.student_reader = new Ext.data.JsonReader({
      root:          'results',
      totalProperty: 'total_results',
      fields: [
        {name:'id',                 type:'string'},
        {name:'first_name',         type:'string'},
        {name:'last_name',          type:'string'},
        {name:'contact_first_name', type:'string'},
        {name:'contact_last_name',  type:'string'},
        {name:'symptom',            type:'string'},
        {name:'treatment',          type:'string'},
        {name:'grade',              type:'integer'},
        {name:'address',            type:'string'},
        {name:'zip',                type:'string'},
        {name:'phone',              type:'string'},
        {name:'gender',             type:'string'},
        {name:'race',               type:'integer'},
        {name:'temperature',        type:'integer'},
        {name:'treatment',          type:'string'},
        {name:'dob',                renderer: Ext.util.Format.dateRenderer('m-d-Y')},
        {name:'student_number',     type:'integer'},
        {name:'report_date',        renderer: Ext.util.Format.dateRenderer('m-d-Y')}
      ]
    });

    this.student_store = new Ext.data.GroupingStore({
      autoLoad:       true,
      autoDestroy:    true,
      autoSave:       true,
      reader:         this.student_reader,
      writer:         new Ext.data.JsonWriter({encode: false}),
      url:            '/rollcall/nurse_assistant',
      sortInfo:       {field: 'report_date'},
      groupField:     'report_date',
      restful:        true,
      container_mask: null,
      baseParams:     {
        filter_report_date: new Date()  
      },
      listeners: {
        scope: this,
        load:  function(){
          this.getPanel().doLayout();
        }
      }
    });

    var main_panel = new Ext.Panel({
      title:    config.title,
      itemId:   config.id,
      layout:   'fit',
      closable: true,
      items:    [{
        xtype:  'grid',
        title:  'Current Student Visits',
        id:     'nurse_assistant',
        itemId: 'nurse_assistant',
        frame:  'true',
        store:  this.student_store,
        cm:     new Ext.grid.ColumnModel({
          columns: [
            {id:'student_number',    header:'Student Number',     dataIndex:'student_number'},
            {id:'first_name_column', header:'Student First Name', dataIndex:'first_name'},
            {id:'last_name_column',  header:'Student Last Name',  dataIndex:'last_name'},
            {id:'symptom_column',    header:'Symptoms',           dataIndex:'symptom'},
            {id:'header',            header:'Action',             dataIndex:'treatment'},
            {id:'visit_date',        header:'Visit Date',         dataIndex:'report_date'},
            {
              xtype:     'xactioncolumn',
              items:     [{icon:'/stylesheets/images/pencil.png'}],
              listeners: {
                scope: this,
                click: function(this_column, this_grid, row_index, event_obj)
                {
                  this.show_new_window(this.student_store.getAt(row_index));
                }
              }
            },{
              xtype:     'xactioncolumn',
              items:     [{icon:'/stylesheets/images/cross-circle.png'}],
              listeners: {
                scope: this,
                click: function(this_column, this_grid, row_index, event_obj)
                {
                  var record_index = row_index;
                  Ext.MessageBox.show({
                    title:   'Delete Student Visit',
                    msg:     'Are you sure you want to delete this recorded visitation? This can not be undone.',
                    buttons: {
                      ok:     'Yes',
                      cancel: 'No'
                    },
                    scope: this,
                    icon:  Ext.MessageBox.QUESTION,
                    fn:    function(btn_ok,txt,cfg_obj)
                    {
                      if(btn_ok == 'ok'){
                        this.student_store.removeAt(record_index);
                      }
                    }
                  });
                }
              }
            }
          ]
        }),
        viewConfig: {
          emptyText: "<div><b style='color:#000'>There are no student visits for "+Ext.util.Format.date(new Date(), 'm/d/Y')+"</b></div>"  
        },
        autoExpandColumn: 'symptom_column',
        autoExpandMax:    5000,
        bbar:             new Ext.PagingToolbar({
          store: this.student_store,
          items: [
            {text: 'New', iconCls:'add_forum', itemId:'new_student_btn', disabled: true, handler: function(){this.show_new_window();}, scope: this},
            '->',
            {xtype: 'textfield'},
            {xtype: 'button', text: 'Search', scope:this},
          ]
        }),
        tbar: {
          items: ['->',{
            fieldLabel:    'Visit Date',
            name:          'visit_date',
            id:            'visit_date',
            xtype:         'datefield',
            emptyText:     'Visit Date...',
            allowBlank:    true,
            selectOnFocus: true,
            width:         200,
            style:         {
              marginRight: '-4px'
            },
            listeners:{
              scope:  this,
              select: function (this_datefield, selected_date)
              {
                this.student_store.load({
                  params:{
                    filter_report_date: selected_date
                  }
                });
              },
              afterrender: function (this_datefield)
              {
                this_datefield.setValue(new Date());
              }
            }
          }]
        }
      }],
      listeners:{
        scope: this,
        afterrender: function(this_panel)
        {
          new Ext.LoadMask(this_panel.getEl(), {msg:"Please wait...", store: this.student_store});  
        }
      }
    });
    this.getPanel = function(){ return main_panel;};
  },

  show_new_window:function()
  {
    var argv           = this.show_new_window.arguments;
    var student_record = {};
    var form_method    = 'POST';
    var form_url       = '/rollcall/nurse_assistant';
    var symptom_data   = [];

    if(argv.length != 0){
      student_record    = argv[0].data;
      student_record.id = argv[0].get("id");
      form_method       = 'PUT';
      form_url         += '/'+student_record.id;
      for(i=0;i<student_record.symptom.split(',').length;i++){
        symptom_data.push({name: student_record.symptom.split(',')[i]})
      }
    }

    var student_list_store = new Ext.data.JsonStore({
      fields: ['first_name','last_name','student_number','phone','race','contact_first_name','contact_last_name','gender','dob','zip','address'],
      data:   []
    });
    
    var window_config = {
      layout:    'fit',
      title:     'New Visit',
      width:     800,
      height:    425,
      renderTo:  'nurse_assistant',
      scope:     this,
      modal:     true,
      constrain: true,
      items:     {
        xtype:        'form',
        layout:       'hbox',
        layoutConfig: {align:'stretch'},
        url:          '/rollcall/nurse_assistant',
        border:       false,
        method:       'POST',
        baseParams:   {authenticity_token: FORM_AUTH_TOKEN, school_id: 1},
        items:[{
          xtype:      'container',
          layout:     'form',
          labelAlign: 'top',
          flex:       1,
          items:      [{
            xtype:    'container',
            layout:   'auto',
            defaults: {
              xtype:  'container',
              layout: 'form',
              cls:    'ux-layout-auto-float-item',
              style:  {
                width:    '120px',
                minWidth: '120px'
              },
              defaults: {
                width: 120,
                allowBlank: false
              }
            },
            items:[{
              items:{
                xtype:           'textfield',
                fieldLabel:      'Student ID',
                id:              'student_number',
                name:            'student_number',
                value:           student_record.student_number,
                enableKeyEvents: true,
                listeners: {
                  scope:    this,
                  keypress: {
                    fn:    this.get_and_filter_by_student_number,
                    delay: 50
                  }
                }
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Student First Name',
                id:         'first_name',
                name:       'first_name',
                value:      student_record.first_name
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Student Last Name',
                id:         'last_name',
                name:       'last_name',
                value:      student_record.last_name
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Contact First Name',
                id:         'contact_first_name',
                value:      student_record.contact_first_name
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Contact Last Name',
                id:         'contact_last_name',
                value:      student_record.contact_last_name
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Address',
                id:         'address',
                value:      student_record.address
              }
            },{
              items: new Ext.form.ComboBox({
                fieldLabel:    'Zip',
                emptyText:     'Select Zipcode...',
                allowBlank:    false,
                id:            'zip',
                store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).get("zip")}),
                typeAhead:     true,
                triggerAction: 'all',
                mode:          'local',
                lazyRender:    true,
                autoSelect:    true,
                selectOnFocus: true,
                valueField:    'id',
                displayField:  'value',
                value:         student_record.zip
              })
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Phone Number',
                id:         'phone',
                value:      student_record.phone
              }
            },{
              items:{
                fieldLabel:    'DOB',
                id:            'dob',
                xtype:         'datefield',
                emptyText:     'Select Date of Birth...',
                allowBlank:    false,
                selectOnFocus: true,
                value:         student_record.dob
              }
            },{
              items: new Ext.form.ComboBox({
                fieldLabel:    'Gender',
                emptyText:     'Select Gender...',
                allowBlank:    false,
                id:            'gender',
                store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).get("gender")}),
                typeAhead:     true,
                triggerAction: 'all',
                mode:          'local',
                lazyRender:    true,
                autoSelect:    true,
                selectOnFocus: true,
                valueField:    'id',
                displayField:  'value',
                value:         student_record.gender
              })
            },{
              items: new Ext.form.ComboBox({
                fieldLabel:    'Race',
                emptyText:     'Select Race...',
                allowBlank:    false,
                id:            'race',
                store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).get("race")}),
                typeAhead:     true,
                triggerAction: 'all',
                mode:          'local',
                lazyRender:    true,
                autoSelect:    true,
                selectOnFocus: true,
                valueField:    'id',
                displayField:  'value',
                value:         student_record.race
              })
            },{
              items: new Ext.form.ComboBox({
                fieldLabel:    'Grade',
                emptyText:     'Select Grade...',
                allowBlank:    false,
                id:            'grade',
                store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).get("grade")}),
                typeAhead:     true,
                triggerAction: 'all',
                mode:          'local',
                lazyRender:    true,
                autoSelect:    true,
                selectOnFocus: true,
                valueField:    'id',
                displayField:  'value',
                value:         student_record.grade
              })
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Temperature',
                id:         'temperature',
                value:      student_record.temperature
              }
            }]
          }]
        },{
          xtype:      'container',
          flex:       1,
          layout:     'form',
          labelAlign: 'top',
          style:{
            paddingRight: '5'
          },
          items:[{
            xtype:      'textarea',
            fieldLabel: 'Action Taken',
            id:         'treatment',
            anchor:     '100%',
            allowBlank: false,
            value:      student_record.treatment
          },{
            xtype:  'container',
            layout: 'border',
            height: 200,
            items:  [{
              region:           'center',
              xtype:            'grid',
              id:               'symptoms_list',
              allowBlank:       false,
              autoExpandColumn: 'symptom_column',
              emptyText:        '<div style="color:#000;">No symptom selected.</div>',
              store:            new Ext.data.JsonStore({fields:['name'], data:symptom_data}),
              cm:               new Ext.grid.ColumnModel({
                columns:[{
                  id:        'symptom_column',
                  header:    'Symptoms',
                  dataField: 'symptom'
                },{
                  xtype: 'xactioncolumn',
                  icon:  '/stylesheets/images/cross-circle.png',
                  listeners:{
                    scope: this,
                    click: function(this_column, this_grid, row_index, event_obj)
                    {
                      this_grid.getStore().remove(this_grid.getStore().getAt(row_index));
                    }
                  }
                }]
              }),
              tbar: {
                items: new Ext.form.ComboBox({
                  fieldLabel:    'Symptom',
                  emptyText:     'Select Symptom...',
                  allowBlank:    false,
                  id:            'symptoms',
                  store:         new Ext.data.JsonStore({fields: ['id', 'name', 'icd9_code'], data: this.init_store.getAt(0).get("symptoms")}),
                  typeAhead:     true,
                  triggerAction: 'all',
                  mode:          'local',
                  lazyRender:    true,
                  autoSelect:    true,
                  selectOnFocus: true,
                  valueField:    'id',
                  displayField:  'name',
                  scope:         this,
                  listeners:     {
                    scope:  this,
                    select: function (this_grid, record, index)
                    {
                      Ext.getCmp('symptoms_list').getStore().loadData(record.data,true);
                    }
                  }
                })
              }
            }]
          }]
        },{
          xtype:     'grid',
          id:        'student_list',
          flex:      1,
          viewConfig: {
            emptyText: '<div style="color:#000;">Please enter student number.</div>'  
          },
          store:     student_list_store,
          cm:        new Ext.grid.ColumnModel({
            columns:[{
              id:        'student_first_name_column',
              header:    'First Name',
              dataField: 'first_name',
              autoWidth: true
            },{
              id:        'student_last_name_column',
              header:    'Last Name',
              dataField: 'last_name',
              autoWidth: true
            },{
              id:        'student_number_column',
              header:    'Number',
              dataField: 'student_number',
              width:     50
              //autoWidth:  true
            }]
          }),
          listeners: {
            rowclick: function(this_grid, index, event)
            {
              var record = this_grid.getStore().getAt(index);
              this_grid.ownerCt.getForm().setValues({
                address:            record.get('address'),
                zip:                record.get('zip'),
                dob:                record.get('dob'),
                gender:             record.get('gender'),
                phone:              record.get('phone'),
                race:               record.get('race'),
                contact_last_name:  record.get('contact_last_name'),
                contact_first_name: record.get('contact_first_name'),
                last_name:          record.get('last_name'),
                first_name:         record.get('first_name'),
                student_number:     record.get('student_number')
              });
            }
          }
        }],
        listeners: {
          scope:          this,
          actioncomplete: function(this_form, action)
          {
            this_form.ownerCt.close();
            this.student_store.load();
          }
        }
      },
      buttons: [{
        text:     "Submit",
        formBind: true,
        scope:    this,
        handler:  function(buttonEl, eventObj)
        {
          var form                     = buttonEl.ownerCt.ownerCt.get(0).getForm();
          var symptom_store            = form.ownerCt.get(0).get(1).get(1).getComponent("symptoms_list").getStore();
          var symptom_list             = jQuery.map(symptom_store.getRange(), function(e,i){ return e.data; });
          form.baseParams.symptom_list = Ext.encode(symptom_list);
          form.submit();
        }
      },{
        text:    'Cancel',
        width:   'auto',
        handler: function(buttonEl, eventObj)
        {
          buttonEl.ownerCt.ownerCt.close();
        }
      }]
    };

    if(argv.length != 0){
      window_config.items.method = "PUT";
      window_config.items.url   += '/'+student_record.id;
    }
    var win = new Ext.Window(window_config);

    win.show();
  },

  get_and_filter_by_student_number:function(this_field, evt)
  {
    this.student_list_store = this_field.ownerCt.ownerCt.ownerCt.ownerCt.get(2).getStore();
    var val                 = this_field.getValue();
    if(val.length == 3){
      Ext.Ajax.request({
        url:     '/rollcall/nurse_assistant/filter_by',
        method:  'POST',
        headers: {'Accept': 'application/json'},
        scope:   this,
        params:  {
          student_number: val
        },
        success: function(response, options)
        {
          var results = Ext.decode(response.responseText).results;
          this.student_list_store.loadData(results);
        }
      });
    }else if(val.length > 3){
      val = new RegExp(val, 'ig');
      symptom_list_store.filter([{property:'student_number', value: val}]);
    }
  }
});

Talho.Rollcall.NurseAssistant.initialize = function(config){
  var na = new Talho.Rollcall.NurseAssistant(config);
  return na.getPanel();
};

Talho.ScriptManager.reg('Talho.Rollcall.NurseAssistant', Talho.Rollcall.NurseAssistant, Talho.Rollcall.NurseAssistant.initialize);