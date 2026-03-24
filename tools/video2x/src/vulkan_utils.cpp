#include "vulkan_utils.h"

#include <cstring>
#include <iostream>
#include <string>
#include <vector>

#include <libvideo2x/logger_manager.h>

#ifndef VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME
#define VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME "VK_KHR_portability_enumeration"
#endif

#ifndef VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR
#define VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR 0x00000001
#endif

namespace {

const char* vulkan_result_name(VkResult result) {
    switch (result) {
        case VK_SUCCESS:
            return "VK_SUCCESS";
        case VK_NOT_READY:
            return "VK_NOT_READY";
        case VK_TIMEOUT:
            return "VK_TIMEOUT";
        case VK_EVENT_SET:
            return "VK_EVENT_SET";
        case VK_EVENT_RESET:
            return "VK_EVENT_RESET";
        case VK_INCOMPLETE:
            return "VK_INCOMPLETE";
        case VK_ERROR_OUT_OF_HOST_MEMORY:
            return "VK_ERROR_OUT_OF_HOST_MEMORY";
        case VK_ERROR_OUT_OF_DEVICE_MEMORY:
            return "VK_ERROR_OUT_OF_DEVICE_MEMORY";
        case VK_ERROR_INITIALIZATION_FAILED:
            return "VK_ERROR_INITIALIZATION_FAILED";
        case VK_ERROR_DEVICE_LOST:
            return "VK_ERROR_DEVICE_LOST";
        case VK_ERROR_MEMORY_MAP_FAILED:
            return "VK_ERROR_MEMORY_MAP_FAILED";
        case VK_ERROR_LAYER_NOT_PRESENT:
            return "VK_ERROR_LAYER_NOT_PRESENT";
        case VK_ERROR_EXTENSION_NOT_PRESENT:
            return "VK_ERROR_EXTENSION_NOT_PRESENT";
        case VK_ERROR_FEATURE_NOT_PRESENT:
            return "VK_ERROR_FEATURE_NOT_PRESENT";
        case VK_ERROR_INCOMPATIBLE_DRIVER:
            return "VK_ERROR_INCOMPATIBLE_DRIVER";
        default:
            return "VK_ERROR_UNKNOWN";
    }
}

void log_macos_portability_requirement(const std::string& detail) {
    video2x::logger()->error(
        "macOS Vulkan device enumeration requires portability enumeration via {} from a "
        "portability stack such as MoltenVK. {}",
        VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
        detail
    );
}

int enumerate_instance_extensions(std::vector<VkExtensionProperties>& extensions) {
    uint32_t extension_count = 0;
    VkResult result = vkEnumerateInstanceExtensionProperties(nullptr, &extension_count, nullptr);
    if (result != VK_SUCCESS) {
        video2x::logger()->error("Failed to enumerate Vulkan instance extensions.");
        return -1;
    }

    extensions.resize(extension_count);
    if (extension_count == 0) {
        return 0;
    }

    result = vkEnumerateInstanceExtensionProperties(nullptr, &extension_count, extensions.data());
    if (result != VK_SUCCESS) {
        video2x::logger()->error("Failed to retrieve Vulkan instance extensions.");
        return -1;
    }

    extensions.resize(extension_count);
    return 0;
}

bool has_instance_extension(
    const std::vector<VkExtensionProperties>& extensions, const char* extension_name
) {
    for (const auto& extension : extensions) {
        if (std::strcmp(extension.extensionName, extension_name) == 0) {
            return true;
        }
    }

    return false;
}

int create_vulkan_instance(VkInstance* instance) {
    std::vector<VkExtensionProperties> available_extensions;
    if (enumerate_instance_extensions(available_extensions) != 0) {
        return -1;
    }

    std::vector<const char*> enabled_extensions;
    VkInstanceCreateFlags create_flags = 0;

#ifdef __APPLE__
    if (!has_instance_extension(
            available_extensions, VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME
        )) {
        log_macos_portability_requirement(
            "The active Vulkan loader did not advertise the required instance extension."
        );
        return -1;
    }

    enabled_extensions.push_back(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME);
    create_flags |= VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
#endif

    VkInstanceCreateInfo create_info{};
    create_info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    create_info.flags = create_flags;
    create_info.enabledExtensionCount = static_cast<uint32_t>(enabled_extensions.size());
    create_info.ppEnabledExtensionNames =
        enabled_extensions.empty() ? nullptr : enabled_extensions.data();

    VkResult result = vkCreateInstance(&create_info, nullptr, instance);
    if (result != VK_SUCCESS) {
#ifdef __APPLE__
        log_macos_portability_requirement(
            "vkCreateInstance returned " + std::string(vulkan_result_name(result)) + " (" +
            std::to_string(result) +
            "). Verify that MoltenVK or another portability-enabled Vulkan loader is "
            "installed and discoverable."
        );
#else
        video2x::logger()->error("Failed to create Vulkan instance.");
#endif
        return -1;
    }

    return 0;
}

}  // namespace

