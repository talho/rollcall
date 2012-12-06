
Ext.namespace("Talho.Rollcall.Graphing.view");

Talho.Rollcall.Graphing.view.AlarmConsole = Ext.extend(Ext.Tip, {
  
  
  initComponent: function () {
    title: '<b>Alarm Information for ' + this.row_record.get('school_name') + '</b>';
    
    this.addEvents('ignorealarm', 'deletealarm');
    this.enableBubble(['ignorealarm', 'deletealarm']);
    
    this.items = [
      this.template, 
      new Ext.grid.GridPanel({
      row_record:  this.row_record,
        forceLayout: true, scope: this, height: 150, width: 285, 
        store: new Ext.data.JsonStore({
          autoDestroy: true, autoSave: true, data: jsonObj[0].students,
          root: 'student_info',
          fields:      [
            {name:'id', type:'int'},
            {name:'school_name', type:'string'},
            {name:'report_date', renderer: Ext.util.Format.dateRenderer('m-d-Y')},
            {name:'age', type:'int'},
            {name:'dob', renderer: Ext.util.Format.dateRenderer('m-d-Y')},
            {name:'gender', type:'string'},
            {name:'grade', type:'int'},
            {name:'confirmed_illness', type:'boolean'}
          ]
        }),
        columns: [
          {header: 'Age', width: 35, sortable: true, dataIndex: 'age'},
          {header: 'DOB', width: 70, sortable: true, dataIndex: 'dob'},
          {header: 'Gender', width: 50, sortable: true, dataIndex: 'gender'},
          {header: 'Grade', width: 50, sortable: true, dataIndex: 'grade'},
          {header: 'Confirmed', width: 75, sortable: true,  dataIndex: 'confirmed_illness'}
        ],
        viewConfig: {
          emptyText: '<div style="padding:5px"><b style="color:#000">No confirmed absent students for this date</b></div>',
          forceFit: true, enableRowBody: true
        },
        stripeRows: true, stateful: true, buttonAlign: 'left', 
        fbar: [{
          text: this.btn_txt, scope: this, handler: function () { this.fireEvent('ignorealarm', this.row_record.get('ignore_alarm'), this.row_record.get('school_name')) }},
          '->',
          {text: 'Delete Alarm', scope: this, handler: function () { this.fireEvent('deletealarm', this.row_record, this.row_record.get('school_name'))}}
        ],
        listeners: {
          afterrender: function(this_panel)
          {
            if(this_panel.getStore().getCount() == 0)
              this_panel.getGridEl().update(this_panel.getView().emptyText);
          }
        }
      })
    ]
    
    Talho.Rollcall.Graphing.view.AlarmConsole.superclass.initComponent.call(this);
  },
});