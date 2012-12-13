
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Symptom = Ext.extend(Talho.Rollcall.Graphing.view.filter.Filter,  {
  title: 'Symptom Filter',
  layout: 'form',
  
  initComponent: function () {
    var symptoms = new Ext.ListView({id: 'symptoms', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'name', width: 0.70, cls:'symptom-list-item'}, {dataIndex: 'value'}],
      hideHeaders: true, height: 160, fieldLabel: 'Symptoms ICD-9 Code'
    });
    
    this.items = [symptoms];
            
    this.loadable = [
      {item: symptoms, fields: ['id', 'name', {name:'value', mapping:'icd9_code'}], key: 'symptoms'}
    ];
    
    this.resetable = this.items;
    
    this.getable = [];
    
    Talho.Rollcall.graphing.view.filter.Symptom.superclass.initComponent.call(this);
  }
});
