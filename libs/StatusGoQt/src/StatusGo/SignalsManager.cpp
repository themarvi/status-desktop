#include "SignalsManager.h"

#include <QtConcurrent>

#include "libstatus.h"

namespace Status::StatusGo {

std::map<QString, SignalType> SignalsManager::signalMap;

// TODO: make me thread safe
SignalsManager* SignalsManager::instance()
{
    static SignalsManager manager;
    return &manager;
}

SignalsManager::SignalsManager()
    : QObject(nullptr)
{
    SetSignalEventCallback((void*)&SignalsManager::signalCallback);

    signalMap = {
        {"node.ready", SignalType::NodeReady},
        {"node.started", SignalType::NodeStarted},
        {"node.stopped", SignalType::NodeStopped},
        {"node.login", SignalType::NodeLogin},
        {"node.crashed", SignalType::NodeCrashed},

        {"discovery.started", SignalType::DiscoveryStarted},
        {"discovery.stopped", SignalType::DiscoveryStopped},
        {"discovery.summary", SignalType::DiscoverySummary},

        {"mailserver.changed", SignalType::MailserverChanged},
        {"mailserver.available", SignalType::MailserverAvailable},

        {"history.request.started", SignalType::HistoryRequestStarted},
        {"history.request.batch.processed", SignalType::HistoryRequestBatchProcessed},
        {"history.request.completed", SignalType::HistoryRequestCompleted}
    };
}

SignalsManager::~SignalsManager()
{
}

void SignalsManager::processSignal(const QString& statusSignal)
{
    try
    {
        QJsonParseError json_error;
        const QJsonDocument signalEventDoc(QJsonDocument::fromJson(statusSignal.toUtf8(), &json_error));
        if(json_error.error != QJsonParseError::NoError)
        {
            qWarning() << "Invalid signal received";
            return;
        }
        decode(signalEventDoc.object());
    }
    catch(const std::exception& e)
    {
        qWarning() << "Error decoding signal, err: ", e.what();
        return;
    }
}

void SignalsManager::decode(const QJsonObject& signalEvent)
{
    SignalType signalType(Unknown);
    auto signalName = signalEvent["type"].toString();
    if(!signalMap.contains(signalName))
    {
        qWarning() << "Unknown signal received: " << signalName;
        return;
    }

    signalType = signalMap[signalName];
    auto signalError = signalEvent["event"]["error"].toString();

    switch(signalType)
    {
    // TODO: create extractor functions like in nim
    case NodeLogin:
        emit nodeLogin(signalError);
        break;
    case NodeReady:
        emit nodeReady(signalError);
        break;
    case NodeStarted:
        emit nodeStarted(signalError);
        break;
    case NodeStopped:
        emit nodeStopped(signalError);
        break;
    case NodeCrashed:
        qWarning() << "node.crashed, error: " << signalError;
        emit nodeCrashed(signalError);
        break;
    case DiscoveryStarted:
        emit discoveryStarted(signalError);
        break;
    case DiscoveryStopped:
        emit discoveryStopped(signalError);
        break;
    case DiscoverySummary:
        emit discoverySummary(signalEvent["event"].toArray().count(), signalError);
        break;
    case MailserverChanged:
        emit mailserverChanged(signalError);
        break;
    case MailserverAvailable:
        emit mailserverAvailable(signalError);
        break;
    case HistoryRequestStarted:
        emit historyRequestStarted(signalError);
        break;
    case HistoryRequestBatchProcessed:
        emit historyRequestBatchProcessed(signalError);
        break;
    case HistoryRequestCompleted:
        emit historyRequestCompleted(signalError);
        break;
    case Unknown: assert(false); break;
    }
}

static void aTest(const QString &string) {

}

void SignalsManager::signalCallback(const char* data)
{
    // TODO: overkill, use a message broker
    auto dataStrPtr = std::make_shared<QString>(data);
    QFuture<void> future = QtConcurrent::run([dataStrPtr](){
        SignalsManager::instance()->processSignal(*dataStrPtr);
    });
}

}
