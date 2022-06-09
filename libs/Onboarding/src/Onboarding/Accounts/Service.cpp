#include "Service.h"

#include "StatusGo/Accounts/Accounts.h"
#include "StatusGo/General.h"
#include "StatusGo/Utils.h"

#include <optional>


std::optional<QString>
getDataFromFile(fs::path path)
{
    QFile jsonFile(QString::fromStdString(path.string()));
    if(!jsonFile.open(QIODevice::ReadOnly))
    {
        qDebug() << "unable to open" << path.filename().c_str() << " for reading";
        return std::nullopt;
    }

    QString data = jsonFile.readAll();
    jsonFile.close();
    return data;
}

namespace Status::Accounts
{

namespace StatusGo = Status::StatusGo;
namespace Utils = Status::StatusGo::Utils;

Service::Service()
    : m_isFirstTimeAccountLogin(false)
{
}

bool Service::init(const fs::path& statusgoDataDir)
{
    m_statusgoDataDir = statusgoDataDir;
    auto response = StatusGo::Accounts::generateAddresses(Constants::General::AccountDefaultPaths);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return false;
    }

    foreach(const auto& genAddressObj, response.result)
    {
        auto gAcc = GeneratedAccountDto::toGeneratedAccountDto(genAddressObj.toObject());
        gAcc.alias = generateAlias(gAcc.derivedAccounts.whisper.publicKey);
        gAcc.identicon = generateIdenticon(gAcc.derivedAccounts.whisper.publicKey);
        m_generatedAccounts.append(std::move(gAcc));
    }
    return true;
}

QVector<AccountDto> Service::openAndListAccounts()
{
    auto response = StatusGo::Accounts::openAccounts(m_statusgoDataDir.c_str());
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QVector<AccountDto>();
    }

    QJsonArray multiAccounts = response.result;
    QVector<AccountDto> result;
    foreach(const auto& value, multiAccounts)
    {
        result << AccountDto::toAccountDto(value.toObject());
    }
    return result;
}

const QVector<GeneratedAccountDto>& Service::generatedAccounts() const
{
    return m_generatedAccounts;
}

bool Service::setupAccountAndLogin(const QString &accountId, const QString &password, const QString &displayName)
{
    QString installationId(QUuid::createUuid().toString(QUuid::WithoutBraces));
    QJsonObject accountData(getAccountDataForAccountId(accountId, displayName));

    if(!setKeyStoreDir(accountData.value("key-uid").toString()))
        return false;

    QJsonArray subAccountData(getSubaccountDataForAccountId(accountId, displayName));
    QJsonObject settings(getAccountSettings(accountId, installationId, displayName));
    QJsonObject nodeConfig(getDefaultNodeConfig(installationId));

    QString hashedPassword(Utils::hashString(password));

    // This initialize the DB if first time running. Required for storing accounts
    if(StatusGo::Accounts::openAccounts(m_statusgoDataDir.c_str()).containsError())
        return false;

    Service::storeDerivedAccounts(accountId, hashedPassword, Constants::General::AccountDefaultPaths);

    m_loggedInAccount = saveAccountAndLogin(hashedPassword, accountData, subAccountData, settings, nodeConfig);

    return getLoggedInAccount().isValid();
}

const AccountDto& Service::getLoggedInAccount() const
{
    return m_loggedInAccount;
}

const GeneratedAccountDto& Service::getImportedAccount() const
{
    return m_importedAccount;
}

bool Service::isFirstTimeAccountLogin() const
{
    return m_isFirstTimeAccountLogin;
}

bool Service::setKeyStoreDir(const QString &key)
{
    auto keyStoreDir = m_statusgoDataDir / m_keyStoreDirName / key.toStdString();
    auto response = StatusGo::General::initKeystore(keyStoreDir.c_str());
    return !response.containsError();
}

QString Service::validateMnemonic(const QString& mnemonic)
{
    // TODO:
    return "";
}

bool Service::importMnemonic(const QString& mnemonic)
{
    // TODO:
    return false;
}

QString Service::login(AccountDto account, const QString& password)
{
    QString hashedPassword(Utils::hashString(password));

    QString thumbnailImage;
    QString largeImage;

    foreach(const Image& img, account.images)
    {
        if(img.imgType == "thumbnail")
        {
            thumbnailImage = img.uri;
        }
        else if(img.imgType == "large")
        {
            largeImage = img.uri;
        }
    }

    auto response = StatusGo::Accounts::login(account.name, account.keyUid, hashedPassword, account.identicon,
                                             thumbnailImage, largeImage);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    m_loggedInAccount = std::move(account);

    return QString();
}

