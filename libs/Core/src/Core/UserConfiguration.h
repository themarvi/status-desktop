#pragma once

#include <filesystem>

namespace Status::Core {

namespace fs = std::filesystem;

struct UserConfiguration
{
    fs::path userDataFolder;
};

using UserConfigurationPtr = std::shared_ptr<UserConfiguration>;

}
