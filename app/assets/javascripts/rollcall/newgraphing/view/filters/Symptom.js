
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Symptom = Ext.extend(Talho.Rollcall.ux.Filter,  {
  title: 'Symptom Filter',
  
  initComponent: function () {
    var symptoms = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'name', width: 0.70, cls:'symptom-list-item'}, {dataIndex: 'value'}],
      hideHeaders: true, height: 160, fieldLabel: 'Symptoms ICD-9 Code', clearValue: function () { this.clearSelections(); }
    });
    
    this.items = [symptoms];
            
    this.loadable = [
      {item: symptoms, fields: ['id', 'name', {name:'value', mapping:'icd9_code'}], key: 'symptoms'}
    ];
    
    this.resetable = this.items;
    
    this.getable = [
      {key: 'symptoms[]', get: this.getListBoxParameters, param: symptoms}
    ];
    
    Talho.Rollcall.graphing.view.filter.Symptom.superclass.initComponent.call(this);
  }
});
