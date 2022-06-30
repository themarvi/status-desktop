#include "StaticUserConfiguration.h"

#include "UserConfiguration.h"

#include <QStandardPaths>

#include <string>

using namespace std::string_literals;

namespace Status::Core {

auto dataSubfolder = "Status"s;

static UserConfigurationPtr staticConfiguration;

void installStaticConfiguration(std::shared_ptr<UserConfiguration> newConfig)
{
    staticConfiguration = newConfig;
}

const std::shared_ptr<UserConfiguration> getStaticConfiguration()
{
    return staticConfiguration;
}

UserConfigurationPtr generateReleaseConfiguration()
{
    auto conf = std::make_shared<UserConfiguration>();
    auto userConfigFolder = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation).toStdString();
    conf->userDataFolder = fs::path(userConfigFolder)/dataSubfolder;
    return conf;
}

}
