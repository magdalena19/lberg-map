Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w[
                                                  page_specific/*
                                                  data_tables.js
                                                ]
