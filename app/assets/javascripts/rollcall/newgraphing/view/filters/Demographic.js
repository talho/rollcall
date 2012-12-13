
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Demographic = Ext.extend(Talho.Rollcall.Graphing.view.filter.Filter, {
  title: 'Demographic Filter',
  layout: 'form',
  
  initComponent: function () {    
    var age = new Ext.ListView({id: 'age', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls: 'age-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'Age'
    });
    
    var grade = new Ext.ListView({id: 'grade', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls: 'grade-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'Grade'
    });
    
    var gender = new Talho.Rollcall.ux.ComboBox({id: 'gender', fieldLabel: 'Gender', editable: false, emptyText: 'Select Gender...'});
    
    this.items = [age, grade, gender];
    
    this.loadable = [
      {item: age, fields: ['id', 'value'],  key: 'age'},
      {item: grade, fields: ['id', 'value'], key: 'grade'},
      {item: gender, fields: ['id', 'value'], key: 'gender'}
    ];
    
    this.resetable = this.items;
    
    this.getable = [];
    
    Talho.Rollcall.graphing.view.filter.Demographic.superclass.initComponent.call(this);
  }
});
