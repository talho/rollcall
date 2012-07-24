Talho.ScriptManager.addInitializer('Talho.Rollcall.NurseAssistant', {
  js:'$(ext_extensions)/xActionColumn.js $(js)/rollcall/NurseAssistant.js'
});
Talho.ScriptManager.addInitializer('Talho.Rollcall.ADST', {
  js: '$(ext_extensions)/Portal.js $(js)/rollcall/ux/ComboBox.js $(js)/rollcall/d3/d3.v2.min.js $(js)/rollcall/ADST/Controller.js' 
});
// Talho.ScriptManager.addInitializer('Talho.Rollcall.ADST', {
  // js:'( $(ext_extensions)/Portal.js > $(js)/rollcall/ux/ComboBox.js > $(js)/rollcall/ux/AlarmQueryWindow.js > $(js)/rollcall/ADSTAlarmQueriesPanel.js ) \
      // ( $(js)/rollcall/d3/d3.v2.min.js ) \
      // $(ext_extensions)/HBox.js ( $(js)/rollcall/ADST.js >  $(js)/rollcall/ADSTSimpleContainer.js ) \
      // $(js)/rollcall/ADSTAlarmsPanel.js $(js)/rollcall/ADSTAdvancedContainer.js \
      // ( $(ext_extensions)/Portal.js > $(js)/rollcall/ADSTResultPanel.js GMap ) \
      // $(js)/rollcall/ux/D3Graph.js'
// });
Talho.ScriptManager.addInitializer('Talho.Rollcall.Schools', {
  js:'$(js)/rollcall/Schools.js  $(ext_extensions)/GMapPanel.js'
});
Talho.ScriptManager.addInitializer('Talho.Rollcall.Users', {
  js:'$(js)/rollcall/Users.js'
});