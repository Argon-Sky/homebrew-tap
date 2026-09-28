class HerdrCodexbar < Formula
  desc "Subscription quota from CodexBar in Herdr's agent sidebar"
  homepage "https://github.com/Argon-Sky/herdr-codexbar"
  url "https://github.com/Argon-Sky/herdr-codexbar/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "dd681fd1c2db927fe0c34e184d41264a91587e49b269deef24edddd55b83909f"
  license "MIT"

  depends_on :macos
  depends_on "python@3.13"

  def install
    libexec.install "herdr_codexbar"
    # Agents and Herdr call the stable opt path, so upgrades need no new setup.
    (bin/"herdr-codexbar").write <<~SH
      #!/bin/sh
      export HERDR_CODEXBAR_BIN="#{opt_bin}/herdr-codexbar"
      export HERDR_CODEXBAR_BREW=1
      export PYTHONPATH="#{opt_libexec}"
      exec "#{Formula["python@3.13"].opt_bin}/python3.13" -m herdr_codexbar "$@"
    SH
    chmod 0755, bin/"herdr-codexbar"
  end

  service do
    run [opt_bin/"herdr-codexbar", "refresh"]
    run_type :interval
    interval 180
    log_path var/"log/herdr-codexbar.log"
    error_log_path var/"log/herdr-codexbar.log"
  end

  def caveats
    <<~EOS
      Finish the setup (it shows its changes first with --dry-run):
        herdr-codexbar check
        herdr-codexbar setup
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/herdr-codexbar --version")
    assert_match "agent sidebar", shell_output("#{bin}/herdr-codexbar --help")
  end
end
