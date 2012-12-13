
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.School = Ext.extend(Talho.Rollcall.Graphing.view.filter.Filter, {
  title: 'School Filter',
  layout: 'form',
  
  initComponent: function () {
    var type = new Ext.ListView({id: 'school_type', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
        columns: [{dataIndex: 'value', cls:'school-type-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'School Type'       
    });
    
    var zip = new Ext.ListView({id: 'zip', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls:'zipcode-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'Zipcode'
    }); 
    
    var district = new Ext.ListView({id: 'school_district', multiSelect: true, simpleSelect: true, cls: 'ux-query-form', 
      columns: [{dataIndex: 'value', cls:'school-district-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'School District'        
    });
    
    var school = new Ext.ListView({id: 'school', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
      columns: [{dataIndex: 'value', cls:'school-name-list-item'}], hideHeaders: true, height: 90, fieldLabel: 'School'     
    });    
    
    this.items = [type, zip, district, school];
        
    this.loadable = [
      {item: type, fields: ['id', 'value'], key: 'school_type'},
      {item: zip, fields: ['id', 'value'], key: 'zipcode'},
      {item: district, fields: ['id', {name:'value', mapping:'name'}], key: 'school_districts'}, 
      {item: school, fields: ['id', {name:'value', mapping:'display_name'}], key: 'schools'}
    ];
    
    this.resetable = this.items;
    
    this.getable = [];
    
    Talho.Rollcall.graphing.view.filter.School.superclass.initComponent.call(this);
  }
});
