import NimQml, tables, sequtils, sugar, chronicles

import io_interface, view, controller, item, model, locale_table
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../../app/core/eventemitter

import ../../../../../app_service/service/language/service as language_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
    events: EventEmitter, languageService: language_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, languageService)
  result.moduleLoaded = false

proc populateLanguageModel(self: Module) =
  var items: seq[Item]

  for locale in self.controller.getLocales():
    if localeDescriptionTable.contains(locale):
      let localeDescr = localeDescriptionTable[locale]
      items.add(initItem(
        locale = locale,
        name = localeDescr.name,
        native = localeDescr.native,
        flag = localeDescr.flag
      ))
    else:
      warn "missing locale details", locale

  self.view.model().setItems(items)

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.populateLanguageModel()
  self.view.setLocale(self.controller.getCurrentLocale())

  self.moduleLoaded = true
  self.delegate.languageModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method changeLocale*(self: Module, locale: string) =
  self.controller.changeLocale(locale)

method onCurrentLocaleChanged*(self: Module, locale: string) =
  self.view.setLocale(locale)

method setIsDDMMYYDateFormat*(self: Module, isDDMMYYDateFormat: bool) =
  if(isDDMMYYDateFormat != singletonInstance.localAccountSensitiveSettings.getIsDDMMYYDateFormat()):
    singletonInstance.localAccountSensitiveSettings.setIsDDMMYYDateFormat(isDDMMYYDateFormat)

method setIs24hTimeFormat*(self: Module, is24hTimeFormat: bool) =
  if(is24hTimeFormat != singletonInstance.localAccountSensitiveSettings.getIs24hTimeFormat()):
    singletonInstance.localAccountSensitiveSettings.setIs24hTimeFormat(is24hTimeFormat)


