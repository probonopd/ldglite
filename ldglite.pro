# Created by and for Qt Creator. This file was created for editing the project sources only.
# You may attempt to use it for building too, by modifying this file here.

QT -= core gui
TEMPLATE = app

# The ABI version.
VER_MAJ = 1
VER_MIN = 3
VER_PAT = 3
VER_BLD = 0
win32: VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT"."$$VER_BLD # major.minor.patch.build
else: VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT              # major.minor.patch
DEFINES += VERSION_INFO=\\\"$$VERSION\\\"

contains(QT_ARCH, x86_64) {
    ARCH = 64
} else {
    ARCH = 32
}
DEFINES += ARCH=\\\"$$join(ARCH,,,bit)\\\"
message("~~~ LDGLITE $$join(ARCH,,,bit) EXECUTABLE VERSION $$VERSION ~~~")

unix: DEFINES += UNIX
macx: DEFINES += MACOS_X

TARGET +=
DEPENDPATH += .
INCLUDEPATH += .
INCLUDEPATH += ldrawini

CONFIG += static
CONFIG += skip_target_version_ext
TARGET = ldglite
CONFIG(debug, debug|release) {
    DESTDIR = $$join(ARCH,,,bit_debug)
    BUILD = DEBUG
} else {
    DESTDIR = $$join(ARCH,,,bit_release)
    BUILD = RELEASE
}

message("~~~ LDGLITE $$BUILD BUILD ~~~")

!contains(CONFIG, ENABLE_PNG): CONFIG += ENABLE_PNG
!contains(CONFIG, ENABLE_TILE_RENDERING): CONFIG += ENABLE_TILE_RENDERING
!contains(CONFIG, ENABLE_OFFSCREEN_RENDERING): CONFIG += ENABLE_OFFSCREEN_RENDERING
!contains(CONFIG, ENABLE_TEST_GUI): CONFIG += ENABLE_TEST_GUI

DEFINES += USE_OPENGL
DEFINES += USE_L3_PARSER
DEFINES += USE_BMP8
DEFINES += HAVE_STRDUP

include($$PWD/ldglite.pri)
include(ldrawini/ldrawini.pri)

ENABLE_PNG {
    DEFINES += USE_PNG
    win32 {
        INCLUDEPATH += \
        $$PWD/win/png/include

        equals (ARCH, 64): LIBS += -L$$_PRO_FILE_PWD_/win/png/lib/x64 -lpng
        else: LIBS += -L$$_PRO_FILE_PWD_/win/png/lib -lpng
        message("~~~ USING LOCAL COPY OF PNG LIBRARY ~~~")
    } else {
        macx {
            # To install libpng follow these instructions:
            # 1. Press Command+Space and type Terminal and press enter/return key.
            # 2. [Optional - if you don't already have Homebrew installed] Run in Terminal app:
            #    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
            #    and press enter/return key. Wait for the command to finish - it may take a long time.
            # 3. Run:
            #    brew install libpng --universal [both 32-bit and 64-bit code]
            # Done! You can now use libpng.
            #
            SYSTEM_PNG_HEADERS = /usr/local/include/png.h
            exists(SYSTEM_PNG_HEADERS) {
                 INCLUDEPATH += /usr/local/include
            } else {
                message("~~~ USING LOCAL COPY OF PNG HEADERS ~~~")
                INCLUDEPATH += $$PWD/macx/png/include
            }
            SYSTEM_PNG_LIB = /usr/local/lib/libpng.a
            exists(SYSTEM_PNG_LIB) {
                LIBS += /usr/local/lib/libpng.a
            } else {
                message("~~~ USING LOCAL COPY OF PNG LIBRARY ~~~")
                LIBS += $$PWD/macx/png/lib/libpng.a
            }
        } else {
            LIBS += -lpng
        }
    }
    LIBS +=  -lz
}

ENABLE_TILE_RENDERING {
    DEFINES += TILE_RENDER_OPTION
    include(tiles.pri)
}

ENABLE_TEST_GUI {
    DEFINES += TEST_MUI_GUI
    macx: DEFINES += USE_GLUT_MENUS
    INCLUDEPATH += \
    $$PWD/mui/src
    include(mui/mui.pri)
}