void Service::clear()
{
    m_generatedAccounts.clear();
    m_loggedInAccount = AccountDto();
    m_importedAccount = GeneratedAccountDto();
    m_isFirstTimeAccountLogin = false;
}

QString Service::generateAlias(const QString& publicKey)
{
    auto response = StatusGo::Accounts::generateAlias(publicKey);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    return response.result;
}

QString Service::generateIdenticon(const QString& publicKey)
{
    auto response = StatusGo::Accounts::generateIdenticon(publicKey);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    return response.result;
}

//bool Service::verifyAccountPassword(const QString& account, const QString& password)
//{
//    // TODO:
//    return false;
//}

DerivedAccounts Service::storeDerivedAccounts(const QString& accountId, const QString& hashedPassword,
                                              const QVector<QString>& paths)
{
    auto response = StatusGo::Accounts::storeDerivedAccounts(accountId, hashedPassword, paths);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return DerivedAccounts();
    }
    return DerivedAccounts::toDerivedAccounts(response.result);
}

StoredAccountDto Service::storeAccount(const QString& accountId, const QString& hashedPassword)
{
    auto response = StatusGo::Accounts::storeAccount(accountId, hashedPassword);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return StoredAccountDto();
    }
    return toStoredAccountDto(response.result);
}

AccountDto Service::saveAccountAndLogin(const QString& hashedPassword, const QJsonObject& account,
                                        const QJsonArray& subaccounts, const QJsonObject& settings,
                                        const QJsonObject& config)
{
    if(!StatusGo::Accounts::saveAccountAndLogin(hashedPassword, account, subaccounts, settings, config)) {
        qWarning() << "Failed saving acccount" << account.value("name");
        return AccountDto();
    }

    m_isFirstTimeAccountLogin = true;
    return AccountDto::toAccountDto(account);
}

QJsonObject Service::prepareAccountJsonObject(const GeneratedAccountDto& account, const QString &displayName) const
{
    return QJsonObject{{"name", displayName.isEmpty() ? account.alias : displayName},
        {"address", account.address},
        {"photo-path", account.identicon},
        {"identicon", account.identicon},
        {"key-uid", account.keyUid},
        {"keycard-pairing", QJsonValue()}};
}

QJsonObject Service::getAccountDataForAccountId(const QString &accountId, const QString &displayName) const
{

    foreach(const GeneratedAccountDto& acc, m_generatedAccounts)
    {
        if(acc.id == accountId)
        {
            return Service::prepareAccountJsonObject(acc, displayName);
        }
    }

    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return Service::prepareAccountJsonObject(m_importedAccount, displayName);
        }
    }

    qDebug() << "account not found";
    return QJsonObject();
}

QJsonArray Service::prepareSubaccountJsonObject(const GeneratedAccountDto& account, const QString &displayName) const
{
    return QJsonArray{
        QJsonObject{
            {"public-key", account.derivedAccounts.defaultWallet.publicKey},
            {"address", account.derivedAccounts.defaultWallet.address},
            {"color", "#4360df"},
            {"wallet", true},
            {"path", Constants::General::PathDefaultWallet},
            {"name", "Status account"}
        },
        QJsonObject{
            {"public-key", account.derivedAccounts.whisper.publicKey},
            {"address", account.derivedAccounts.whisper.address},
            {"path", Constants::General::PathWhisper},
            {"name", displayName.isEmpty() ? account.alias : displayName},
            {"identicon", account.identicon},
            {"chat", true}
        }
    };
}

QJsonArray Service::getSubaccountDataForAccountId(const QString& accountId, const QString &displayName) const
{
    foreach(const GeneratedAccountDto& acc, m_generatedAccounts)
    {
        if(acc.id == accountId)
        {
            return prepareSubaccountJsonObject(acc, displayName);
        }
    }
    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return prepareSubaccountJsonObject(m_importedAccount, displayName);
        }
    }

    // TODO: Is this expected? Have proper error propagation, otherwise throw
    qDebug() << "account not found";
    return QJsonArray();
}

QString Service::generateSigningPhrase(const int count) const
{
    QStringList words;
    for(int i = 0; i < count; i++)
    {
        words.append(Constants::SigningPhrases[QRandomGenerator::global()->bounded(
                    static_cast<int>(Constants::SigningPhrases.size()))]);
    }
    return words.join(" ");
}

