if (typeof(Ext) == "undefined") {
  (function($) {
    $(function() {
      $(document).ready(function() {
        $(".school_selection select#district_id").change(function() {
          $(".school_selection select#school_id option:selected").attr('selected', '');
          $(".school_selection select#school_id option:first").attr('selected', 'selected');
          $("form").submit();
        });

        $("ul.school_alerts").hide();
        $("ul.schools").hide();
      });
      $("ul.district a.district_name").click(function(){
        $("ul.schools", $(this).parent()).toggle("slide", {direction:"up"});
        $("span.more").hide();
        expander=$("span.expander", $(this).parent());
        expander.text(expander.text() == ">>" ? "<<" : ">>");
      });
      $("a.school_name").click(function(){
        $("ul.school_alerts", $(this).parent().parent()).toggle("slide", {direction:"up"});
        $("span.more", $(this).parent().parent()).toggle();
        $(this).parent().parent().toggleClass('school_bordered');
      });
    });
  })(jQuery);
} else {
  Ext.namespace('Talho');

  Talho.Rollcall = Ext.extend(Ext.util.Observable, {
    constructor: function(config){
      Ext.apply(this, config);
      Talho.Rollcall.superclass.constructor.call(this, config);
      var panel = new Ext.CenteredAjaxPanel({
        url: this.url,
        title: this.title,
        itemId: this.id,
        closable: true,
        hideBorders:true,
        autoScroll:true,
        listeners:{ scope: this, 'ajaxloadcomplete': this.panelLoaded }
      });
      this.getPanel = function(){ return panel; }
    },
    panelLoaded: function(panel){
      // Setup for Rollcall Schools tab
      $(".school_selection select#district_id").change(function() {
        $(".school_selection select#school_id option:selected").attr('selected', '');
        $(".school_selection select#school_id option:first").attr('selected', 'selected');
        $("form").submit();
      });

      // Setup for Rollcall Main tab
      $("ul.district a.district_name").click(function(){
        $("ul.schools", $(this).parent()).toggle("slide", {direction:"up"});
        $("span.more").hide();
        expander=$("span.expander", $(this).parent());
        expander.text(expander.text() == ">>" ? "<<" : ">>");
      });
      $("a.school_name").click(function(){
        $("ul.school_alerts", $(this).parent().parent()).toggle("slide", {direction:"up"});
        $("span.more", $(this).parent().parent()).toggle();
        $(this).parent().parent().toggleClass('school_bordered');
      });

      // Execute the script tag to generate the open flash chart graph
      scr_tag = panel.getEl().select("div.rollcall_chart script").first();
      if (scr_tag) { eval(scr_tag.dom.text); }

      // Render the layout
      panel.doLayout();
    }
  });

  Talho.Rollcall.initialize = function(config){
    var alerts = new Talho.Rollcall(config);
    return alerts.getPanel();
  }
}
