Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADSTResultPanel = Ext.extend(Ext.ux.Portal, {
  constructor: function(config){
    var leftColumn = new Ext.Container({
      columnWidth: .50,
      itemId: 'columnLeft',
      listeners:{
        scope: this
      }
    });

    var rightColumn = new Ext.Container({
      columnWidth: .50,
      id: 'columnRight',
      listeners:{
        scope: this
      }
    });

    Ext.applyIf(config,{
      hidden: true,
      id:     'ADSTResultPanel',
      itemId: 'portalId',
      items:[leftColumn, rightColumn],
      leftColumn: leftColumn,
      rightColumn: rightColumn
    });

    var result_store = new Ext.data.JsonStore({
      idProperty: 'id',
      totalProperty: 'total_results',
      root:   'results',
      fields: ['id', 'value'],
      listeners: {
        scope: this,
        'load': function(this_store, record){
          var item_id = null;
          var graphImageConfig = null;
          var result_obj = null;
          for(var i = 0; i < record.length; i++){
            item_id = 'query_result_'+i;
            graphImageConfig = {
              title: 'Query Result',
              style:'margin:5px',
              itemId: item_id,
              tools: [{
                id:'plus',
                qtip: 'Save Query',
                handler: function(e, targetEl, panel, tc){
                  this._showAlarmConsole();
                }
              },{
                id:'close',
                handler: function(e, target, panel){
                  panel.ownerCt.remove(panel, true);
                }
              }],
              height: 230,
              html: '<div style="text-align:center"><img src="/images/Ajax-loader.gif" /></div>'
            };

            if(i == 0 || i%2 == 0){
              result_obj = this.rightColumn.add(graphImageConfig);
            }else{
              result_obj = this.leftColumn.add(graphImageConfig);
            }
            this.leftColumn.doLayout();
            this.rightColumn.doLayout();
            this.renderGraphs(record[i].data.value, result_obj);
          }
        }
      }
    });
    this.getStore = function(){
      return result_store;
    }

    Talho.Rollcall.ADSTResultPanel.superclass.constructor.call(this, config);
  },

  processQuery: function(json_result)
  {
    this.getStore().loadData(json_result);
  },

  _showAlarmConsole: function()
  {
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
  renderGraphs: function(image, obj) {
    Ext.Ajax.request({
      url: image,
      scope: this,
      success: function(){
        obj.add({html:'<div style="text-align:center"><img src="'+image+'" /></div>'});
        this.leftColumn.doLayout();
        this.rightColumn.doLayout();
      },
      failure: function(result, opts){
        Ext.Ajax.request(opts);
      },
      headers: {
        'type': 'HEAD'
      }
    });
  }
});
