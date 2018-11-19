# We need to define a function to check whether or not
# an identifier exists. The default one returns false,
# which will occasionally raise LDP::Conflict errors.
#
# see: https://github.com/samvera/hyrax/issues/3128#issuecomment-439967751
::Noid::Rails.config.identifier_in_use = lambda do |id|
  ActiveFedora::Base.exists?(id) || ActiveFedora::Base.gone?(id)
end
