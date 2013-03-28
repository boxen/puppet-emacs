require 'formula'

class Emacs < Formula
  homepage 'http://www.gnu.org/software/emacs/'
  url 'http://ftpmirror.gnu.org/emacs/emacs-24.2.tar.bz2'
  mirror 'http://ftp.gnu.org/pub/gnu/emacs/emacs-24.2.tar.bz2'
  sha1 '38e8fbc9573b70a123358b155cf55c274b5a56cf'

  version "24.2-boxen2"

  option "cocoa", "Build a Cocoa version of emacs"
  option "srgb", "Enable sRGB colors in the Cocoa version of emacs"
  option "with-x", "Include X11 support"
  option "use-git-head", "Use Savannah git mirror for HEAD builds"
  option "keep-ctags", "Don't remove the ctags executable that emacs provides"

  if build.include? "use-git-head"
    head 'http://git.sv.gnu.org/r/emacs.git'
  else
    head 'bzr://http://bzr.savannah.gnu.org/r/emacs/trunk'
  end

  depends_on :x11 if build.include? "with-x"

  fails_with :llvm do
    build 2334
    cause "Duplicate symbol errors while linking."
  end

  def patches
    # Fullscreen patch works against 24.2; already included in 24.3+
    if build.include? "cocoa" and not build.head?
      "https://raw.github.com/gist/1746342/702dfe9e2dd79fddd536aa90d561efdeec2ba716"
    end
  end

  def install
    # HEAD builds are currently blowing up when built in parallel
    # as of April 20 2012
    ENV.j1 if build.head?

    args = ["--prefix=#{prefix}",
            "--without-dbus",
            "--enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp",
            "--infodir=#{info}/emacs"]

    if build.head? and File.exists? "./autogen/copy_autogen"
      opoo "Using copy_autogen"
      puts "See https://github.com/mxcl/homebrew/issues/4852"
      system "autogen/copy_autogen"
    end

    if build.include? "cocoa"
      # Patch for color issues described here:
      # http://debbugs.gnu.org/cgi/bugreport.cgi?bug=8402
      if build.include? "srgb"
        inreplace "src/nsterm.m",
          "*col = [NSColor colorWithCalibratedRed: r green: g blue: b alpha: 1.0];",
          "*col = [NSColor colorWithDeviceRed: r green: g blue: b alpha: 1.0];"
      end

      args << "--with-ns" << "--disable-ns-self-contained"
      system "./configure", *args
      system "make bootstrap"
      system "make install"
      prefix.install "nextstep/Emacs.app"

      # Follow MacPorts and don't install ctags from emacs. This allows vim
      # and emacs and ctags to play together without violence.
      unless build.include? "keep-ctags"
        (bin/"ctags").unlink
        (share/man/man1/"ctags.1.gz").unlink
      end

      # Replace the symlink with one that avoids starting Cocoa.
      (bin/"emacs").unlink # Kill the existing symlink
      (bin/"emacs").write <<-EOS.undent
        #!/bin/bash
        #{prefix}/Emacs.app/Contents/MacOS/Emacs -nw  "$@"
      EOS
      (bin/"emacs").chmod 0755
    else
      if build.include? "with-x"
        # These libs are not specified in xft's .pc. See:
        # https://trac.macports.org/browser/trunk/dports/editors/emacs/Portfile#L74
        # https://github.com/mxcl/homebrew/issues/8156
        ENV.append 'LDFLAGS', '-lfreetype -lfontconfig'
        args << "--with-x"
        args << "--with-gif=no" << "--with-tiff=no" << "--with-jpeg=no"
      else
        args << "--without-x"
      end

      system "./configure", *args
      system "make"
      system "make install"

      # Follow MacPorts and don't install ctags from emacs. This allows vim
      # and emacs and ctags to play together without violence.
      unless build.include? "keep-ctags"
        (bin/"ctags").unlink
        (share/man/man1/"ctags.1.gz").unlink
      end
    end
  end
end
