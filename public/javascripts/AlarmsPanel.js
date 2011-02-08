Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.AlarmsPanel = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config,{
      id: 'alarm_panel',
      itemId: 'alarm_panel',
      alarm_store: new Ext.data.JsonStore({
        autoDestroy: true,
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
                this.add({
                  bodyStyle: 'padding: 5 0 0 5',
                  itemId: 'empty_alarms_container',
                  title:'There are currently no alarms.',
                  autoScroll:true,
                  border:false,
                  iconCls:'rollcall_alarm_icon'
                });
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
                    autoDestroy: true,
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
                    iconCls: 'rollcall_alarm_icon',
                    tip_array: [],
                    listeners:{
                      rowclick: function(this_grid, index, event_obj){
                        record = this_grid.getStore().getAt(index);
                        if(this_grid.tip_array.length != 0) this_grid.tip_array.pop().destroy();
                        var tip = new Ext.Tip({
                          title: 'Alarm Information for '+ record.json.school_name,
                          closable: true,
                          cls: 'alarm-tip',
                          layout:'fit',
                          data: [1],
                          tpl: new Ext.XTemplate(
                            '<div class="all-purpose-load-icon"></div>',
                            '<div class="x-tip-anchor x-tip-anchor-left x-tip-anchor-adjust"></div>'
                          )
                        });
                        this_grid.tip_array.push(tip);
                        tip.showBy(this_grid.getView().getRow(index), 'tl-tr');

                        Ext.Ajax.request({
                          url: 'rollcall/get_info',
                          method: 'POST',
                          headers: {'Accept': 'application/json'},
                          params:{
                            school_id: record.json.school_id,
                            report_date: record.json.report_date,
                            alarm_id: record.json.id,
                            saved_query_id: record.json.saved_query_id
                          },
                          success: function(response, options){                          
                            jsonObj = response.responseText.replace(/"alarm_severity"/g, 'alarm_severity');
                            jsonObj = jsonObj.replace(/"info"/g, 'info');
                            jsonObj = jsonObj.replace(/"total_confirmed_absent"/g, 'total_confirmed_absent');
                            jsonObj = jsonObj.replace(/"total_absent"/g, 'total_absent');
                            jsonObj = jsonObj.replace(/"total_enrolled"/g, 'total_enrolled');
                            jsonObj = eval(jsonObj);
                            var template = new Ext.XTemplate(
                                '<tpl for=".">',
                                  '<table class="alarm-tip-table">',
                                    '<tr>',
                                      '<td><b>Severity:</b></td>',
                                      '<td><span>{alarm_severity}</span></td>',
                                    '</tr>',
                                    '<tr>',
                                      '<td><b>Total Absent:</b></td>',
                                      '<td><span>{total_absent}</span></td>',
                                    '</tr>',
                                    '<tr>',
                                      '<td><b>Total Confirmed Absent:</b></td>',
                                      '<td><span>{total_confirmed_absent}</span></td>',
                                    '</tr>',
                                    '<tr>',
                                      '<td><b>Total Enrolled:</b></td>',
                                      '<td><span>{total_enrolled}</span></td>',
                                    '</tr>',
                                  '</table>',
                                '</tpl>',
                                '<div class="x-tip-anchor x-tip-anchor-left x-tip-anchor-adjust"></div>'
                              );

                            if(this_grid.tip_array.length != 0) this_grid.tip_array.pop().destroy();
                            tip = new Ext.Tip({
                              title: 'Alarm Information for '+ record.json.school_name,
                              closable: true,
                              cls: 'alarm-tip',
                              layout:'fit',
                              items: [template,new Ext.grid.GridPanel({
                                forceLayout: true,
                                viewConfig: {
                                  forceFit: true
                                },
                                store: new Ext.data.JsonStore({
                                  autoDestroy: true,
                                  data: jsonObj[0].students,
                                  root: 'student_info',
                                  fields: [
                                    {name:'id',                type:'int'},
                                    {name:'school_name',       type:'int'},
                                    {name:'report_date',       renderer: Ext.util.Format.dateRenderer('m-d-Y')},
                                    {name:'age',               type:'int'},
                                    {name:'dob',               renderer: Ext.util.Format.dateRenderer('m-d-Y')},
                                    {name:'gender',            type:'boolean'},
                                    {name:'grade',             type:'int'},
                                    {name:'confirmed_illness', type:'boolean'}
                                  ]
                                }),
                                columns: [
                                  {header: 'Age',       sortable: true,  dataIndex: 'age'},
                                  {header: 'DOB',       sortable: true,  dataIndex: 'dob'},
                                  {header: 'Gender',    sortable: true,  dataIndex: 'gender'},
                                  {header: 'Grade',     sortable: true,  dataIndex: 'grade'},
                                  {header: 'Confirmed', sortable: true,  dataIndex: 'confirmed_illness'}
                                ],
                                stripeRows: true,
                                stateful: true
                              })]
                            });
                            this_grid.tip_array.push(tip);
                            tip.showBy(this_grid.getView().getRow(index), 'tl-tr');
                            template.overwrite(tip.getComponent(0).getEl(),jsonObj);
                            tip.getComponent(1).doLayout();
                          }
                        });
                      }
                    }
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