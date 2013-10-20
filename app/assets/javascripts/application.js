//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$(window).load(function() {
	$('li.unchanged').remove();
  $('.site-link td:not(.main-link)').on('click', function(){
    window.open($(this).closest('tr').data("url"));
  });
});