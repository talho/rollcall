Ext.namespace('TALHO');

Talho.RollcallQuery = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    Talho.RollcallQuery.superclass.constructor.call(this, config);

    var panel = new Ext.Panel({
      title: config.title,
      itemId: config.id,
      closable: true,
      autoScroll:true,
      layout:'border',
      defaults: {
        collapsible: true,
        split: true,
        bodyStyle: 'padding:15px'
      },
      items: [{
        title: 'Saved Queries',
        region: 'south',
        height: 150,
        minSize: 75,
        maxSize: 250,
        cmargins: '5 0 0 0',
//        defaults:{
//          style: {
//            marginLeft: '10px'
//          }
//        },
        items:[{
          xtype: 'portal',
          itemId: 'portalId_south',
          border: false,
          items:[{
            columnWidth: .25,
            listeners:{
              scope: this
            },
            items:[{
              title: 'Saved Query(1)',
              style:{
                marginRight: '5px',
                top: '-5px'
              },
              autoWidth: true,
              autoHeight: true,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
            }]
          },{
            columnWidth: .25,
            listeners:{
              scope: this
            },
            items:[{
              title: 'Saved Query(2)',
              style:{
                marginRight: '5px',
                top: '-5px'
              },
              autoWidth: true,
              autoHeight: true,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism_berry.png" /></div>'
            }]
          },{
            columnWidth: .25,
            listeners:{
              scope: this
            },
            items:[{
              title: 'Saved Query(3)',
              style:{
                marginRight: '5px',
                top: '-5px'
              },
              autoWidth: true,
              autoHeight: true,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism_lewis.png" /></div>'
            }]
          },{
            columnWidth: .25,
            listeners:{
              scope: this
            },
            items:[{
              title: 'Saved Query(4)',
              style:{
                marginRight: '5px',
                top: '-5px'
              },
              autoWidth: true,
              autoHeight: true,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism_south.png" /></div>'
            }]
          }]
        }]
      },{
        title: 'Reports',
        region:'east',
        margins: '5 0 0 0',
        cmargins: '5 5 0 0',
        width: 200,
        minSize: 175,
        maxSize: 400,
        split:true,
        collapsible: true,
        bodyStyle: 'padding:0px',
        layout:'fit',
        autoScroll:true,
        items: this.buildReportPanel()     
      },{
        title: 'Alarms',
        region:'west',
        margins: '5 0 0 0',
        cmargins: '5 5 0 0',
        width: 200,
        minSize: 175,
        maxSize: 400,
        split:true,
        collapsible: true,
        bodyStyle: 'padding:0px',
        layout:'accordion',
        layoutConfig:{
          animate:true
        },
        items: [{
          bodyStyle: 'padding: 5 0 0 5',
          html: '<div>' +
                '<a class="school_name">CEP Southeast</a>&nbsp;'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<ul class="school_alerts" style="border:none">'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<span>10/12</span> - <span class="absence">14.69%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<span>10/08</span> - <span class="absence">14.98%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<span>10/07</span> - <span class="absence">12.61%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<span>10/06</span> - <span class="absence">11.93%</span></li>'+
                '</ul><span class="more"><a href="/schools/39">More info...</a></span>'+
                '</div>'+'<br/>'+
                '<div>' +
                '<a class="school_name">Hope Academy Charter</a>&nbsp;'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<ul class="school_alerts" style="border:none">'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<span>10/12</span> - <span class="absence">14.69%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_severe">'+
                '<span>10/08</span> - <span class="absence">10.98%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<span>10/07</span> - <span class="absence">12.61%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<span>10/06</span> - <span class="absence">11.93%</span></li>'+
                '</ul><span class="more"><a href="/schools/39">More info...</a></span>'+
                '</div>',
          title:'Alarm Title(1)',
          autoScroll:true,
          border:false,
          iconCls:'rollcall_alarm_icon'
        },{
          title:'Alarm Title(2)',
          html: 'some html mark up goes here',
          border:false,
          autoScroll:true,
          html: '<div>' +
                '<a class="school_name">Osborne Elementary</a>'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<ul class="school_alerts" style="border:none">'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<span>10/12</span> - <span class="absence">14.69%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<span>10/06</span> - <span class="absence">11.93%</span></li>'+
                '</ul><span class="more"><a href="/schools/39">More info...</a></span>'+
                '</div>'+
                '<div>' +
                '<a class="school_name">Reach Charter</a>'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
                '<ul class="school_alerts" style="border:none">'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
                '<span>10/12</span> - <span class="absence">14.69%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_severe">'+
                '<span>10/08</span> - <span class="absence">10.98%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_extreme.png" class="severity" alt="Status_moderate">'+
                '<span>10/07</span> - <span class="absence">31.61%</span></li>'+
                '<li class="school_alert">'+
                '<img src="/stylesheets/images/status_extreme.png" class="severity" alt="Status_moderate">'+
                '<span>10/06</span> - <span class="absence">32.93%</span></li>'+
                '</ul><span class="more"><a href="/schools/39">More info...</a></span>'+
                '</div>',
          iconCls:'rollcall_alarm_icon'
        },{
          title:'Alarm Title(3)',
          html: 'some html mark up goes here',
          border:false,
          autoScroll:true,
          iconCls:'rollcall_alarm_icon'
        },{
          title:'Alarm Title(4)',
          html: 'some html mark up goes here',
          border:false,
          autoScroll:true,
          iconCls:'rollcall_alarm_icon'
        }]
      },{
        listeners:{ scope: this},
        title: 'Search',
        itemId: 'search_panel',
        collapsible: false,
        region:'center',
        margins: '5 0 0 0',
        autoScroll:true,
        items:[{
          xtype: 'container',
          itemId: 'query_container',
          layout: 'column',
          items:[{
            xtype: 'form',
            columnWidth: 1,
            collapsible: false,
            labelAlign: 'top',
            title: "Simple Query Select",
            itemId: "simple_query_select",
            padding: '0 0 5 5',
            style: "padding-right: 5px",
            url:'',
            buttonAlign: 'left',
            buttons: [{
              text: "Submit",
              scope: this,
              handler: function(buttonEl, eventObj){
                this.showPortal();
              },
              formBind: true
            },{
              text: "Cancel",
              handler: this.clearForm
            }],
            items: [{
              xtype: 'container',
              layout: 'hbox',
              lazyRender: true,
              items:[{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  fieldLabel: 'Absenteeism',
                  mode: 'local', 
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Gross',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'absentId',
                      'absenteeism'
                    ],
                    data: [[1, 'Gross'], [2, 'Confirmed Illness']]
                  }),
                  valueField: 'absentId',
                  displayField: 'absenteeism'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'School',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select School...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'schoolId',
                      'school'
                    ],
                    data: [
                      [1, 'Bellaire High School'], [2, 'Berry Elementary'],[3,'Lewis Elementary'],
                      [4, 'Southmayd Elementary'], [5, 'Woodson Middle School']
                    ]
                  }),
                  valueField: 'schoolId',
                  displayField: 'school'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                //flex: 1,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'School Type',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select School Type...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'schoolTypeId',
                      'schoolType'
                    ],
                    data: [[1, 'Elementary'], [2, 'High School']]
                  }),
                  valueField: 'schoolTypeId',
                  displayField: 'schoolType'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'checkbox',
                  width: 75,
                  boxLabel: "Include",
                  name: "include_school",
                  id: "include_school"
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  fieldLabel: 'Start Date',
                  name: 'startdt',
                  id: 'startdt',
                  xtype: 'datefield',
                  width: 182,
                  endDateField: 'enddt', // id of the end date field
                  emptyText:'Select Start Date...',
                  selectOnFocus:true
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  fieldLabel: 'End Date',
                  name: 'enddt',
                  id: 'enddt',
                  xtype: 'datefield',
                  width: 182,
                  startDateField: 'startdt', // id of the start date field
                  emptyText:'Select End Date...',
                  selectOnFocus:true
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'Data Function',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Raw',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'dataFunctionId',
                      'dataFunction'
                    ],
                    data: [
                      [1,'Raw'], [2,'Average'], [3, 'Moving Average 30 Day'], [4,'Moving Average 60 Day'],
                      [5, 'Standard Deviation'], [6, 'Cusum']
                    ]
                  }),
                  valueField: 'dataFunctionId',
                  displayField: 'dataFunction'
                }]
              }]
            },{
              xtype: 'container',
              layout: 'auto',
              lazyRender: true,
              items:[{
                xtype: 'button',
                text: "Switch to Advanced Search >>",
                style:{
                  marginLeft: '10px'
                },
                scope: this,
                handler: function(buttonEl, eventObj){
                  this.getQueryContainer().getComponent('simple_query_select').hide();
                  this.getQueryContainer().getComponent('advanced_query_select').show();
                }
              }]
            }]
          },{
            xtype: 'form',
            columnWidth: 1,
            labelAlign: 'top',
            title: "Advanced Query Select",
            itemId: "advanced_query_select",
            hidden: true,
            hideMode: "display",
            padding: '0 0 5 5',
            style: "padding-left: 5px",
            url:'',
            buttonAlign: 'left',
            buttons: [{
              text: "Submit",
              scope: this,
              handler: function(buttonEl, eventObj){
                this.showPortal();
              },
              formBind: true
            },{
              text: "Cancel",
              handler: this.clearForm
            }],
            items: [{
              xtype: 'container',
              layout: 'hbox',
              lazyRender: true,
              items:[{
                xtype: 'fieldset',
                border: false,
                align: 'middle',
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  fieldLabel: 'Absenteeism',
                  mode: 'local',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Gross',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'absentId_adv',
                      'absenteeism_adv'
                    ],
                    data: [[1, 'Gross'], [2, 'Confirmed Illness']]
                  }),
                  valueField: 'absentId_adv',
                  displayField: 'absenteeism_adv'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  fieldLabel: 'Age',
                  mode: 'local',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select Age...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'ageId',
                      'age'
                    ],
                    data: [[1, '3-4'], [2, '5-6'],[3, '7-8'],[4, '9-10'],[5, '11-12'],[6,'13-14'],[7,'15-16'],[8,'17-18']]
                  }),
                  valueField: 'ageId',
                  displayField: 'age'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  fieldLabel: 'Gender',
                  mode: 'local',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select Gender...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'genderId',
                      'gender'
                    ],
                    data: [[1, 'Male'], [2, 'Female']]
                  }),
                  valueField: 'genderId',
                  displayField: 'gender'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  fieldLabel: 'Grade',
                  mode: 'local',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select Grade...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'gradeId',
                      'grade'
                    ],
                    data: [
                      [1, 'Kindergarden'], [2, '1st Grade'], [3, '2nd Grade'], [4, '3rd Grade'], [5, '4th Grade'],
                      [6, '5th Grade'], [7, '6th Grade'],[8, '7th Grade'],[9,'8th Grade'],[10,'9th Grade'],
                      [11,'10th Grade'],[12,'11th Grade'],[13,'12th Grade']
                    ]
                  }),
                  valueField: 'gradeId',
                  displayField: 'grade'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'School',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select School...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'schoolId_adv',
                      'school_adv'
                    ],
                    data: [
                      [1, 'Bellaire High School'], [2, 'Berry Elementary'],[3,'Lewis Elementary'],
                      [4, 'Southmayd Elementary'], [5, 'Woodson Middle School']
                    ]
                  }),
                  valueField: 'schoolId_adv',
                  displayField: 'school_adv'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'School Type',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select School Type...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'schoolTypeId_adv',
                      'schoolType_adv'
                    ],
                    data: [[1, 'Elementary'], [2, 'High School']]
                  }),
                  valueField: 'schoolTypeId_adv',
                  displayField: 'schoolType_adv'
                }]
              }]
            },{
              xtype: 'container',
              layout: 'hbox',
              lazyRender: true,
              items:[{
                xtype: 'fieldset',
                border: false,
                items:[{
                  fieldLabel: 'Start Date',
                  name: 'startdt_adv',
                  id: 'startdt_adv',
                  xtype: 'datefield',
                  width: 182,
                  endDateField: 'enddt_adv', // id of the end date field
                  emptyText:'Select Start Date...',
                  selectOnFocus:true
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  fieldLabel: 'End Date',
                  name: 'enddt_adv',
                  id: 'enddt_adv',
                  xtype: 'datefield',
                  width: 182,
                  startDateField: 'startdt_adv', // id of the start date field
                  emptyText:'Select End Date',
                  selectOnFocus:true
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'Symptoms',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select Symptoms...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'symptomsId',
                      'symptoms'
                    ],
                    data: [[1,'High Fever'],[2, 'Nausea'],[3, 'Headache'],[4, 'Extreme Headache']]
                  }),
                  valueField: 'symptomsId',
                  displayField: 'symptoms'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'Temperature',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select Temperature...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'temperatureId',
                      'temperature'
                    ],
                    data: [
                      [1,'98 - 99'],[2, '100'],[3, '101'],[4, '102'],[5, '103'],
                      [6, '104'],[7,'105'],[8,'106'],[9,'107'],[10,'108']
                    ]
                  }),
                  valueField: 'temperatureId',
                  displayField: 'temperature'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'Zipcode',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Select Zipcode...',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'zipcodeId',
                      'zipcode'
                    ],
                    data: [[1,'77007'],[2, '77001'],[3, '77559'],[4, '77076']]
                  }),
                  valueField: 'zipcodeId',
                  displayField: 'zipcode'
                }]
              },{
                xtype: 'fieldset',
                border: false,
                items:[{
                  xtype: 'combo',
                  typeAhead: true,
                  triggerAction: 'all',
                  mode: 'local',
                  fieldLabel: 'Data Function',
                  lazyRender: true,
                  autoSelect: true,
                  emptyText:'Raw',
                  selectOnFocus:true,
                  store: new Ext.data.ArrayStore({
                    id: 0,
                    fields: [
                      'dataFunctionId_adv',
                      'dataFunction_adv'
                    ],
                    data: [
                      [1,'Raw'], [2,'Average'], [3, 'Moving Average 30 Day'], [4,'Moving Average 60 Day'],
                      [5, 'Standard Deviation'], [6, 'Cusum']
                    ]
                  }),
                  valueField: 'dataFunctionId_adv',
                  displayField: 'dataFunction_adv'
                }]
              }]  
            },{
              xtype: 'container',
              layout: 'auto',
              lazyRender: true,
              items:[{
                xtype: 'button',
                text: "Switch to Simple Search >>",
                style:{
                  marginLeft: '10px'
                },
                scope: this,
                handler: function(buttonEl, eventObj){
                  this.getQueryContainer().getComponent('advanced_query_select').hide();
                  this.getQueryContainer().getComponent('simple_query_select').show();
                }
              }]
            }]
          }]
        },
        {
          xtype: 'portal',
          hidden: true,
          itemId: 'portalId',
          items:[{
            columnWidth: .50,
            listeners:{
              scope: this
            },
            items:[{
              title: 'Query Result(1)',
              style:'margin:5px',
              tools: this.buildTools(),
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
            },
            {
              title: 'Query Result(2)',
              style:'margin:5px',
              tools: this.buildTools(),
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism_berry.png" /></div>'
            },
            {
              title: 'Query Result(5)',
              style:'margin:5px',
              tools: this.buildTools(),
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism_woodson.png" /></div>'
            }]
          },
          {
            columnWidth: .50,
            listeners:{
              scope: this
            },
            items:[{
              title: 'Query Result(3)',
              style:'margin:5px',
              tools: this.buildTools(),
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism_lewis.png" /></div>'
            },
            {
              title: 'Query Result(4)',
              style:'margin:5px',
              tools: this.buildTools(),
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism_south.png" /></div>'
            }]
          }]
        }]
      }]  
    });

    this.getPanel = function(){ return panel; }
    this.getQueryContainer = function(){
      return panel.getComponent('search_panel').getComponent('query_container');
    }
    this.showPortal = function(){
      panel.getComponent('search_panel').getComponent('portalId').show();
      panel.doLayout();
    }
  },
  showAlarmConsole: function(){
    /*
    * Setting up mock data for presentation.  This code might be useful
    * in constructing the app.
    * */
    var myStore = new Ext.data.ArrayStore({
        storeId: 'my-store',
        fields: ['field', 'value'],
        idIndex: 0
    });
    var myData = [
        ['Absenteeism', 'Confirmed Illness'],
        ['School Type', 'Elementary']
    ];
    myStore.loadData(myData);

    /*
    * Creating Ext Component Window.  Mocking up
    * alarm console
    * */
    var alarm_console = new Ext.Window({
      layout:'fit',
      autoWidth:true,
      autoHeight:true,
      closeAction:'hide',
      title: 'Set Alarm for Query Result(1)',
      plain: true,
      items: [{
        xtype: 'form',
        border:false,
        items:[{
          xtype:'textfield',
          labelStyle:'margin: 10px 0px 0px 5px',
          fieldLabel: 'Alarm Name',
          width: 195,
          style:{
            marginTop: '10px',
            marginBottom: '5px'
          }
        },{
          xtype: 'fieldset',
          width : 300,
          autoHeight: true,
          title : 'Deviation',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          defaultType: 'sliderfield',
          buttonAlign: 'left',
          defaults: {
              anchor: '95%',
              tipText: function(thumb){
                  return String(thumb.value) + '%';
              }
          },
          items: [{
              fieldLabel: 'Threshold',
              value: 50,
              name: 'th'
          },{
              fieldLabel: 'Min',
              value: 80,
              name: 'min'
          },{
              fieldLabel: 'Max',
              value: 25,
              name: 'max'
          }],
          fbar: {
              xtype: 'toolbar',
              items: ['->', {
                  text: 'Max All',
                  handler: function(){
                      form.items.each(function(c){
                          c.setValue(100);
                      });
                  }
              },{
                  text: 'Reset',
                  handler: function(){
                      form.getForm().reset();
                  }
              }]
          }
        },{
          xtype: 'fieldset',
          width : 300,
          autoHeight: true,
          title : 'Severity',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          defaultType: 'sliderfield',
          buttonAlign: 'left',
          defaults: {
              anchor: '95%',
              tipText: function(thumb){
                  return String(thumb.value) + '%';
              }
          },
          items: [{
              fieldLabel: 'Min',
              value: 80,
              name: 'min'
          },{
              fieldLabel: 'Max',
              value: 25,
              name: 'max'
          }],
          fbar: {
              xtype: 'toolbar',
              items: ['->', {
                  text: 'Max All',
                  handler: function(){
                      form.items.each(function(c){
                          c.setValue(100);
                      });
                  }
              },{
                  text: 'Reset',
                  handler: function(){
                      form.getForm().reset();
                  }
              }]
          }
        },{
          xtype: 'fieldset',
          autoWidth : true,
          autoHeight: true,
          title : 'Parameters',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          collapsible: true,
          items: [{
            xtype: 'listview',
            store: myStore,
            multiSelect: true,
            reserveScrollOffset: true,
            columns: [{
                header: 'Field Name',
                width: .65,
                dataIndex: 'field'
            },{
                header: 'Value Set',
                width: .35,
                dataIndex: 'value'
            }]
          }]
        }]
      }],
      buttons: [{
        text:'Submit',
        disabled:true
      },{
        text: 'Close',
        handler: function(){
          alarm_console.hide();
        }
      }]
    });
    alarm_console.show();
  },
  buildTools: function(){
    /*
    * Creating Ext Elements for tools attribute in panels
    * */
    var tools = [{
        id:'plus',
        qtip: 'Save Query',
        scope: this,
        handler: function(e, targetEl, panel, tc){
          this.showAlarmConsole();
        }
    },{
        id:'close',
        handler: function(e, target, panel){
            panel.ownerCt.remove(panel, true);
        }
    }];
    return tools;
  },
  buildReportPanel: function(){
    // sample static data for the store
    var myData = [
        ['Bellaire High School'],
        ['Berry Elementary'],
        ['Lewis Elementary'],
        ['Southmayd Elementary'],
        ['Woodson Middle School']
    ];
    // create the data store
    var store = new Ext.data.ArrayStore({
        fields: [
           {name: 'school'}
        ]
    });

    // manually load local data
    store.loadData(myData);

    // create the Grid
    var grid = new Ext.grid.GridPanel({
        store: store,
        columns: [
            {
              id       :'school',
              header   : 'School',
              width    : 160,
              sortable : true,
              dataIndex: 'school'
            },
            {
              xtype: 'actioncolumn',
              width: 50,
              items: [{
                iconCls: 'rollcall_pdf_icon', 
                tooltip: 'Download Report',
                handler: function(grid, rowIndex, colIndex) {
                    var rec = store.getAt(rowIndex);
                    alert("Download " + rec.get('school') + " PDF");
                }
              }]
            }
        ],
        stripeRows: true,
        autoExpandColumn: 'school',
        autoHeight: true,
        autoWidth: true,
        // config options for stateful behavior
        stateful: true,
        stateId: 'grid'
    });
    return grid;
  },
  submitQuery: function(b, e){
    return false;
  },
  cancelForm: function(b,e){
    return false;
  },
  resizeGraphs: function(){
    return false;  
  }
});

Talho.RollcallQuery.initialize = function(config){
  var query = new Talho.RollcallQuery(config);
  return query.getPanel();
}

Talho.ScriptManager.reg('Talho.RollcallQuery', Talho.RollcallQuery, Talho.RollcallQuery.initialize);