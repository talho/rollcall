Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ux.ComboBox = Ext.extend(Ext.form.ComboBox, {
  typeAhead:     true,
  triggerAction: 'all',
  mode:          'local',
  lazyRender:    true,
  autoSelect:    true,
  selectOnFocus: true,
  valueField:    'id',
  displayField:  'value',
  ctCls:         'ux-combo-box-cls'
});