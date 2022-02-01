module PgEtl
  module Compare
    # Compare the schema with the supplied one
    def self.included(base)
      base.class_eval do
      end
      base.extend(ClassMethods)
    end
    module ClassMethods
    end
  end
end
