import NimQml, json, os, chronicles # strutils, , json_serialization
import keycard_go
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../constants as status_const

type FlowType {.pure.} = enum
  GetAppInfo = 0
  RecoverAccount
  LoadAccount
  Login
  ExportPublic
  Sign
  ChangePIN
  ChangePUK
  ChangePairing
  UnpairThis
  UnpairOthers
  DeleteAccountAndUnpair

const CheckForAKeycardReaderEveryMilliseconds = 5 * 1000 # 5 seconds

const KeycardResponseKeyType = "type"
const KeycardResponseKeyEvent = "event"

const KeycardKeycardFlowResult = "keycard.flow-result"
const KeycardInsertCard = "keycard.action.insert-card"
const KeycardCardInserted = "keycard.action.card-inserted"
const KeycardSwapCard = "keycard.action.swap-card"
const KeycardEnterPairing = "keycard.action.enter-pairing"
const KeycardEnterPIN = "keycard.action.enter-pin"
const KeycardEnterPUK = "keycard.action.enter-puk"
const KeycardEnterNewPair = "keycard.action.enter-new-pairing"
const KeycardEnterNewPIN = "keycard.action.enter-new-pin"
const KeycardEnterNewPUK = "keycard.action.enter-new-puk"
const KeycardEnterTXHash = "keycard.action.enter-tx-hash"
const KeycardEnterPath = "keycard.action.enter-bip44-path"
const KeycardEnterMnemonic = "keycard.action.enter-mnemonic"

const KeycardErrorKey = "error"
const KeycardErrorOK = "ok"
const KeycardErrorCancel = "cancel"
const KeycardErrorConnection = "connection-error"
const KeycardErrorUnknownFlow = "unknown-flow"
const KeycardErrorNotAKeycard = "not-a-keycard"
const KeycardErrorNoKeys = "no-keys"
const KeycardErrorHasKeys = "has-keys"
const KeycardErrorRequireInit = "require-init"
const KeycardErrorPairing = "pairing"
const KeycardErrorUnblocking = "unblocking"
const KeycardErrorSigning = "signing"
const KeycardErrorExporting = "exporting"
const KeycardErrorChanging = "changing-credentials"
const KeycardErrorLoading = "loading-keys"

const SignalPluginKeycardReader* = "pluginKeycardReader"
const SignalInsertKeycard* = "insertKeycard"
const SignalReadingKeycard* = "readingKeycard"

logScope:
  topics = "keycard-service"

include async_tasks
include ../../common/json_utils

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    closingApp: bool
    cancelFlow: bool 

  #################################################
  # Forward declaration section
  proc startCheckingForAKeycardReader(self: Service)

  #################################################

  proc setup(self: Service) =
    self.QObject.setup

  proc delete*(self: Service) =
    self.closingApp = true
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    new(result)
    result.setup()
    result.events = events
    result.threadpool = threadpool
    result.closingApp = false
    result.cancelFlow = false

  proc init*(self: Service) =
    discard

  proc processSignal(self: Service, signal: string) =
    var jsonSignal: JsonNode
    try:
      jsonSignal = signal.parseJson
    except:
      error "Invalid signal received", data = signal
      return

    var typeObj, eventObj: JsonNode
    if(not jsonSignal.getProp(KeycardResponseKeyType, typeObj) or 
      not jsonSignal.getProp(KeycardResponseKeyEvent, eventObj)):
      return
    
    let flowType = typeObj.getStr
    let error = eventObj{KeycardErrorKey}.getStr

    if(flowType == KeycardKeycardFlowResult and error == KeycardErrorConnection):
      self.startCheckingForAKeycardReader()
      self.events.emit(SignalPluginKeycardReader, Args())
      return
    
    if(flowType == KeycardInsertCard):
      self.events.emit(SignalInsertKeycard, Args())
      return

    if(flowType == KeycardCardInserted):
      self.events.emit(SignalReadingKeycard, Args())
      return

  proc receiveKeycardSignal(self: Service, signal: string) {.slot.} =
    self.processSignal(signal)

  proc checkForAKeycardReader*(self: Service, response: string) {.slot.} =
    if(self.closingApp or self.cancelFlow):
      return
    let payload = "{}"
    let startFlowResp = keycard_go.keycardStartFlow(FlowType.GetAppInfo.int, payload)
    debug "get app info result: ", startFlowResp    

  proc startCheckingForAKeycardReader(self: Service) =
    if(self.closingApp or self.cancelFlow):
      return

    let arg = TimerTaskArg(
      tptr: cast[ByteAddress](timerTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "checkForAKeycardReader",
      timeoutInMilliseconds: CheckForAKeycardReaderEveryMilliseconds
    )
    self.threadpool.start(arg)

  proc startKeycardFlow*(self: Service) =
    self.cancelFlow = false
    debug "init keycard using ", pairingsJson=status_const.ROOTKEYCARDDIR
    let initResp = keycard_go.keycardInitFlow(status_const.ROOTKEYCARDDIR)
    debug "initialization result: ", initResp
    self.checkForAKeycardReader("")

  proc cancelFlow*(self: Service) =
    self.cancelFlow = true