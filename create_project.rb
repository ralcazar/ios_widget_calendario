require 'xcodeproj'

PROJECT_ROOT = File.dirname(__FILE__)
PROJECT_PATH = File.join(PROJECT_ROOT, 'Calendario', 'Calendario.xcodeproj')

# Create project
project = Xcodeproj::Project.new(PROJECT_PATH)

# ── File groups ──────────────────────────────────────────────────────────────
main_group = project.main_group

app_group    = main_group.new_group('Calendario',       'CalendarioApp')
shared_group = main_group.new_group('Shared',           'Shared')
widget_group = main_group.new_group('CalendarioWidget', 'CalendarioWidget')
tests_group  = main_group.new_group('CalendarioTests',  '../CalendarioTests')
products_group = main_group.new_group('Products')

# ── App target ───────────────────────────────────────────────────────────────
app_target = project.new_target(:application, 'Calendario', :ios, '17.0')
app_target.product_reference.path = 'Calendario.app'
products_group << app_target.product_reference

app_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']        = 'com.ralcazar.calendario'
  config.build_settings['SWIFT_VERSION']                    = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY']          = '1'  # iPhone
  config.build_settings['GENERATE_INFOPLIST_FILE']         = 'YES'
  config.build_settings['CURRENT_PROJECT_VERSION']         = '1'
  config.build_settings['MARKETING_VERSION']               = '1.0'
  config.build_settings['SWIFT_EMIT_LOC_STRINGS']          = 'YES'
  config.build_settings['CODE_SIGN_ENTITLEMENTS']          = 'CalendarioApp/Calendario.entitlements'
  config.build_settings['ENABLE_PREVIEWS']                 = 'YES'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS']         = ['$(inherited)', '@executable_path/Frameworks']
  config.build_settings['DEVELOPMENT_TEAM']                = 'VM3BNYCM22'
  config.build_settings['CODE_SIGN_STYLE']                 = 'Automatic'
end

# ── Widget Extension target ───────────────────────────────────────────────────
widget_target = project.new_target(:app_extension, 'CalendarioWidget', :ios, '17.0')
widget_target.product_reference.path = 'CalendarioWidget.appex'
products_group << widget_target.product_reference

widget_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']       = 'com.ralcazar.calendario.widget'
  config.build_settings['SWIFT_VERSION']                   = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY']          = '1'
  config.build_settings['INFOPLIST_FILE']                  = 'CalendarioWidget/Info.plist'
  config.build_settings['CURRENT_PROJECT_VERSION']         = '1'
  config.build_settings['MARKETING_VERSION']               = '1.0'
  config.build_settings['CODE_SIGN_ENTITLEMENTS']          = 'CalendarioWidget/CalendarioWidget.entitlements'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS']         = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  config.build_settings['APPLICATION_EXTENSION_API_ONLY']  = 'YES'
  config.build_settings['DEVELOPMENT_TEAM']                = 'VM3BNYCM22'
  config.build_settings['CODE_SIGN_STYLE']                 = 'Automatic'
end

# Embed the widget in the app
embed_phase = app_target.new_copy_files_build_phase('Embed Foundation Extensions')
embed_phase.dst_subfolder_spec = '13'  # Plug-ins / Extensions
widget_ref = embed_phase.add_file_reference(widget_target.product_reference)
widget_ref.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# ── Tests target ─────────────────────────────────────────────────────────────
tests_target = project.new_target(:unit_test_bundle, 'CalendarioTests', :ios, '17.0')
tests_target.product_reference.path = 'CalendarioTests.xctest'
products_group << tests_target.product_reference

tests_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']  = 'com.ralcazar.calendarioTests'
  config.build_settings['SWIFT_VERSION']              = '5.0'
  config.build_settings['BUNDLE_LOADER']              = '$(TEST_HOST)'
  config.build_settings['TEST_HOST']                  = '$(BUILT_PRODUCTS_DIR)/Calendario.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Calendario'
  config.build_settings['GENERATE_INFOPLIST_FILE']    = 'YES'
  config.build_settings['DEVELOPMENT_TEAM']           = 'VM3BNYCM22'
  config.build_settings['CODE_SIGN_STYLE']            = 'Automatic'
end

tests_target.add_dependency(app_target)

# ── Source files ─────────────────────────────────────────────────────────────
def add_file(group, rel_path, targets)
  ref = group.new_file(rel_path)
  targets.each do |t|
    t.add_file_references([ref])
  end
  ref
end

add_file(app_group, 'CalendarioApp.swift',    [app_target])
add_file(app_group, 'ContentView.swift',      [app_target])
add_file(app_group, 'Calendario.entitlements',[])   # not compiled

add_file(shared_group, '../Shared/SharedConstants.swift', [app_target, widget_target])

add_file(widget_group, 'CalendarioWidget.swift',       [widget_target])
add_file(widget_group, 'CalendarioWidgetBundle.swift',  [widget_target])
add_file(widget_group, 'Info.plist',                    [])
add_file(widget_group, 'CalendarioWidget.entitlements', [])

add_file(tests_group, 'CALsue1ScenarioTests.swift', [tests_target])

# ── Save first so project has root_object ─────────────────────────────────────
project.save

# ── Schemes ──────────────────────────────────────────────────────────────────
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app_target)
scheme.add_test_target(tests_target)
scheme.save_as(PROJECT_PATH, 'Calendario')

puts "✅ Project saved to #{PROJECT_PATH}"
