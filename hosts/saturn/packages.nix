{pkgs, ...}: let
  python-packages = ps:
    with ps; [
      pandas
      numpy
      opencv4
      ipython
    ];

  qgroundcontrol-v5 = let
    appimageContents = pkgs.appimageTools.extractType2 {
      pname = "qgroundcontrol";
      version = "5.0.8";
      src = pkgs.fetchurl {
        url = "https://github.com/mavlink/qgroundcontrol/releases/download/v5.0.8/QGroundControl-x86_64.AppImage";
        hash = "sha256-BpacZ+9Y6gY97wqCcUR6HMOFQ4xKffNoEzFbRHUUZzc=";
      };
    };
  in
    pkgs.appimageTools.wrapType2 {
      pname = "qgroundcontrol";
      version = "5.0.8";
      src = pkgs.fetchurl {
        url = "https://github.com/mavlink/qgroundcontrol/releases/download/v5.0.8/QGroundControl-x86_64.AppImage";
        hash = "sha256-BpacZ+9Y6gY97wqCcUR6HMOFQ4xKffNoEzFbRHUUZzc=";
      };
      extraInstallCommands = ''
        install -Dm444 ${appimageContents}/org.mavlink.qgroundcontrol.desktop \
          $out/share/applications/org.mavlink.qgroundcontrol.desktop
        substituteInPlace $out/share/applications/org.mavlink.qgroundcontrol.desktop \
          --replace "Exec=QGroundControl" "Exec=qgroundcontrol"
        install -Dm444 ${appimageContents}/usr/share/icons/hicolor/128x128/apps/QGroundControl.png \
          $out/share/icons/hicolor/128x128/apps/QGroundControl.png
      '';
      meta = with pkgs.lib; {
        description = "Provides full ground station support and configuration for the PX4 and APM Flight Stacks";
        homepage = "https://qgroundcontrol.com/";
        license = licenses.gpl3Plus;
        platforms = platforms.linux;
        mainProgram = "QGroundControl";
      };
    };

  openvsp = let
    version = "3.51.3";
    src = pkgs.fetchFromGitHub {
      owner = "OpenVSP";
      repo = "OpenVSP";
      rev = "OpenVSP_${version}";
      hash = "sha256-mwMxTIHtEbVfzYD3/osqzptIPJ2lgCswSm8DQfcX8Q0=";
    };

    # OpenVSP's own "Libraries" superbuild bundles most of its dependencies as
    # source archives committed directly in the repo (Libraries/*.zip) and
    # builds them from source via CMake ExternalProject - no network needed.
    # We only point it at nixpkgs for the two libs upstream's own Linux build
    # instructions recommend using the system copy of (glew, libxml2).
    libFlags = [
      "-DVSP_USE_SYSTEM_ADEPT2=false"
      "-DVSP_USE_SYSTEM_CLIPPER2=false"
      "-DVSP_USE_SYSTEM_CMINPACK=false"
      "-DVSP_USE_SYSTEM_CODEELI=false"
      "-DVSP_USE_SYSTEM_CPPTEST=false"
      "-DVSP_USE_SYSTEM_DELABELLA=false"
      "-DVSP_USE_SYSTEM_EIGEN=false"
      "-DVSP_USE_SYSTEM_EXPRPARSE=false"
      "-DVSP_USE_SYSTEM_FLTK=false"
      "-DVSP_USE_SYSTEM_GLEW=true"
      "-DVSP_USE_SYSTEM_GLM=false"
      "-DVSP_USE_SYSTEM_LIBIGES=false"
      "-DVSP_USE_SYSTEM_LIBXML2=true"
      "-DVSP_USE_SYSTEM_OPENABF=false"
      "-DVSP_USE_SYSTEM_PINOCCHIO=false"
      "-DVSP_USE_SYSTEM_STEPCODE=false"
      "-DVSP_USE_SYSTEM_TRIANGLE=false"
    ];
  in
    pkgs.stdenv.mkDerivation {
      pname = "openvsp";
      inherit version src;

      nativeBuildInputs = with pkgs; [cmake pkg-config unzip zip];
      buildInputs = with pkgs; [
        libxml2
        glew
        libGL
        libGLU
        fontconfig
        freetype
        xorg.libX11
        xorg.libXext
        xorg.libXft
        xorg.libXinerama
        xorg.libXcursor
        libxfixes
        libxrender
      ];

      dontUseCmakeConfigure = true;
      enableParallelBuilding = true;

      # STEPCODE's bundled CMakeLists.txt unconditionally does
      # `CMAKE_POLICY(SET CMP0026 OLD)`; recent CMake has dropped OLD support
      # for that policy entirely and hard-errors on it, which fails the whole
      # superbuild's "configure" step. Patch it out of the zip in place
      # (no URL_HASH is checked against it, so this is safe).
      postPatch = ''
        (
          cd Libraries
          zipfile=$(ls stepcode-*.zip)
          dir=$(unzip -Z1 "$zipfile" | head -1 | cut -d/ -f1)
          unzip -q "$zipfile"
          sed -i '/CMAKE_POLICY(SET CMP0026 OLD)/d' "$dir"/CMakeLists.txt
          rm "$zipfile"
          zip -qr "$zipfile" "$dir"
          rm -rf "$dir"
        )

        # External_OpenABF.cmake points Eigen3_DIR at the Eigen install
        # prefix, but Eigen's CMake config actually installs under
        # <prefix>/share/eigen3/cmake. find_package(Eigen3 CONFIG) requires
        # Eigen3_DIR to point directly at that dir, so OPENABF's configure
        # step can't find it as-is.
        sed -i 's|Eigen3_DIR=''${EIGEN_INSTALL_DIR}"|Eigen3_DIR=''${EIGEN_INSTALL_DIR}/share/eigen3/cmake"|' \
          Libraries/cmake/External_OpenABF.cmake

        # main.cpp's CheckVersionNumber() phones home to openvsp.org (posts a
        # hash of $PWD, checks for a newer release) using libxml2's nanohttp
        # client, which upstream libxml2 dropped entirely in recent releases
        # (nixpkgs' libxml2 no longer declares xmlNanoHTTP*). Stub the body
        # out instead of trying to resurrect a removed module - a packaged
        # build silently phoning home on launch isn't desirable anyway.
        sed -i '/xmlNanoHTTPInit();/,/xmlNanoHTTPCleanup();/d' src/vsp/main.cpp
      '';

      # The Libraries/ superbuild extracts bundled zip archives (e.g.
      # angelscript-*.zip) that contain non-ASCII filenames. Nix's sandboxed
      # build env has no locale set, so libarchive can't decode UTF-8
      # pathnames and CMake's extraction step fails.
      LC_ALL = "C.UTF-8";

      # Some bundled sub-libraries (e.g. STEPCODE) ship a cmake_minimum_required
      # older than 3.5, which recent CMake refuses outright. They're built via
      # nested ExternalProject cmake invocations we don't control the flags of,
      # so set the policy floor via env (read by CMake >= 3.31) instead.
      CMAKE_POLICY_VERSION_MINIMUM = "3.5";

      # STEPCODE's bundled C (express parser etc.) relies on old-style
      # unprototyped function declarations (`foo()` meaning "unspecified
      # args" pre-C23). GCC 15 defaults to gnu23, where `()` means "no args",
      # turning every such call into a hard error. Pin C (not C++) sources
      # back to gnu17 for the whole superbuild via env, since nested
      # ExternalProject cmake/make invocations inherit it.
      CFLAGS = "-std=gnu17";

      buildPhase = ''
        runHook preBuild

        mkdir -p buildlibs buildvsp

        (
          cd buildlibs
          cmake ${pkgs.lib.concatStringsSep " " libFlags} \
            -DCMAKE_BUILD_TYPE=Release \
            ../Libraries
          make -j''${NIX_BUILD_CORES:-1}
        )

        (
          cd buildvsp
          cmake \
            -DVSP_LIBRARY_PATH=$(pwd)/../buildlibs \
            -DCMAKE_BUILD_TYPE=Release \
            -DVSP_NO_API_WRAPPERS=true \
            -DVSP_NO_DOC=true \
            -DCMAKE_INSTALL_PREFIX=$out/opt/openvsp \
            ../src
          make -j''${NIX_BUILD_CORES:-1}
        )

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        make -C buildvsp install

        mkdir -p $out/bin
        for f in "$out"/opt/openvsp/*; do
          if [ -f "$f" ] && [ -x "$f" ]; then
            ln -s "$f" "$out/bin/$(basename "$f")"
          fi
        done

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Parametric aircraft geometry tool";
        homepage = "https://openvsp.org/";
        license = licenses.nasa13;
        platforms = platforms.linux;
        mainProgram = "vsp";
      };
    };
in {
  environment.systemPackages = with pkgs; [
    (python3.withPackages python-packages)
    vlc
    material-icons
    material-design-icons
    libreoffice
    spotify
    hyprland-protocols
    xrandr
    wine
    # easyeffects
    nautilus
    alsa-utils
    foot
    gimp
    imagemagick
    glow # cli markdown viewer
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_AT
    tuigreet
    freecad
    openvsp
    claude-code
    ansible
    mtr
    tcpdump
    wireshark
    pkg-config
    autoconf
    automake
    foxglove-studio
    qgroundcontrol-v5
    slack
    remmina
    bambu-studio
    orca-slicer
    prusa-slicer
    virt-manager
    xournalpp
    # jmtpfs
    rquickshare
    expresslrs-configurator
    moonlight-qt
    distrobox
  ];
}
