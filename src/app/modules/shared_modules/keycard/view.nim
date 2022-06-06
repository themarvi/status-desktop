import NimQml
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      flowState: FlowStateType

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.flowState = FlowStateType.PluginKeycard

  proc flowStateChanged*(self: View) {.signal.}
  proc setFlowState*(self: View, value: FlowStateType) =
    if self.flowState == value:
      return
    self.flowState = value
    self.flowStateChanged()
  proc getFlowState*(self: View): string {.slot.} =
    return $self.flowState
  QtProperty[string] flowState:
    read = getFlowState
    notify = flowStateChanged

  proc startKeycardFlow*(self: View) {.slot.} =
    self.delegate.startKeycardFlow()

  proc cancelFlow*(self: View) {.slot.} =
    self.delegate.cancelFlow()