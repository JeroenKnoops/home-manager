{
  pkgs,
  src,
}:
let
  pdfium = pkgs.pdfium;
in
pkgs.rustPlatform.buildRustPackage {
  pname = "athenaeum-mcp-server";
  version = "0.1.0";

  inherit src;
  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = with pkgs; [
    protobuf
    cmake
    pkg-config
    makeWrapper
    cacert
  ];

  buildInputs = [ pdfium ];

  # buildRustPackage runs `cargo test` in the checkPhase. Two wirings are
  # needed there:
  #  1. pdfium loader path — Pdfium::default() finds libpdfium only via the OS
  #     dynamic-linker search path (LD_LIBRARY_PATH / DYLD_LIBRARY_PATH).
  #  2. SSL_CERT_FILE — six core embed tests build a reqwest client whose
  #     rustls-platform-verifier (-> rustls-native-certs on Linux) loads the OS
  #     trust store eagerly; the hermetic sandbox has none, so point it at
  #     pkgs.cacert. rustls-native-certs loads ONLY from SSL_CERT_FILE when set.
  # One export each covers every workspace test binary (cargo runs them in a
  # single invocation). Append loader paths rather than clobber.
  preCheck =
    let
      libDir = "${pdfium}/lib";
    in
    ''
      export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ''
    + (
      if pkgs.stdenv.hostPlatform.isDarwin then
        ''
          export DYLD_LIBRARY_PATH="${libDir}''${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
        ''
      else
        ''
          export LD_LIBRARY_PATH="${libDir}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        ''
    );

  # buildRustPackage installs every workspace binary. relevance-eval is a
  # hand-run, dev-shell-only evaluation instrument (live Ollama + human grader;
  # see crates/ingest/src/bin/relevance-eval.rs) — drop it rather than ship a
  # tool meant only for `nix develop`. The two deployed binaries both call
  # pdfium-render's Pdfium::default(), which resolves libpdfium only via the OS
  # loader path, so bake the pdfium lib dir onto that path with wrapProgram
  # (DYLD_LIBRARY_PATH on macOS, LD_LIBRARY_PATH on Linux).
  postInstall =
    let
      libVar = if pkgs.stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in
    ''
      rm -f $out/bin/relevance-eval
      for bin in athenaeum-mcp-server athenaeum-ingest; do
        wrapProgram $out/bin/$bin \
          --prefix ${libVar} : ${pdfium}/lib
      done
    '';
}
