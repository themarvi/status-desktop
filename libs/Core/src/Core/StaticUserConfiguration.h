#pragma once

#include <memory>

namespace Status::Core {

class UserConfiguration;

const std::shared_ptr<UserConfiguration> getStaticConfiguration();
void installStaticConfiguration(std::shared_ptr<UserConfiguration> newConfig);

std::shared_ptr<UserConfiguration> generateReleaseConfiguration();

}
