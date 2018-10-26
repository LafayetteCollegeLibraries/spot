# this was originally in config/initializers/hyrax.rb,
# but buried at the bottom. moving it into its own file
# so that it's easier to find/configure.
Qa::Authorities::Local.register_subauthority('languages',
                                             'Qa::Authorities::Local::TableBasedAuthority')
