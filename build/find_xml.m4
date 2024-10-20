dnl Check for LIBXML2 Libraries
dnl CHECK_LIBXML2(ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND])
dnl Sets:
dnl  LIBXML2_CFLAGS
dnl  LIBXML2_LIBS

AC_DEFUN([CHECK_XML2CONFIG], [

AC_MSG_CHECKING([for libxml2 config script])

for x in ${test_paths}; do
    dnl # Determine if the script was specified and use it directly
    if test ! -d "$x" -a -e "$x"; then
        LIBXML2_CONFIG=$x
        libxml2_path="no"
        break
    fi

    dnl # Try known config script names/locations
    for LIBXML2_CONFIG in xml2-config xml-2-config xml-config; do
        if test -e "${x}/bin/${LIBXML2_CONFIG}"; then
            libxml2_path="${x}/bin"
            break
        elif test -e "${x}/${LIBXML2_CONFIG}"; then
            libxml2_path="${x}"
            break
        else
            libxml2_path=""
        fi
    done
    if test -n "$libxml2_path"; then
        break
    fi
done

if test -n "${libxml2_path}"; then
    if test "${libxml2_path}" != "no"; then
        LIBXML2_CONFIG="${libxml2_path}/${LIBXML2_CONFIG}"
    fi
    AC_MSG_RESULT([${LIBXML2_CONFIG}])
    LIBXML2_VERSION=`${LIBXML2_CONFIG} --version | sed 's/^[[^0-9]][[^[:space:]]][[^[:space:]]]*[[[:space:]]]*//'`
    if test "$verbose_output" -eq 1; then AC_MSG_NOTICE(xml VERSION: $LIBXML2_VERSION); fi
    LIBXML2_CFLAGS="`${LIBXML2_CONFIG} --cflags`"
    if test "$verbose_output" -eq 1; then AC_MSG_NOTICE(xml CFLAGS: $LIBXML2_CFLAGS); fi
    LIBXML2_LDADD="`${LIBXML2_CONFIG} --libs`"
    if test "$verbose_output" -eq 1; then AC_MSG_NOTICE(xml LDADD: $LIBXML2_LDADD); fi

    AC_MSG_CHECKING([if libxml2 is at least v${LIBXML2_MIN_VERSION}])
    libxml2_min_ver=`echo ${LIBXML2_MIN_VERSION} | awk -F. '{print (\$ 1 * 1000000) + (\$ 2 * 1000) + \$ 3}'`
    libxml2_ver=`echo ${LIBXML2_VERSION} | awk -F. '{print (\$ 1 * 1000000) + (\$ 2 * 1000) + \$ 3}'`
    if test "$libxml2_ver" -ge "$libxml2_min_ver"; then
        AC_MSG_RESULT([yes, $LIBXML2_VERSION])
    else
        AC_MSG_RESULT([no, $LIBXML2_VERSION])
        AC_MSG_ERROR([NOTE: libxml2 library must be at least ${LIBXML2_MIN_VERSION}])
    fi

else
    AC_MSG_RESULT([no])
fi
])

AC_DEFUN([CHECK_LIBXML2], [

AC_ARG_WITH(
    libxml,
    [AS_HELP_STRING([--with-libxml=PATH],[Path to libxml2 prefix or config script])],
    [test_paths="${with_libxml}"],
    [test_paths="/usr/local/libxml2 /usr/local/xml2 /usr/local/xml /usr/local /opt/libxml2 /opt/libxml /opt/xml2 /opt/xml /opt /usr"])

LIBXML2_MIN_VERSION="2.6.29"
LIBXML2_PKG_NAME="libxml-2.0"
LIBXML2_CONFIG=""
LIBXML2_VERSION=""
LIBXML2_CFLAGS=""
LIBXML2_CPPFLAGS=""
LIBXML2_LDADD=""
LIBXML2_LDFLAGS=""

if test "x${with_libxml}" != "xno"; then
    if test -n "${PKG_CONFIG}"; then
        AC_MSG_CHECKING([for libxml2 >= ${LIBXML2_MIN_VERSION} via pkg-config])
        if `${PKG_CONFIG} --exists "${LIBXML2_PKG_NAME} >= ${LIBXML2_MIN_VERSION}"`; then
            LIBXML2_VERSION="`${PKG_CONFIG} --modversion ${LIBXML2_PKG_NAME}`"
            LIBXML2_CFLAGS="`${PKG_CONFIG} --cflags ${LIBXML2_PKG_NAME}`"
            LIBXML2_LDADD="`${PKG_CONFIG} --libs-only-l ${LIBXML2_PKG_NAME}`"
            LIBXML2_LDFLAGS="`${PKG_CONFIG} --libs-only-L --libs-only-other ${LIBXML2_PKG_NAME}`"
            AC_MSG_RESULT([found version ${LIBXML2_VERSION}])
        else
            AC_MSG_RESULT([not found])
        fi
    fi

    if test -z "${LIBXML2_VERSION}"; then
        CHECK_XML2CONFIG
    fi
fi

AC_SUBST(LIBXML2_CONFIG)
AC_SUBST(LIBXML2_VERSION)
AC_SUBST(LIBXML2_CFLAGS)
AC_SUBST(LIBXML2_CPPFLAGS)
AC_SUBST(LIBXML2_LDADD)
AC_SUBST(LIBXML2_LDFLAGS)

if test -z "${LIBXML2_VERSION}"; then
    AC_MSG_NOTICE([*** xml library not found.])
    ifelse([$2], , AC_MSG_ERROR([libxml2 is required]), $2)
else
    AC_MSG_NOTICE([using libxml2 v${LIBXML2_VERSION}])
    ifelse([$1], , , $1) 
fi
])