win32 {
    CONFIG += windows
    CONFIG += debug_and_release

    QMAKE_LFLAGS += -static
    QMAKE_LFLAGS += -static-libgcc
    QMAKE_LFLAGS += -static-libstdc++

    QMAKE_TARGET_COMPANY = "Don Heyse"
    QMAKE_TARGET_DESCRIPTION = "LDraw Image Renderer"
    QMAKE_TARGET_COPYRIGHT = "Copyright (c) 2017 Don Heyse, Trevor SANDY"
    QMAKE_TARGET_PRODUCT = "LDGLite ($$join(ARCH,,,bit))"
    RC_LANG = "English (United Kingdom)"
    RC_ICONS = "ldglite.ico"

    ENABLE_OFFSCREEN_RENDERING: DEFINES += WIN_DIB_OPTION

    DEFINES += USING_FREEGLUT
    DEFINES += FREEGLUT_STATIC
    INCLUDEPATH += \
    $$PWD/win/freeglut/include

    equals (ARCH, 64): LIBS += -L$$_PRO_FILE_PWD_/win/freeglut/lib/x64 -lfreeglut_static
    else: LIBS += -L$$_PRO_FILE_PWD_/win/freeglut/lib -lfreeglut_static
    message("~~~ USING LOCAL COPY OF FREEGLUT ~~~")

    LIBS += -lshell32 -lglu32 -lopengl32 -lwinmm -lgdi32
}

unix:!macx {
    ENABLE_OFFSCREEN_RENDERING: DEFINES += OSMESA_OPTION

    DEFINES += USE_ALPHA_BUFFER

    LIBS += -lOSMesa -lglut -lGLU -lGL -lX11 -lXext -lm
}

# some funky processing to get the prefix passed in on the command line
# CONFIG+=3RD_PARTY_INSTALL=../lpub3d_linux_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../lpub3d_macos_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../lpub3d_windows_3rdparty
3RD_ARG = $$find(CONFIG, 3RD_PARTY_INSTALL.*)
!isEmpty(3RD_ARG): CONFIG -= $$3RD_ARG
CONFIG += $$section(3RD_ARG, =, 0, 0)

3RD_PARTY_INSTALL {
    macx: CONFIG                            -= app_bundle   # don't creatre app bundle
    3RD_PREFIX                               = $$_PRO_FILE_PWD_/$$section(3RD_ARG, =, 1, 1)
    isEmpty(3RD_PREFIX):3RD_PREFIX           = $$_PRO_FILE_PWD_/3rdPartyInstall
    isEmpty(3RD_PACKAGE_VER):3RD_PACKAGE_VER = $$TARGET-$$VER_MAJ"."$$VER_MIN
    isEmpty(3RD_BINDIR):3RD_BINDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/bin/$$QT_ARCH
    isEmpty(3RD_DOCDIR):3RD_DOCDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/docs
    isEmpty(3RD_RESOURCES):3RD_RESOURCES     = $$3RD_PREFIX/$$3RD_PACKAGE_VER/resources

    message("~~~ LDGLITE 3RD INSTALL PREFIX $${3RD_PREFIX} ~~~")

    target.path                 = $${3RD_BINDIR}
    documentation.path          = $${3RD_DOCDIR}
    documentation.files         = doc/ldglite.1 doc/LICENCE doc/README.TXT
    resources.path              = $${3RD_RESOURCES}
    resources.files             = set-ldrawdir.command
    macx: resources.files      += ldglite_w.command

    INSTALLS += target documentation resources
}

