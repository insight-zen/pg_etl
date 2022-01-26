module PgEtl
  module Compare
    def self.included(base)
      base.class_eval do
      end
      base.extend(ClassMethods)
    end
    module ClassMethods

    end
  end
end