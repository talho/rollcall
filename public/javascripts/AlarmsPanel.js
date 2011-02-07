Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.AlarmsPanel = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config,{
      id: 'alarm_panel',
      itemId: 'alarm_panel',
      alarm_store: new Ext.data.JsonStore({
        autoLoad: true,
        root:   'results',
        fields: ['id', 'alarms'],
        proxy: new Ext.data.HttpProxy({
          url: '/rollcall/alarms',
          method:'get'
        }),
        listeners:{
          scope: this,
          load: function(this_store, record){
            var alarm_name      = "";
            var alarms_query_id = null;
            var result_obj      = null;
            var alarms_data     = null;

            var tmpl = new Ext.XTemplate(
              '<tpl for=".">',
                '<div class="thumb-wrap">',
                  '<div class="alarm {alarm_severity}">',
                    '<div>',
                      '<b>Report Date:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b><span>{report_date}</span>',
                    '</div>',
                    '<div>',
                      '<b>Absentee Rate: </b><span>{absentee_rate}%</span>',
                    '</div>',
                    '<div>',
                      '<b>Deviation Rate: </b><span>{deviation}%</span>',
                    '</div>',
                  '</div>',
                '</div>',
              '</tpl>',
              '<div class="x-clear"></div>'
            );
            if(record[0].data.alarms.length == 0){
              if(this.items.length == 0){
                //if(typeof(this_store.alarm_icon_el) == "undefined"){
                  this.add({
                    bodyStyle: 'padding: 5 0 0 5',
                    itemId: 'empty_alarms_container',
                    title:'There are currently no alarms.',
                    autoScroll:true,
                    border:false,
                    iconCls:'rollcall_alarm_icon'
                  });
                //}
                if(typeof(this_store.alarm_icon_el) != "undefined") {
                  this_store.alarm_icon_el.toggleClass('x-tool-alarm-off');
                  this_store.alarm_icon_el.toggleClass('x-tool-alarm-on');
                }
              }
            }else{
              if(record[0].data.alarms.length != 0){
                if(this.getComponent('empty_alarms_container')){
                  this.getComponent('empty_alarms_container').destroy();
                }
                for(var i=0;i<record[0].data.alarms.length;i++){
                  alarms_data = {
                    alarms: []
                  };
                  var alarms_store = new Ext.data.JsonStore({
                    root: 'alarms',
                    autoLoad: false,
                    fields: [
                      {name:'absentee_rate',  type:'float'},
                      {name:'deviation',      type:'float'},
                      {name:'id',             type:'int'},
                      {name:'report_date',    renderer: Ext.util.Format.dateRenderer('m-d-Y')},
                      {name:'saved_query_id', type:'int'},
                      {name:'school_id',      type:'int'},
                      {name:'school_name',    type:'string'},
                      {name:'alarm_name',     type:'string'},
                      {name:'severity',       type:'float'},
                      {name:'alarm_severity', type:'string'},
                      {name:'created_at',     type:'date', dateFormat:'timestamp'},
                      {name:'updated_at',     type:'date', dateFormat:'timestamp'}
                    ]
                  });
                  result_obj = this.add(new Ext.grid.GridPanel({
                    store: alarms_store,
                    hideHeaders: true,
                    columns: [
                      {
                        xtype: 'templatecolumn',
                        id:'alarm_name',
                        header: 'Alarm Name',
                        sortable: true,
                        dataIndex: 'alarm_name',
                        tpl: tmpl
                      }
                    ],
                    stripeRows: true,
                    autoExpandColumn: 'alarm_name',
                    stateful: true,
                    stateId: 'grid',
                    iconCls: 'rollcall_alarm_icon'
                  }));

                  for(var cnt=0;cnt<record[0].data.alarms[i].length;cnt++){
                    if(alarms_query_id != record[0].data.alarms[i][cnt].alarm.saved_query_id){
                      alarms_query_id = record[0].data.alarms[i][cnt].alarm.saved_query_id;
                      result_obj.setTitle(record[0].data.alarms[i][cnt].alarm.alarm_name);
                    }
                    alarms_data.alarms.push(record[0].data.alarms[i][cnt].alarm);
                  }
                  alarms_store.loadData(alarms_data);
                  result_obj.doLayout();
                }
                if(typeof(this_store.alarm_icon_el) != "undefined") {
                  this_store.alarm_icon_el.toggleClass('x-tool-alarm-off');
                  this_store.alarm_icon_el.toggleClass('x-tool-alarm-on');
                }
              }
            }
            this.doLayout();
          }
        }
      }),
      layout:'accordion',
      layoutConfig:{
        animate:true
      }
    });
    Talho.Rollcall.AlarmsPanel.superclass.constructor.call(this, config);
  }
});