macx {
    INCLUDEPATH += \
    $$PWD/macx/include \
    $$PWD/macx/glut/include
    QMAKE_CXXFLAGS += -F/System/Library/Frameworks
    # Using local glut headers because source originally written
    # for developer-defined glut library so $$PWD/macx/glut/include above.
    message("~~~ USING LOCAL COPY OF GL HEADERS ~~~")

    ENABLE_OFFSCREEN_RENDERING: DEFINES += CGL_OFFSCREEN_OPTION
    MACOSX_FRAMEWORKS += -framework OpenGL -framework GLUT

    equals(QT_MAJOR_VERSION,4):equals(QT_MINOR_VERSION,7):equals(ARCH,32) {    # qt 4.7 carbon (32bit only)
        DEFINES += USING_CARBON
        QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.7
        MACOSX_FRAMEWORKS += -framework Carbon
        include(carbon.pri)
        message("~~~ USING CARBON FRAMEWORK ~~~")
    } else {
        DEFINES += USING_COCOA
        QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.9
        MACOSX_FRAMEWORKS += -framework Cocoa
        message("~~~ USING COCOA FRAMEWORK ~~~")
    }

    DEFINES += NEED_MIN_MAX
    DEFINES += NOT_WARPING
    DEFINES += VISIBLE_SPIN_CURSOR
    DEFINES += SAVE_DEPTH_ALL
    DEFINES += SAVE_COLOR_ALL
    DEFINES += MACOS_X_TEST2

    LIBS += $$MACOSX_FRAMEWORKS -lobjc -lstdc++ -lm

    app_bundle {
        ICON = ldglite.icns
        QMAKE_INFO_PLIST = Info.plist

        ldglite_osxwrapper.files += ldglite_w.command
        ldglite_osxwrapper.path = Contents/MacOS

        set_ldraw_directory.files += set-ldrawdir.command
        set_ldraw_directory.path = Contents/Resources

        QMAKE_BUNDLE_DATA += \
            ldglite_osxwrapper set_ldraw_directory

        INFO_PLIST_FILE = $$shell_quote$$DESTDIR/ldglite.app/Contents/Info.plist
        PLIST_COMMAND = /usr/libexec/PlistBuddy -c
        TYPEINFO_COMMAND = /bin/echo "APPLLdGL" > $$DESTDIR/ldglite.app/Contents/PkgInfo
        WRAPPER_TARGET = $$DESTDIR/ldglite.app/Contents/MacOS/ldglite_w.command
        WRAPPER_CHMOD_COMMAND = chmod 755 $$WRAPPER_TARGET
        LDRAWDIR_TARGET = $$DESTDIR/ldglite.app/Contents/Resources/set-ldrawdir.command
        LDRAWDIR_CHMOD_COMMAND = chmod 755 $$LDRAWDIR_TARGET
        QMAKE_POST_LINK += $$escape_expand(\n\t)   \
                           $$PLIST_COMMAND \"Set :CFBundleShortVersionString $${VERSION}\" $${INFO_PLIST_FILE}  \
                           $$escape_expand(\n\t)   \
                           $$PLIST_COMMAND \"Set :CFBundleVersion $${VERSION}\" $${INFO_PLIST_FILE} \
                           $$escape_expand(\n\t)   \
                           $$PLIST_COMMAND \"Set :CFBundleGetInfoString ldglite $${VERSION} https://github.com/trevorsandy/ldglite\" $${INFO_PLIST_FILE} \
                           $$escape_expand(\n\t)   \
                           $$shell_quote$${TYPEINFO_COMMAND} \
                           $$escape_expand(\n\t)   \
                           $$shell_quote$${WRAPPER_CHMOD_COMMAND} \
                           $$escape_expand(\n\t)   \
                           $$shell_quote$${LDRAWDIR_CHMOD_COMMAND}
    }
}

OBJECTS_DIR = $$DESTDIR/.obj

# set config to enable build check
# CONFIG+=BUILD_CHECK
# ldglite -l3 -i2 -ca0.01 -cg23,-45,3031328 -J -v1240,1753 -o0,-292 -W2 -q -fh -w1 -l =tests/LDConfigCustom01.ldr -mFtests/TestOK_1.3.3_Foo2.png tests/Foo2.ldr
BUILD_CHECK {
    QMAKE_POST_LINK += $$escape_expand(\n\t)                                    \
                    ./$$DESTDIR/$${TARGET} -l3 -i2 -ca0.01 -cg23,-45,3031328 -J \
                    -v1240,1753 -o0,-292 -W2 -q -fh -w1 -l                      \
                    ="$$_PRO_FILE_PWD_/tests/LDConfigCustom01.ldr"              \
                    -mF"$$_PRO_FILE_PWD_/tests/$$DESTDIR-TestOK_1.3.3_Foo2.png $$_PRO_FILE_PWD_/tests/Foo2.ldr"
}

# suppress warnings
QMAKE_CFLAGS_WARN_ON =  -Wall -W \
                        -Wno-unused-parameter \
                        -Wno-unused-result \
                        -Wno-implicit-int \
                        -Wno-unused-variable \
                        -Wno-implicit-function-declaration \
                        -Wno-parentheses \
                        -Wno-switch \
                        -Wno-sign-compare \
                        -Wno-incompatible-pointer-types \
                        -Wno-return-type \
                        -Wno-uninitialized \
                        -Wno-format \
                        -Wno-format-security \
                        -Wno-pointer-sign \
                        -Wno-missing-braces \
                        -Wno-unused-function \
                        -Wno-unused-label \
                        -Wno-strict-aliasing \
                        -Wno-format-zero-length \
                        -Wno-format-extra-args \
                        -Wno-unknown-pragmas \
                        -Wno-comment \
                        -Wno-unused-value
macx {
QMAKE_CFLAGS_WARN_ON +=  \
                        -Wno-macro-redefined \
                        -Wno-deprecated-declarations
}
QMAKE_CXXFLAGS_WARN_ON = $${QMAKE_CFLAGS_WARN_ON}
