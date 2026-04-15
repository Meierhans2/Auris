-- Allow CI to override via --generator-version=3 for x86-64-support-sourcesdk branch
newoption({
	trigger = "generator-version",
	description = "garrysmod_common PROJECT_GENERATOR_VERSION (2 = default, 3 = x86-64-support-sourcesdk)",
	value = "2"
})
PROJECT_GENERATOR_VERSION = tonumber(_OPTIONS["generator-version"]) or 2

newoption({
	trigger = "gmcommon",
	description = "Sets the path to the garrysmod_common (https://github.com/danielga/garrysmod_common) directory",
	value = "../garrysmod_common"
})

local gmcommon = assert(_OPTIONS.gmcommon or os.getenv("GARRYSMOD_COMMON"),
	"you didn't provide a path to your garrysmod_common (https://github.com/danielga/garrysmod_common) directory")
include(gmcommon)

CreateWorkspace({name = "auris", abi_compatible = false, path = "projects/" .. os.target() .. "/" .. _ACTION})
	CreateProject({serverside = true, source_path = "source", manual_files = false})
		warnings("Default")
		IncludeSDKCommon()
		IncludeSDKTier0()
		IncludeSDKTier1()
		IncludeSteamAPI()
		IncludeDetouring()
		IncludeScanning()

		-- whisper.cpp vendor files
		includedirs({
			"vendor/whisper.cpp/include",
			"vendor/whisper.cpp/ggml/include",
			"vendor/whisper.cpp/ggml/src",
			"vendor/whisper.cpp/ggml/src/ggml-cpu",
		})
		files({
			"vendor/whisper.cpp/src/whisper.cpp",
			"vendor/whisper.cpp/ggml/src/*.c",
			"vendor/whisper.cpp/ggml/src/*.cpp",
			"vendor/whisper.cpp/ggml/src/ggml-cpu/*.c",
			"vendor/whisper.cpp/ggml/src/ggml-cpu/*.cpp",
			"vendor/whisper.cpp/ggml/src/ggml-cpu/arch/x86/*.c",
			"vendor/whisper.cpp/ggml/src/ggml-cpu/arch/x86/*.cpp",
		})
		defines({
			"GGML_USE_CPU",
			"WHISPER_VERSION=\"1.0.0\"",
			"GGML_VERSION=\"1.0.0\"",
			"GGML_COMMIT=\"local\"",
			"NDEBUG",
		})

		-- Optimization for whisper.cpp — flags split by toolset
		optimize("Speed")
		vectorextensions("AVX2")

		filter("toolset:msc*")
			flags({"NoBufferSecurityCheck"})
			buildoptions({"/fp:fast", "/Ox", "/GL", "/arch:AVX2"})
			linkoptions({"/LTCG"})

		filter("toolset:gcc or clang")
			defines({"_GNU_SOURCE"})
			-- -ffast-math enables -ffinite-math-only which ggml explicitly forbids
			-- (vec.h line 1069 #errors on __FINITE_MATH_ONLY__). Use the safe subset instead.
			buildoptions({"-fno-math-errno", "-funsafe-math-optimizations", "-fno-rounding-math", "-fno-signaling-nans", "-O3", "-flto", "-mavx2", "-mfma", "-mf16c", "-fno-stack-protector"})
			linkoptions({"-flto"})

		filter({})

		-- Opus for decoding steam voice
		includedirs({"vendor/opus/include"})
		filter("platforms:x86")
			libdirs({path.getabsolute("vendor/opus/lib32")})
		filter("platforms:x86_64")
			libdirs({path.getabsolute("vendor/opus/lib64")})
		filter({})
		links({"opus"})

		-- Vulkan GPU backend
		local vulkan_sdk = os.getenv("VULKAN_SDK") or "C:/VulkanSDK/1.4.341.1"
		defines({"GGML_USE_VULKAN"})
		includedirs({
			"vendor/whisper.cpp/ggml/src/ggml-vulkan",
		})
		files({
			"vendor/whisper.cpp/ggml/src/ggml-vulkan/ggml-vulkan.cpp",
			"vendor/whisper.cpp/ggml/src/ggml-vulkan/ggml-vulkan-shaders.cpp",
		})

		-- Windows: Vulkan SDK headers + import lib
		filter("system:windows")
			includedirs({vulkan_sdk .. "/Include"})
			links({"vulkan-1"})

		-- premake does not support compound filter keys — split into separate filters
		filter({"system:windows", "platforms:x86"})
			libdirs({path.getabsolute("vendor/vulkan/lib32")})
			-- x86 stdcall decorates symbols with @N but the import lib has
			-- undecorated names. Map the 3 directly-linked Vulkan symbols.
			linkoptions({
				"/ALTERNATENAME:_vkCmdCopyBuffer@28=_vkCmdCopyBuffer",
				"/ALTERNATENAME:_vkGetPhysicalDeviceFeatures2@8=_vkGetPhysicalDeviceFeatures2",
				"/ALTERNATENAME:_vkGetInstanceProcAddr@8=_vkGetInstanceProcAddr",
			})

		filter({"system:windows", "platforms:x86_64"})
			libdirs({vulkan_sdk .. "/Lib"})

		-- Linux: system Vulkan loader
		-- VULKAN_HPP_TYPESAFE_CONVERSION enables implicit vk:: <-> Vk* handle conversions
		-- that ggml-vulkan.cpp relies on when mixing C and C++ Vulkan APIs.
		filter("system:linux")
			defines({"VULKAN_HPP_TYPESAFE_CONVERSION=1"})
			links({"vulkan"})

		filter({})
