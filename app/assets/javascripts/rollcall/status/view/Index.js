Ext.namespace("Talho.Rollcall.status.view");

Talho.Rollcall.status.view.Index = Ext.extend(Ext.Panel, {
  layout: 'hbox',
  
  initComponent: function () {
    //TODO Loading mask
    var school_store = new Ext.data.JsonStore({
      fields: ['School','School District','Last Reported Date']
    });
    
    var district_store = new Ext.data.JsonStore({
      fields: ['School District','Last Reported Date']
    });
    
    Ext.Ajax.request({
      url: 'rollcall/status.json',
      method: 'GET',
      success: function (response, options) {
        var results = Ext.decode(response.responseText).results;
        school_store.loadData(results.schools);
        district_store.loadData(results.school_districts);
      }
    })
    
    this.school_panel = new Ext.grid.GridPanel({
      store: school_store,
      flex: 1,
      autoHeight: true,
      border: false,
      padding: 5,
      title: "Schools that haven't reported in 5 days",
      columns: [
        {id: 'school', dataIndex: 'School', header: 'School'},
        {id: 'schooldistrict', dataIndex: 'School District', header: 'School District'},
        {id: 'date', dataIndex: 'Last Reported Date', header: 'Last Reported Date'},
      ]
    });
    
    this.district_panel = new Ext.grid.GridPanel({
      store: district_store,
      flex: 1,
      autoHeight: true,
      padding: 5,
      border: false,
      title: "School Districts that haven't reported in 5 days",
      columns: [
        {id: 'schooldistrict', dataIndex: 'School District', header: 'School District'},
        {id: 'date', dataIndex: 'Last Reported Date', header: 'Last Reported Date'},
      ]
    });
    
    this.items = [
      this.district_panel,
      this.school_panel
    ]
    
    Talho.Rollcall.status.view.Index.superclass.initComponent.apply(this, arguments);
  }
});