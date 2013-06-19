module.exports = function(grunt) {
	var fs = require('fs'),
		data = {
			nodes: [],
			links: []
		},
		modulesCache = {},
		sourceId;

	grunt.registerMultiTask('dependencygraph', 'Build modules dependency map.', function() {
		var options = this.options({
				baseUrl: "", // Базовый урл относительно которого рассматриваем модули.
				libsList: {}, // Словарь соответсвий названий модулей с желаемыми названиями для отображения.
				groupList: {}, // Список модулей и назначенные им цветовые группы.
				priorityList: {}, // Список содулей и назначенные им коэфициенты увеличения размера нода.
				linkDistance: 300, // Длина связей между нодами
				charge: -700, // Заряд нодов. Если отрицательный, то они отталкиваются, если положительный то притягиваются.
				sizeX: 1000,
				sizeY: 1000
			}),
			regex = /(?:(?:define\s+\[)|(?:requirejs\s+\[))([^\]]+)/gm,
			rememberModuleName = function(name) {
				if (modulesCache[name] != null) {
					return modulesCache[name];
				} else {
					data.nodes.push({
						id: name,
						group: options.groupList[name] || 1,
						priority: options.priorityList[name] || 1,
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
					for (var i = 0, length = dependency.length, dependencyName, forceDependency; i < length; i++) {
						dependencyName = dependency[i];
						forceDependency = false;

						if (dependencyName[dependencyName.length - 1] === '!') {
							dependencyName = dependencyName.substr(0, dependencyName.length - 1);
							forceDependency = true;
						}

						data.links.push({
							source: sourceId,
							target: rememberModuleName(options.libsList[dependencyName] || dependencyName),
							forceDependency: forceDependency
						});
					};
				}
			};

		// Переносим настройки графа в объект данных.
		data.sizeX = options.sizeX;
		data.sizeY = options.sizeY;
		data.charge = options.charge;
		data.linkDistance = options.linkDistance;

		// Собираем файлы и обрабатываем ищем в них модули и зависимости.
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

		console.log('found modules:\n');
		console.log(data.nodes);
	});
};