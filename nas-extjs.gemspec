# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "nas-extjs"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Stitt"]
  s.date = "2013-01-27"
  s.description = "Collection of functions to make working with Extjs and rails work together better"
  s.email = "nathan@stitt.org"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/generators/nas_extjs/install_generator.rb",
    "lib/generators/nas_extjs/templates/config/initializers/nas_extjs.rb",
    "lib/generators/nas_extjs/templates/lib/tasks/build_coffee.rake",
    "lib/generators/nas_extjs/templates/public/app/lib/BuildURL.coffee",
    "lib/generators/nas_extjs/templates/public/app/lib/Notification.coffee",
    "lib/generators/nas_extjs/templates/public/app/lib/SaveNotify.coffee",
    "lib/generators/nas_extjs/templates/public/app/lib/Util.coffee",
    "lib/generators/nas_extjs/templates/public/app/lib/VTypes.coffee",
    "lib/generators/nas_extjs/templates/public/app/model/Association.coffee",
    "lib/generators/nas_extjs/templates/public/app/model/Base.coffee",
    "lib/generators/nas_extjs/templates/public/app/model/BelongsTo.coffee",
    "lib/generators/nas_extjs/templates/public/app/model/HasMany.coffee",
    "lib/generators/nas_extjs/templates/public/app/model/Message.coffee",
    "lib/generators/nas_extjs/templates/public/app/model/mixins/PolymorphicSource.coffee",
    "lib/generators/nas_extjs/templates/public/app/store/Base.coffee",
    "lib/generators/nas_extjs/templates/public/app/store/EmailArray.coffee",
    "lib/generators/nas_extjs/templates/public/app/store/mixins/HasSelections.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/BoxSelect.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/BoxSelectField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/CodeField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/CustomComboBox.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/DateTimeField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/DateTimePicker.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/EmailDisplayField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/EmbededWindow.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/FinderWindow.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/FindingField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/Format.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/MailWindow.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/Notification.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/NumericField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/RadioColumn.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/SelectedColumn.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/StateField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/TelDisplayField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/TimePickerField.coffee",
    "lib/generators/nas_extjs/templates/public/app/ux/VisibleIdField.coffee",
    "lib/generators/nas_extjs/templates/public/images/nas-extjs/checked.gif",
    "lib/generators/nas_extjs/templates/public/images/nas-extjs/fader.png",
    "lib/generators/nas_extjs/templates/public/images/nas-extjs/failure.png",
    "lib/generators/nas_extjs/templates/public/images/nas-extjs/info.png",
    "lib/generators/nas_extjs/templates/public/images/nas-extjs/radioed.gif",
    "lib/generators/nas_extjs/templates/public/images/nas-extjs/success.png",
    "lib/generators/nas_extjs/templates/public/images/nas-extjs/unchecked.gif",
    "lib/generators/nas_extjs/templates/public/images/nas-extjs/unradioed.gif",
    "lib/generators/nas_extjs/templates/public/resources/sass/default/box_select.scss",
    "lib/generators/nas_extjs/templates/public/resources/sass/default/nas_extjs.scss",
    "lib/generators/nas_extjs/templates/public/resources/sass/default/notifications.scss",
    "lib/generators/nas_extjs/templates/public/resources/sass/default/selectheader.scss",
    "lib/nas-extjs/ar_ext/api_serializable_hash.rb",
    "lib/nas-extjs/ar_ext/exports_associations.rb",
    "lib/nas-extjs/ar_ext/exports_methods.rb",
    "lib/nas-extjs/ar_ext/exports_scope.rb",
    "lib/nas-extjs/ar_ext/immutable_model.rb",
    "lib/nas-extjs/ar_ext/sanitizes_json.rb",
    "lib/nas-extjs/controller.rb",
    "lib/nas_extjs.rb",
    "nas-extjs.gemspec",
    "test/helper.rb",
    "test/test_nas-extjs.rb"
  ]
  s.homepage = "http://github.com/nathanstitt/nas-extjs"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Controller and utilities to make Extjs and rails work together better"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end

