import NimQml
import io_interface
import view, controller
import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller

proc newModule*(events: EventEmitter, keycardService: keycard_service.Service):
  Module =
  result = Module()
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, keycardService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method init*(self: Module) =
  self.controller.init()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method switchToState*(self: Module, state: FlowStateType) =
  self.view.setFlowState(state)

method startKeycardFlow*(self: Module) =
  self.controller.startKeycardFlow()

method cancelFlow*(self: Module) =
  self.controller.cancelFlow()