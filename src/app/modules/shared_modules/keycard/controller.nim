import Tables, chronicles

import io_interface

import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service

logScope:
  topics = "keycard-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    keycardService: keycard_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  keycardService: keycard_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SignalPluginKeycardReader) do(e: Args):
    self.delegate.switchToState(FlowStateType.PluginKeycard)
  
  self.events.on(SignalInsertKeycard) do(e: Args):
    self.delegate.switchToState(FlowStateType.InsertKeycard)
  
  self.events.on(SignalReadingKeycard) do(e: Args):
    self.delegate.switchToState(FlowStateType.ReadingKeycard)

proc startKeycardFlow*(self: Controller) =
  self.keycardService.startKeycardFlow()

proc cancelFlow*(self: Controller) =
  self.keycardService.cancelFlow()