$.extend({
	isDefined: function(dom) {
		return $(dom).length;
	},
	assetsURL: function() {
		return $('#remote-server').attr('data-assets-url');
	}
});