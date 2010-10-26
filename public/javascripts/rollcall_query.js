Ext.namespace('TALHO');

Talho.RollcallQuery = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    Talho.RollcallQuery.superclass.constructor.call(this, config);

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

    /*
    * Creating Ext Elements for tools attribute in panels
    * */
    var tools = [{
        id:'plus',
        qtip: 'Save Query',
        scope: this,
        handler: function(e, targetEl, panel, tc){
          alarm_console.show();
        }
    },{
        id:'close',
        handler: function(e, target, panel){
            panel.ownerCt.remove(panel, true);
        }
    }];

    /*
    * Creating the main Rollcall "search" panel. Mocking up display data.
    * */
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
        title: 'Alarms',
        region: 'south',
        height: 150,
        minSize: 75,
        maxSize: 250,
        cmargins: '5 0 0 0',
        defaults:{
          style: {
            marginLeft: '10px'
          }
        },
        items:[{
          xtype: 'box',
          autoEl:{
            tag: "img",
            src: "/images/school_absenteeism.png"
          },
          width: 250,
          height: 100
        },{
          xtype: 'box',
          autoEl:{
            tag: "img",
            src: "/images/school_absenteeism.png"
          },
          width: 250,
          height: 100
        },{
          xtype: 'box',
          autoEl:{
            tag: "img",
            src: "/images/school_absenteeism.png"
          },
          width: 250,
          height: 100
        }]
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
        collapsible: false,
        region:'center',
        margins: '5 0 0 0',
        autoScroll:true,
        items:[{
          xtype: 'container',
          layout: 'column',
          items:[{
            xtype: 'form',
            columnWidth: .5,
            collapsible: false,
            labelAlign: 'top',
            title: "Simple Query Select",
            padding: '0 0 5 5',
            style: "padding-right: 5px",
            url:'',
            buttonAlign: 'left',
            buttons: [{
              text: "Submit",
              handler: this.submitQuery,
              formBind: true
            },{
              text: "Cancel",
              handler: this.clearForm
            }],
            items: [{
              xtype: 'container',
              layout: 'ux.hblreduex',
              fieldLabel: 'School Type',
              lazyRender: true,
              items:[{
                xtype: 'combo',
                typeAhead: true,
                triggerAction: 'all',
                mode: 'local',
                fieldLabel: 'Absenteeism',
                lazyRender: true,
                autoSelect: true,
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
              },{
                xtype: 'combo',
                typeAhead: true,
                triggerAction: 'all',
                mode: 'local',
                store: new Ext.data.ArrayStore({
                  id: 0,
                  fields: [
                    'schoolId',
                    'schoolType'
                  ],
                  data: [[1, 'Elementary'], [2, 'High School']]
                }),
                valueField: 'schoolId',
                displayField: 'schoolType'
              },
              {
                xtype: 'checkbox',
                width: 75,
                boxLabel: "Include",
                name: "include_school",
                id: "include_school"
              }]
            },{
              fieldLabel: 'Start Date',
        name: 'startdt',
        id: 'startdt',
        xtype: 'datefield',
        endDateField: 'enddt' // id of the end date field
      },{
        fieldLabel: 'End Date',
        name: 'enddt',
        id: 'enddt',
        xtype: 'datefield',
        startDateField: 'startdt' // id of the start date field
      }
//            {
//              xtype: 'combo',
//              typeAhead: true,
//              triggerAction: 'all',
//              fieldLabel: 'Data Function',
//              lazyRender: true,
//              autoSelect: true,
//              mode: 'local',
//              store: new Ext.data.ArrayStore({
//                id: 0,
//                fields: [
//                  'dataId',
//                  'dataFunction'
//                ],
//                data: [[1, 'Raw'], [2, 'Average']]
//              }),
//              valueField: 'dataId',
//              displayField: 'dataFunction'
//            }
             ]
          },{
            xtype: 'form',
            columnWidth: .5,
            labelAlign: 'top',
            collapsed: true,
            collapsible: true,
            title: "Advanced Query Select",
            padding: '0 0 5 5',
            style: "padding-left: 5px",
            url:'',
            items: [{
              xtype: 'container',
              layout: 'ux.hblreduex',
              fieldLabel: 'School Type',
              lazyRender: true,
              items:[{
                xtype: 'combo',
                typeAhead: true,
                triggerAction: 'all',
                mode: 'local',
                fieldLabel: 'Absenteeism',
                lazyRender: true,
                autoSelect: true,
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
              },{
                xtype: 'combo',
                typeAhead: true,
                triggerAction: 'all',
                mode: 'local',
                store: new Ext.data.ArrayStore({
                  id: 0,
                  fields: [
                    'schoolId',
                    'schoolType'
                  ],
                  data: [[1, 'Elementary'], [2, 'High School']]
                }),
                valueField: 'schoolId',
                displayField: 'schoolType'
              },
              {
                xtype: 'checkbox',
                width: 75,
                boxLabel: "Include",
                name: "include_school",
                id: "include_school"
              }]
            },
            {
              xtype: 'combo',
              typeAhead: true,
              triggerAction: 'all',
              fieldLabel: 'Data Function',
              lazyRender: true,
              autoSelect: true,
              mode: 'local',
              store: new Ext.data.ArrayStore({
                id: 0,
                fields: [
                  'dataId',
                  'dataFunction'
                ],
                data: [[1, 'Raw'], [2, 'Average']]
              }),
              valueField: 'dataId',
              displayField: 'dataFunction'
            }]
          }]
        },
        {
          xtype: 'portal',
          items:[{
            columnWidth: .50,
            listeners:{
              scope: this
            },
            items:[{
              title: 'Query Result(1)',
              style:'margin:5px',
              tools: tools,
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
            },
            {
              title: 'Query Result(2)',
              style:'margin:5px',
              tools: tools,
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
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
              tools: tools,
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
            },
            {
              title: 'Query Result(4)',
              style:'margin:5px',
              tools: tools,
              height: 230,
              html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
            }]
          }]
        }]
      }]  
    });
    this.getPanel = function(){ return panel; }
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