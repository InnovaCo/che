require = {
	config: function() {}
};

define = function(moduleName, dependency) {
	if (typeof(dependency) === 'function') {
		dependency = null;
	}

	if (dependency && !dependency.length) {
		dependency = null;
	}
	console.log(moduleName, dependency);
};