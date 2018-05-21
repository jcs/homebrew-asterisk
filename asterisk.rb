class Asterisk < Formula
  desc "Open Source PBX and telephony toolkit (LTS branch)"
  homepage "http://www.asterisk.org"
  url "http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13.21.0.tar.gz"
  sha256 "73043e4e7721f3ef919b470932e0c303e9a210c75e2cfb669711a51571f79438"

  # add coin detection
  patch do
    url "https://raw.githubusercontent.com/jcs/homebrew-asterisk/master/asterisk-coins.patch"
    sha256 "558beef933ed662e035e931b78fea7bb63be7904c4ec02d984641fff6c156b17"
  end

  depends_on "pkg-config" => :build

  depends_on "jansson"
  depends_on "libgsm"
  depends_on "libxml2"
  depends_on "openssl"
  depends_on "pjsip-asterisk"
  depends_on "speex"
  depends_on "sqlite"
  depends_on "srtp"

  def install
    ENV.append "CFLAGS", "-fno-strict-aliasing"

    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          "--datadir=#{share}/#{name}",
                          "--docdir=#{doc}/asterisk",
                          "--enable-dev-mode=no",
                          "--with-crypto",
                          "--with-ssl",
                          "--without-pjproject-bundled",
                          "--with-pjproject",
                          "--with-sqlite3",
                          "--without-sqlite",
                          "--without-gmime",
                          "--without-gtk2",
                          "--without-iodbc",
                          "--without-netsnmp"

    system "make", "menuselect/cmenuselect",
                   "menuselect/nmenuselect",
                   "menuselect/gmenuselect",
                   "menuselect/menuselect",
                   "menuselect-tree",
                   "menuselect.makeopts"

    # enable gsm en sounds
    system "menuselect/menuselect",
           "--enable", "MOH-OPSOUND-GSM", "menuselect.makeopts"
    system "menuselect/menuselect",
           "--enable", "CORE-SOUNDS-EN-GSM", "menuselect.makeopts"
    system "menuselect/menuselect",
           "--enable", "EXTRA-SOUNDS-EN-GSM", "menuselect.makeopts"

    system "make", "all", "NOISY_BUILD=yes"
    system "make", "install", "samples"

    # Replace Cellar references to opt/asterisk
    system "sed", "-i", "", "s#Cellar/asterisk/[^/]*/#opt/asterisk/#", "#{etc}/asterisk/asterisk.conf"

    # Run as asterisk:asterisk by default
    system "sed", "-i", "", "s#^;runuser =.*#runuser = asterisk#", "#{etc}/asterisk/asterisk.conf"
    system "sed", "-i", "", "s#^;rungroup =.*#rungroup = asterisk#", "#{etc}/asterisk/asterisk.conf"
  end

  plist_options :startup => false, :manual => "asterisk -r"

  def plist; <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
          <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/asterisk</string>
          <string>-f</string>
          <string>-C</string>
          <string>#{etc}/asterisk/asterisk.conf</string>
        </array>
         <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/asterisk.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/asterisk.log</string>
        <key>ServiceDescription</key>
        <string>Asterisk PBX</string>
      </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS
Create "asterisk" user and group (sharing only) from System Preferences,
then update permissions on directories asterisk writes to:

sudo chown -R asterisk:asterisk /usr/local/var/{lib,spool,run,log}/asterisk

When starting service, make sure to start it as root:

sudo brew services start jcs/asterisk-lts/asterisk
EOS
  end
end