QJsonObject Service::prepareAccountSettingsJsonObject(const GeneratedAccountDto& account,
                                                      const QString& installationId,
                                                      const QString& displayName) const
{
    try {
        auto templateDefaultNetworksJson = getDataFromFile(":/Status/StaticConfig/default-networks.json").value();
        auto infuraKey = getDataFromFile(":/Status/StaticConfig/infura_key").value();

        QString defaultNetworksContent = templateDefaultNetworksJson.replace("%INFURA_KEY%", infuraKey);
        QJsonArray defaultNetworksJson = QJsonDocument::fromJson(defaultNetworksContent.toUtf8()).array();

        return QJsonObject{
            {"key-uid", account.keyUid},
            {"mnemonic", account.mnemonic},
            {"public-key", account.derivedAccounts.whisper.publicKey},
            {"name", account.alias},
            {"display-name", displayName},
            {"address", account.address},
            {"eip1581-address", account.derivedAccounts.eip1581.address},
            {"dapps-address", account.derivedAccounts.defaultWallet.address},
            {"wallet-root-address", account.derivedAccounts.walletRoot.address},
            {"preview-privacy?", true},
            {"signing-phrase", generateSigningPhrase(3)},
            {"log-level", "INFO"},
            {"latest-derived-path", 0},
            {"networks/networks", defaultNetworksJson},
            {"currency", "usd"},
            {"identicon", account.identicon},
            {"waku-enabled", true},
            {"wallet/visible-tokens", {
                    {Constants::General::DefaultNetworkName, QJsonArray{"SNT"}}
                }
            },
            {"appearance", 0},
            {"networks/current-network", Constants::General::DefaultNetworkName},
            {"installation-id", installationId}
        };
    } catch (std::bad_optional_access) {
        return QJsonObject();
    }
}

QJsonObject Service::getAccountSettings(const QString& accountId, const QString& installationId, const QString &displayName) const
{
    foreach(const GeneratedAccountDto& acc, m_generatedAccounts)

        if(acc.id == accountId)
        {
            return Service::prepareAccountSettingsJsonObject(acc, installationId, displayName);
        }

    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return Service::prepareAccountSettingsJsonObject(m_importedAccount, installationId, displayName);
        }
    }

    // TODO: Is this expected? Have proper error propagation, otherwise throw
    qDebug() << "account not found";
    return QJsonObject();
}

QJsonArray getNodes(const QJsonObject& fleet, const QString& nodeType)
{
    auto nodes = fleet[nodeType].toObject();
    QJsonArray result;
    for(auto it = nodes.begin(); it != nodes.end(); ++it)
        result << *it;
    return result;
}

QJsonObject Service::getDefaultNodeConfig(const QString& installationId) const
{
    try {
        auto templateNodeConfigJsonStr = getDataFromFile(":/Status/StaticConfig/node-config.json").value();
        auto fleetJson = getDataFromFile(":/Status/StaticConfig/fleets.json").value();
        auto infuraKey = getDataFromFile(":/Status/StaticConfig/infura_key").value();

        auto nodeConfigJsonStr = templateNodeConfigJsonStr.replace("%INSTALLATIONID%", installationId)
                .replace("%INFURA_KEY%", infuraKey);
        QJsonObject nodeConfigJson = QJsonDocument::fromJson(nodeConfigJsonStr.toUtf8()).object();
        QJsonObject clusterConfig = nodeConfigJson["ClusterConfig"].toObject();

        QJsonObject fleetsJson = QJsonDocument::fromJson(fleetJson.toUtf8()).object()["fleets"].toObject();
        auto fleet = fleetsJson[Constants::Fleet::Prod].toObject();

        clusterConfig["Fleet"] = Constants::Fleet::Prod;
        clusterConfig["BootNodes"] = getNodes(fleet, Constants::FleetNodes::Bootnodes);
        clusterConfig["TrustedMailServers"] = getNodes(fleet, Constants::FleetNodes::Mailservers);
        clusterConfig["StaticNodes"] = getNodes(fleet, Constants::FleetNodes::Whisper);
        clusterConfig["RendezvousNodes"] = getNodes(fleet, Constants::FleetNodes::Rendezvous);
        clusterConfig["RelayNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
        clusterConfig["StoreNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
        clusterConfig["FilterNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
        clusterConfig["LightpushNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);

        nodeConfigJson["ClusterConfig"] = clusterConfig;

        return nodeConfigJson;
    } catch (std::bad_optional_access) {
        return QJsonObject();
    }
}

}
