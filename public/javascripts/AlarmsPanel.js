Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.AlarmsPanel = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    this.alarm_reader = new Ext.data.JsonReader({
      root: 'alarms',
      totalProperty: 'total_results',
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
        {name:'ignore_alarm',   type:'boolean'},
        {name:'created_at',     type:'date', dateFormat:'timestamp'},
        {name:'updated_at',     type:'date', dateFormat:'timestamp'}
      ]
    });

    this.alarms_store = new Ext.data.GroupingStore({
      autoLoad: true,
      autoDestroy: true,
      autoSave: true,
      reader: this.alarm_reader,
      writer: new Ext.data.JsonWriter({
        encode: false
      }),
      url: '/rollcall/alarms',
      sortInfo:{field: 'alarm_name', direction: "ASC"},
      groupField:'alarm_name',
      restful: true,
      listeners:{
          scope: this,
          load: function(this_store, record){
            if(typeof(this_store.alarm_icon_el) != "undefined") {
              this_store.alarm_icon_el.toggleClass('x-tool-alarm-off');
              this_store.alarm_icon_el.toggleClass('x-tool-alarm-on');
            }
          }
      }
    });

    this.tmpl = new Ext.XTemplate(
      '<tpl for=".">',
        '<div class="thumb-wrap {[this.ignore_alarm(values.ignore_alarm)]}">',
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
      '<div class="x-clear"></div>',
      {
        compiled: true,
        ignore_alarm: function(ignore){
          if(ignore){
            return 'ignore'
          }
        }
      }
    );

    this.tip_array = [];
    
    Ext.applyIf(config,{
      id: 'alarm_panel',
      itemId: 'alarm_panel',
      items: new Ext.grid.GridPanel({
        store: this.alarms_store,
        hideHeaders: true,
        columns: [
          {
            xtype: 'templatecolumn',
            id:'school_name',
            header: 'School Name',
            sortable: true,
            dataIndex: 'school_name',
            tpl: this.tmpl
          },{
            id:'alarm_name',
            dataIndex: 'alarm_name',
            hidden: true
          }
        ],
        stripeRows: true,
        autoExpandColumn: 'school_name',
        stateful: true,
        stateId: 'grid',
        iconCls: 'rollcall_alarm_icon',
        view: new Ext.grid.GroupingView({
          showGroupName: false,
          startCollapsed: true,
          groupTextTpl: '<div class="rollcall_alarm_icon">{text}</div>'
        }),
        listeners:{
          scope: this,
          collapse: this.collapse,
          bodyscroll: this.bodyscroll,
          rowclick: this.rowclick
        }
      }),
      layout:'fit',
      layoutConfig:{
        animate:true
      }
    });
    Talho.Rollcall.AlarmsPanel.superclass.constructor.call(this, config);
  },
  collapse: function(this_grid){
    if(this.tip_array.length != 0) this.tip_array.pop().destroy();
  },
  bodyscroll: function(scroll_left, scroll_right){
    if(this.tip_array.length != 0) this.tip_array.pop().destroy();
  },
  rowclick: function(this_grid, index, event_obj){
    var row_record = this_grid.getStore().getAt(index);
    if(this.tip_array.length != 0) this.tip_array.pop().destroy();
    var tip = new Ext.Tip({
      title: 'Alarm Information for '+ row_record.get('school_name'),
      closable: true,
      cls: 'alarm-tip',
      layout:'fit',
      data: [1],
      tpl: new Ext.XTemplate(
        '<div class="all-purpose-load-icon"></div>',
        '<div class="x-tip-anchor x-tip-anchor-left x-tip-anchor-adjust"></div>'
      )
    });
    this.tip_array.push(tip);
    tip.showBy(this_grid.getView().getRow(index), 'tl-tr');

    Ext.Ajax.request({
      url: 'rollcall/get_info',
      method: 'POST',
      headers: {'Accept': 'application/json'},
      scope: this,
      params:{
        school_id: row_record.get('school_id'),
        report_date: row_record.get('report_date'),
        alarm_id: row_record.get('id'),
        saved_query_id: row_record.get('saved_query_id')
      },
      success: function(response, options){
        jsonObj      = response.responseText.replace(/"alarm_severity"/g, 'alarm_severity');
        jsonObj      = jsonObj.replace(/"info"/g, 'info');
        jsonObj      = jsonObj.replace(/"total_confirmed_absent"/g, 'total_confirmed_absent');
        jsonObj      = jsonObj.replace(/"total_absent"/g, 'total_absent');
        jsonObj      = jsonObj.replace(/"total_enrolled"/g, 'total_enrolled');
        jsonObj      = jsonObj.replace(/"school_name"/g, 'school_name');
        jsonObj      = jsonObj.replace(/"school_type"/g, 'school_type');
        jsonObj      = eval(jsonObj);
        var template = new Ext.XTemplate(
          '<tpl for=".">',
            '<table class="alarm-tip-table">',
              '<tr>',
                '<td><b>School:</b></td>',
                '<td><span>{school_name}</span></td>',
              '</tr>',
              '<tr>',
                '<td><b>School Type:</b></td>',
                '<td><span>{school_type}</span></td>',
              '</tr>',
              '<tr>',
                '<td>&nbsp;</td>',
                '<td>&nbsp;</td>',
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
              '<tr>',
                '<td>&nbsp;</td>',
                '<td>&nbsp;</td>',
              '<tr>',
              '<tr>',
                '<td><b>Student Info:</b></td>',
                '<td>&nbsp;</td>',
              '<tr>',
            '</table>',
          '</tpl>',
          '<div class="x-tip-anchor x-tip-anchor-left x-tip-anchor-adjust"></div>'
        );
        var ignore_button_text = "Ignore Alarm";
        if(row_record.get('ignore_alarm'))ignore_button_text = "Unignore Alarm";

        if(this.tip_array.length != 0) this.tip_array.pop().destroy();
        tip = new Ext.Tip({
          title: 'Alarm Information for '+ row_record.get('school_name'),
          closable: true,
          cls: 'alarm-tip',
          scope: this,
          layout:'fit',
          items: [template,new Ext.grid.GridPanel({
            forceLayout: true,
            scope: this,
            viewConfig: {
              forceFit: true
            },
            store: new Ext.data.JsonStore({
              autoDestroy: true,
              autoSave: true,
              data: jsonObj[0].students,
              root: 'student_info',
              fields: [
                {name:'id',                type:'int'},
                {name:'school_name',       type:'int'},
                {name:'report_date',       renderer: Ext.util.Format.dateRenderer('m-d-Y')},
                {name:'age',               type:'int'},
                {name:'dob',               renderer: Ext.util.Format.dateRenderer('m-d-Y')},
                {name:'gender',            type:'string'},
                {name:'grade',             type:'int'},
                {name:'confirmed_illness', type:'boolean'}
              ]
            }),
            columns: [
              {header: 'Age',       width: 35, sortable: true,  dataIndex: 'age'},
              {header: 'DOB',       width: 70, sortable: true,  dataIndex: 'dob'},
              {header: 'Gender',    width: 50, sortable: true,  dataIndex: 'gender'},
              {header: 'Grade',     width: 50, sortable: true,  dataIndex: 'grade'},
              {header: 'Confirmed', width: 75, sortable: true,  dataIndex: 'confirmed_illness'}
            ],
            stripeRows: true,
            stateful: true,
            buttonAlign: 'left',
            fbar:[{
              text: ignore_button_text,
              scope: this,
              handler: function(btn,event){
                if(row_record.get('ignore_alarm')){
                  row_record.set('ignore_alarm', false);
                  this.tip_array.pop().destroy();
                }else{
                  this.tip_array[0].hide();
                  Ext.MessageBox.show({
                    title: 'Ignore Alarm for '+row_record.get('school_name'),
                    msg: 'Are you sure you want to ignore this alarm? Ignoring an alarm prevents any alerts '+
                    'associated with the alarm from firing. You can unignore an alarm at anytime.',
                    buttons: {
                      ok: 'Yes',
                      cancel: 'No'
                    },
                    scope: this,
                    icon: Ext.MessageBox.QUESTION,
                    fn: function(btn,txt,cfg_obj){
                      if(btn == 'ok'){
                        row_record.set('ignore_alarm', true);
                        this.tip_array.pop().destroy();
                      }else{
                        this.tip_array[0].show();
                      }
                    }
                  });
                }
              }
            },'->',{
              text: 'Delete Alarm',
              scope: this,
              handler: function(btn,event){
                this.tip_array[0].hide();
                Ext.MessageBox.show({
                  title: 'Delete Alarm for '+row_record.get('school_name'),
                  msg: 'Are you sure you want to delete this alarm? You can not undo this change.',
                  buttons: {
                    ok: 'Yes',
                    cancel: 'No'
                  },
                  scope: this,
                  icon: Ext.MessageBox.QUESTION,
                  fn: function(btn,txt,cfg_obj){
                    if(btn == 'ok'){
                      this_grid.getStore().remove(row_record);
                      this.tip_array.pop().destroy();
                    }else{
                      this.tip_array[0].show();
                    }
                  }
                });
              }
            }]
          })]
        });
        this.tip_array.push(tip);
        tip.showBy(this_grid.getView().getRow(index), 'tl-tr');
        template.overwrite(tip.getComponent(0).getEl(),jsonObj);
        tip.getComponent(1).doLayout();
      }
    });
  }
});