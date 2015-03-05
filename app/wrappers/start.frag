(function (root, factory) {
	if (typeof define === 'function' && define.amd) {
		define(['underscore'], factory);
	} else {
		root.che = factory(root._);
	}
}(this, function (_) {
