# frozen_string_literal: true

Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.paths << Rails.root.join('vendor', 'javascript')
Rails.application.config.assets.precompile += %w[bootstrap.min.js popper.js]
Rails.application.config.assets.precompile += %w[ vendor/javascript/codemirror/**/*.js
                                                  vendor/javascript/codemirror/**/*.css ]
Rails.application.config.assets.precompile += %w[ codemirror/lib/codemirror.js
                                                  codemirror/lib/codemirror.css
                                                  codemirror/addon/comment/comment.js
                                                  codemirror/mode/sql/sql.js
                                                  codemirror/theme/dracula.css]
