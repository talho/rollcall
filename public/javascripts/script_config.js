Talho.ScriptManager.addInitializer('Talho.Rollcall', {js:'AjaxPanel /javascripts/rollcall/rollcall.js'});
Talho.ScriptManager.addInitializer('Talho.Rollcall.NurseAssistant', {js:'$(ext_extensions)/xActionColumn.js /javascripts/rollcall/NurseAssistant.js'});
Talho.ScriptManager.addInitializer('Talho.Rollcall.ADST', {
  js:'( $(ext_extensions)/Portal.js > /javascripts/rollcall/ux/ComboBox.js > ' +
     '/javascripts/rollcall/SavedQueriesPanel.js ) $(ext_extensions)/HBox.js ' +
     '( /javascripts/rollcall/ADST.js >  /javascripts/rollcall/SimpleADSTContainer.js ) '+
     ' /javascripts/rollcall/ReportsPanel.js ' +
     '/javascripts/rollcall/AlarmsPanel.js /javascripts/rollcall/AdvancedADSTContainer.js ' +
     '( $(ext_extensions)/Portal.js > /javascripts/rollcall/ADSTResultPanel.js )'
});
 