{ lib
, fetchgit
, meson
, ninja
, pkgconfig
, python3
, gtk3
, gst_all_1
, libsecret
, libsoup
, appstream-glib
, desktop-file-utils
, totem-pl-parser
, gobject-introspection
, wrapGAppsHook
, lastFMSupport ? true
, youtubeSupport ? true
}:

python3.pkgs.buildPythonApplication rec  {
  pname = "lollypop";
  version = "1.2.16";

  format = "other";
  doCheck = false;

  src = fetchgit {
    url = "https://gitlab.gnome.org/World/lollypop";
    rev = "refs/tags/${version}";
    fetchSubmodules = true;
    sha256 = "0rl4a5npjh5sm3kih11cs2j7ik894nlygllbw4j5pn9n9v66x51w";
  };

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkgconfig
    wrapGAppsHook
  ];

  buildInputs = with gst_all_1; [
    gst-libav
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gstreamer
    gtk3
    libsoup
    totem-pl-parser
  ] ++ lib.optional lastFMSupport libsecret;

  propagatedBuildInputs = with python3.pkgs; [
    beautifulsoup4
    pillow
    pycairo
    pygobject3
  ]
  ++ lib.optional lastFMSupport pylast
  ++ lib.optional youtubeSupport youtube-dl
  ;

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  postFixup = ''
    wrapPythonProgramsIn $out/libexec "$out $propagatedBuildInputs"
  '';

  strictDeps = false;

  # Produce only one wrapper using wrap-python passing
  # gappsWrapperArgs to wrap-python additional wrapper
  # argument
  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    changelog = "https://gitlab.gnome.org/World/lollypop/tags/${version}";
    description = "A modern music player for GNOME";
    homepage = https://wiki.gnome.org/Apps/Lollypop;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ worldofpeace ];
    platforms = platforms.linux;
  };
}
