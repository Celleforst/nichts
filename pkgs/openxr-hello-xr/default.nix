# Diagnostic tool: a minimal OpenXR client that actually creates a session
# and submits frames, unlike `monado-cli probe`/`test` which never touch the
# compositor's display-acquisition path. Used to check whether Monado's own
# compositor can drive the Rift directly, independent of SteamVR's vrcompositor.
{
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  python3,
  glslang,
  vulkan-headers,
  vulkan-loader,
  libGL,
  jsoncpp,
  xorg,
  wayland,
  wayland-protocols,
}:
stdenv.mkDerivation {
  pname = "openxr-hello-xr";
  version = "unstable-2026-09-17";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenXR-SDK-Source";
    rev = "3ed64d0f9bb680f24b80a085091e5c8fab38f7b7";
    fetchSubmodules = true;
    hash = "sha256-eUZEultLvLpm/ycVpYxwjibs1dK3qrF8KricIIxz9OE=";
  };

  nativeBuildInputs = [cmake pkg-config python3 glslang];
  buildInputs = [
    vulkan-headers
    vulkan-loader
    libGL
    jsoncpp
    xorg.libX11
    xorg.libXrandr
    xorg.libXxf86vm
    xorg.libXext
    wayland
    wayland-protocols
  ];

  cmakeFlags = [
    "-DBUILD_API_LAYERS=OFF"
    "-DBUILD_CONFORMANCE_TESTS=OFF"
  ];

  # Upstream's openxr.pc.in double-joins CMAKE_INSTALL_LIBDIR (already
  # absolute under nixpkgs) with exec_prefix; we only want the hello_xr
  # binary here, not a consumable pkg-config file, so just drop it before
  # validatePkgConfigFilesHook gets a chance to reject it.
  postInstall = ''
    rm -f "$out"/lib/pkgconfig/openxr.pc
  '';

  meta.mainProgram = "hello_xr";
}
