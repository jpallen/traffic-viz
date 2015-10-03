module.exports = (grunt) ->
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-jade'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-express-server'
	grunt.loadNpmTasks 'grunt-mocha-test'
	
	grunt.initConfig {
		less:
			app:
				files:
					"public/styles/main.css": "app/styles/main.less"
		
		jade:
			app:
				files:
					"public/index.html": "app/pages/index.jade"
		
		browserify:
			app:
				files:
					"public/js/index.js": ["app/scripts/index.coffee"]
				options:
					transform: ["coffeeify"]
		
		express:
			server:
				options:
					opts: ['node_modules/coffee-script/bin/coffee']
					script: "app/server/index.coffee"
					port: 8000
		
		watch:
			server:
				files: ["app/server/*.coffee", "app/shared/*.coffee"]
				tasks: ["express:server"],
				options:
					spawn: false
			coffee:
				files: ["app/scripts/*.coffee", "app/shared/*.coffee"]
				tasks: ["browserify:app"]
			less:
				files: "app/styles/*.less"
				tasks: ["less:app"]
			jade:
				files: "app/pages/*.jade"
				tasks: ["jade:app"]
			livereload:
				options:
					livereload: true
				files: [
					'public/js/*'
					'public/*.html'
					'public/styles/*'
				]
		
		mochaTest:
			test:
				src: ["test/coffee/*.coffee"]
				options:
					reporter: 'spec',
					require: 'coffee-script/register'
	}
	
	grunt.registerTask "build", ["jade", "less", "browserify"]
	
	grunt.registerTask "run", ["jade", "less", "browserify", "express", "watch"]
