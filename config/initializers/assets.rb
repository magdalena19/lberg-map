Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w[
                                                  maps/show.js
                                                  maps/index.js
                                                  places/index.js.erb
                                                  review/review_translation.js
                                                  data_tables.js
                                                ]
