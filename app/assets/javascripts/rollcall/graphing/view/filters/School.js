
Ext.namespace("Talho.Rollcall.Graphing.view.filter");

Talho.Rollcall.Graphing.view.filter.School = Ext.extend(Talho.Rollcall.ux.Filter, {
  title: 'School Filter',
  
  initComponent: function () {
    this.enableBubble('activateschool');
    
    var type = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
        columns: [{dataIndex: 'value', cls:'school-type-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'School Type'       
    });
    
    var zip = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form', 
      columns: [{dataIndex: 'value', cls:'zipcode-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'Zipcode'
    }); 
    
    var district = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form', 
      columns: [{dataIndex: 'value', cls:'school-district-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'School District'        
    });
    
    var school = new Ext.ListView({multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls:'school-name-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'School'           
    });    
    
    this.items = [type, zip, district, school];
    
    Ext.each(this.items, function (item) {
      item.clearValue = function () { this.clearSelections(); };
      item.addListener('selectionchange', function (view, selections) { 
        this.fireEvent('activateschool');
      }, this);
    }, this);
        
    this.loadable = [
      {item: type, fields: ['id', 'value'], key: 'school_type'},
      {item: zip, fields: ['id', 'value'], key: 'zipcode'},
      {item: district, fields: ['id', {name:'value', mapping:'name'}], key: 'school_districts'}, 
      {item: school, fields: ['id', {name:'value', mapping:'display_name'}], key: 'schools'}
    ];
    
    this.resetable = this.items;
    
    this.getable = [
      {key: 'type[]', get: this.getListBoxParameters, param: type},
      {key: 'zip[]', get: this.getListBoxParameters, param: zip},
      {key: 'district[]', get: this.getListBoxParameters, param: district},
      {key: 'school[]', get: this.getListBoxParameters, param: school}
    ];
    
    Talho.Rollcall.Graphing.view.filter.School.superclass.initComponent.call(this);
  }
});
