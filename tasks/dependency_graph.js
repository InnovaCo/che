module.exports = function(grunt) {
	var fs = require('fs'),
		data = {
			'nodes': [],
			'links': []
		},
		modulesCache = {},
		priorityList = {
			'app': 2,
			'underscore': 1.5
		},
		groupList = {
			'app': 3,
			'underscore': 2
		},
		libsList = {
			'dom!': 'DomReady'
		},

		rememberModuleName = function(name) {
			if (modulesCache[name] != null) {
				return modulesCache[name];
			} else {
				data.nodes.push({
					id: name,
					group: groupList[name] || 1,
					priority: priorityList[name] || 1,
				});
				return modulesCache[name] = data.nodes.length - 1;
			}
		},

		define = function(moduleName, dependency) {
			sourceId = rememberModuleName(moduleName);

			if (typeof(dependency) === 'function') {
				dependency = null;
			}

			if (dependency && dependency.length) {
				for (var i = 0, length = dependency.length, dependencyName; i < length; i++) {
					dependencyName = dependency[i];

					data.links.push({
						'source': sourceId,
						'target': rememberModuleName(libsList[dependencyName] || dependencyName)
					});
				};
			}
		},
		sourceId;

	grunt.registerMultiTask('dependencygraph', 'Build modules dependency map.', function() {
		var options = this.options({
				baseUrl: ""
			}),
			regex = /(?:(?:define\s+\[)|(?:requirejs\s+\[))([^\]]+)/gm;

		this.files.forEach(function(f) {
			var src = f.src.filter(function(filepath) {
					if (!grunt.file.exists(filepath)) {
						grunt.log.warn('Source file "' + filepath + '" not found.');
						return false;
					} else {
						return true;
					}
				})

			src.forEach(function(path) {
				var fString = fs.readFileSync(path, 'utf-8'),
					matches = fString.match(regex);

				for (var match in matches) {
					// Подготавливаем список зависимостей исправляя особенности.
					var fixedMatch = matches[match]
							.replace(/[\n\t]+/g, '')
							.replace(/('|"),?(\s+)/g, '",$2')
							.replace(/,\s*$/, '')
							.replace(/'/g, '"');

					// Создаемм данные для графа зависимостей.
					define(path.substring(options.baseUrl.length, path.lastIndexOf('.')), eval(fixedMatch.substr(fixedMatch.indexOf('[')) + ']'));
				}
			});
		});

		// Копируем необходимые файлы.
		grunt.file.copy('tasks/files/main.css', this.data.dest + 'static/styles/main.css');
		grunt.file.copy('tasks/files/main.js', this.data.dest + 'static/js/main.js');
		grunt.file.copy('tasks/files/index.html', this.data.dest + 'index.html');

		// Создаем файл с данными по зависимостям.
		fs.writeFileSync(this.data.dest + 'data.json', JSON.stringify(data));

		console.log('all done!');
	});
};