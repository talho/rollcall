Ext.ns("Talho.Rollcall");

Talho.Rollcall.NurseAssistant = Ext.extend(function(){}, {
  constructor: function(config){
    this.init_store = new Ext.data.JsonStore({
      root:     'options',
      fields:   ['race', 'age', 'gender', 'grade', 'symptoms', 'zipcode', 'total_enrolled_alpha', 'app_init'],
      url:      '/rollcall/nurse_assistant_options',
      autoLoad: true,
      listeners:{
        scope: this,
        load:  function(this_store, records){}
      }
    });

    this.student_reader = new Ext.data.JsonReader({
      root:          'results',
      totalProperty: 'total_results',
      fields: [
        //{name:'id',                 type:'int'},
        //{name:'school_id',          type:'int'},
        {name:'first_name',         type:'string'},
        {name:'last_name',          type:'string'},
        //{name:'contact_first_name', type:'string'},
        //{name:'contact_last_name',  type:'string'},
        //{name:'address',            type:'string'},
        //{name:'zip',                type:'string'},

        //{name:'phone',              type:'string'},
        {name:'symptom',            type:'string'},
        {name:'treatment',          type:'string'},
        //{name:'created_at',         type:'date', dateFormat:'timestamp'},
        //{name:'updated_at',         type:'date', dateFormat:'timestamp'},
        {name:'report_date',        renderer: Ext.util.Format.dateRenderer('m-d-Y')},
        //{name:'report_month',       renderer: Ext.util.Format.dateRenderer('M')},
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
      listeners: {
        scope: this,
        'load':function(){
          this.getPanel().doLayout();
        }
      }
    });

    var main_panel = new Ext.Panel({
      title:    config.title,
      itemId:   config.id,
      layout:   'fit',
      closable: true,
      items:[{
        xtype: 'grid',
        title: 'Current Student Visits',
        frame: 'true',
        store: this.student_store,
        cm:    new Ext.grid.ColumnModel({
          columns: [
            {id:'first_name_column', header:'Student First Name', dataField:'first_name'},
            {id:'last_name_column',  header:'Student Last Name',  dataField:'last_name'},
            {id:'symptom_column',    header:'Symptoms',           dataField:'symptom'},
            {id:'header',            header:'Action',             dataField:'treatment'},
            {id:'visit_date',        header:'Visit Date',         dataField:'report_date'},
            {xtype:'xactioncolumn',  items:
              [{
                icon:'/stylesheets/images/pencil.png'},{
                icon:'/stylesheets/images/cross-circle.png'
              }]
            }
          ]
        }),
        autoExpandColumn: 'symptom_column',
        autoExpandMax:    5000,
        bbar:             new Ext.PagingToolbar({
          store: this.student_store,
          items: [
            {text: 'New', iconCls:'add_forum', handler: this.show_new_window, scope: this},
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
            style:{
              marginRight: '-4px'
            }
          }]
        }
      }]
    });

    this.getPanel = function(){ return main_panel;};

  },

  show_new_window:function(){
    var win = new Ext.Window({
      layout:'fit',
      title:'New Visit',
      width: 600,
      height: 425,
      scope: this,
      items:{
        xtype: 'form',
        layout: 'hbox',
        layoutConfig:{align:'stretch'},
        url: '/rollcall/nurse_assistant',
        border: false,
        method: 'POST',
        baseParams: {authenticity_token: FORM_AUTH_TOKEN, school_id: 1},
        items:[{
          xtype:'container',
          layout:'form',
          labelAlign:'top',
          flex:1,
          items:[
            {
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
                  width: 120
                }
              },
              items:[{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Student First Name',
                  id: 'first_name',
                  name: 'first_name'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Student Last Name',
                  id: 'last_name',
                  name: 'last_name'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Contact First Name',
                  id: 'contact_first_name'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Contact Last Name',
                  id: 'contact_last_name'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Address',
                  id: 'address'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Zip',
                  id: 'zip'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Phone Number',
                  id: 'phone'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'DOB',
                  id: 'dob'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Gender',
                  id: 'gender'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Race',
                  id: 'race'
                }
              },{
                items:{
                  xtype: 'textfield',
                  fieldLabel: 'Grade',
                  id: 'grade'
                }
              },{
                items:{
                  xtype:'textfield',
                  fieldLabel:'Temperature',
                  id: 'temperature'
                }
              },{
                items:{
                  fieldLabel:'Symptoms',
                  xtype:'combo',
                  store:['High Fever', 'Nausea', 'Headache', 'Extreme Headache'],
                  typeAhead: true,
                  mode:'local',
                  forceSelection:false,
                  id: 'symptoms'
                }
              }]
            }
          ]
        },{
          xtype: 'container',
          flex:1,
          layout:'form',
          labelAlign:'top',
          style:{
            paddingRight: '5'
          },
          items:[{
            xtype:'textarea',
            fieldLabel:'Action Taken',
            anchor:'100%'
          },{
            xtype:'container',
            anchor:'100% -55',
            layout:'border',
            items:[{
              region:'center',
              xtype:'grid',
              autoExpandColumn: 'symptom_column',
              emptyText:        '<div style="color:#000;">No symptom selected.</div>',
              store: new Ext.data.JsonStore({fields:['symptom'], data:[]}),
              cm: new Ext.grid.ColumnModel({
                columns:[{
                  id: 'symptom_column',
                  header:'Symptom',
                  dataField:'symptom'
                },{
                  xtype:'xactioncolumn',
                  icon:'/stylesheets/images/cross-circle.png'
                }]
              })
            }]
          }]
        }],
        listeners:{
          scope: this,
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
        scope: this,
        handler: function(buttonEl, eventObj)
        {
          buttonEl.ownerCt.ownerCt.get(0).getForm().submit();
        }
      },{
        text:    'Cancel',
        width:   'auto',
        handler: function(buttonEl, eventObj)
        {
          buttonEl.ownerCt.ownerCt.close();
        }
      }]
    });

    win.show();
  }
});

Talho.Rollcall.NurseAssistant.initialize = function(config){
  var na = new Talho.Rollcall.NurseAssistant(config);
  return na.getPanel();
};

Talho.ScriptManager.reg('Talho.Rollcall.NurseAssistant', Talho.Rollcall.NurseAssistant, Talho.Rollcall.NurseAssistant.initialize);