static int enumerate_vulkan_devices(VkInstance* instance, std::vector<VkPhysicalDevice>& devices) {
    if (create_vulkan_instance(instance) != 0) {
        return -1;
    }

    // Enumerate physical devices
    uint32_t device_count = 0;
    VkResult result = vkEnumeratePhysicalDevices(*instance, &device_count, nullptr);
    if (result != VK_SUCCESS || device_count == 0) {
#ifdef __APPLE__
        if (result != VK_SUCCESS) {
            log_macos_portability_requirement(
                "vkEnumeratePhysicalDevices returned " + std::string(vulkan_result_name(result)) +
                " (" + std::to_string(result) +
                ") after enabling portability enumeration."
            );
        } else {
            log_macos_portability_requirement(
                "Vulkan instance creation succeeded but no portability-backed devices were "
                "visible."
            );
        }
#else
        video2x::logger()->error(
            "Failed to enumerate Vulkan physical devices or no devices available."
        );
#endif
        vkDestroyInstance(*instance, nullptr);
        return -1;
    }

    devices.resize(device_count);
    result = vkEnumeratePhysicalDevices(*instance, &device_count, devices.data());
    if (result != VK_SUCCESS) {
#ifdef __APPLE__
        log_macos_portability_requirement(
            "Failed to retrieve portability-backed Vulkan physical devices after enabling "
            "portability enumeration: " +
            std::string(vulkan_result_name(result)) + " (" + std::to_string(result) + ")."
        );
#else
        video2x::logger()->error("Failed to retrieve Vulkan physical devices.");
#endif
        vkDestroyInstance(*instance, nullptr);
        return -1;
    }

    return 0;
}

int list_vulkan_devices() {
    VkInstance instance;
    std::vector<VkPhysicalDevice> physical_devices;
    int result = enumerate_vulkan_devices(&instance, physical_devices);
    if (result != 0) {
        return result;
    }

    uint32_t device_count = static_cast<uint32_t>(physical_devices.size());

    // List Vulkan device information
    for (uint32_t i = 0; i < device_count; i++) {
        VkPhysicalDevice device = physical_devices[i];
        VkPhysicalDeviceProperties device_properties;
        vkGetPhysicalDeviceProperties(device, &device_properties);

        // Print Vulkan device ID and name
        std::cout << i << ". " << device_properties.deviceName << std::endl;
        std::cout << "\tType: ";
        switch (device_properties.deviceType) {
            case VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU:
                std::cout << "Integrated GPU";
                break;
            case VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU:
                std::cout << "Discrete GPU";
                break;
            case VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU:
                std::cout << "Virtual GPU";
                break;
            case VK_PHYSICAL_DEVICE_TYPE_CPU:
                std::cout << "CPU";
                break;
            default:
                std::cout << "Unknown";
                break;
        }
        std::cout << std::endl;

        // Print Vulkan API version
        std::cout << "\tVulkan API Version: " << VK_VERSION_MAJOR(device_properties.apiVersion)
                  << "." << VK_VERSION_MINOR(device_properties.apiVersion) << "."
                  << VK_VERSION_PATCH(device_properties.apiVersion) << std::endl;

        // Print driver version
        std::cout << "\tDriver Version: " << VK_VERSION_MAJOR(device_properties.driverVersion)
                  << "." << VK_VERSION_MINOR(device_properties.driverVersion) << "."
                  << VK_VERSION_PATCH(device_properties.driverVersion) << std::endl;

        // Print device ID
        std::cout << "\tDevice ID: " << std::hex << std::showbase << device_properties.deviceID
                  << std::dec << std::endl;
    }

    // Clean up Vulkan instance
    vkDestroyInstance(instance, nullptr);
    return 0;
}

int get_vulkan_device_prop(uint32_t vk_device_index, VkPhysicalDeviceProperties* dev_props) {
    if (dev_props == nullptr) {
        video2x::logger()->error("Invalid device properties pointer.");
        return -1;
    }

    VkInstance instance;
    std::vector<VkPhysicalDevice> devices;
    int result = enumerate_vulkan_devices(&instance, devices);
    if (result != 0) {
        return result;
    }

    uint32_t device_count = static_cast<uint32_t>(devices.size());

    // Check if the Vulkan device ID is valid
    if (vk_device_index >= device_count) {
        vkDestroyInstance(instance, nullptr);
        return -2;
    }

    // Get device properties for the specified Vulkan device ID
    vkGetPhysicalDeviceProperties(devices[vk_device_index], dev_props);

    // Clean up Vulkan instance
    vkDestroyInstance(instance, nullptr);

    return 0;
}
