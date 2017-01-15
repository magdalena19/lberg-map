Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w[
                                                  static_pages/map.js
                                                  static_pages/index.js
                                                  places/index.js.erb
                                                  review/translation_review.js
                                                  data_tables.js
                                                ]
