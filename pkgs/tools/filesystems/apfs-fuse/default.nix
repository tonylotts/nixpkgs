{ stdenv, fetchFromGitHub, fuse3, osxfuse, bzip2, zlib, attr, cmake, coreutils
, clang }:

stdenv.mkDerivation {
  pname = "apfs-fuse-unstable";
  version = "2019-07-23";

  src = fetchFromGitHub {
    owner = "sgan81";
    repo = "apfs-fuse";
    rev = "309ecb030f38edac4c10fa741a004c5eb7a23e15";
    sha256 = "0wq6rlqi00m5dp5gbzy65i1plm40j6nsm7938zvfgx5laal4wzr2";
    fetchSubmodules = true;
  };

  preConfigure = with stdenv;
    with stdenv.lib;
    "" + optionalString (isDarwin) ''
      substituteInPlace ./CMakeLists.txt \
        --replace "target_link_libraries(apfs-fuse apfs /usr/local/lib/libosxfuse.dylib)" \
        "target_link_libraries(apfs-fuse apfs ${osxfuse}/lib/libosxfuse.dylib)" \
        --replace "target_include_directories(apfs-fuse PRIVATE /usr/local/include/osxfuse/)" \
        "target_include_directories(apfs-fuse PRIVATE ${osxfuse}/include/osxfuse/)"
    '';

  buildInputs = with stdenv;
    with stdenv.lib;
    [ bzip2 zlib ] ++ optionals isLinux [ fuse3 attr ]
    ++ optionals isDarwin [ osxfuse ];

  nativeBuildInputs = [ cmake ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/sgan81/apfs-fuse";
    description = "FUSE driver for APFS (Apple File System)";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ealasu ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
