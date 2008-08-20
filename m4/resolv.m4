dnl AC_C_DNS
dnl Checks resolv.h presence and usability
dnl Checks for specific lresolv exports
dnl Checks for lresolve reentrance
dnl
dnl Note using AC_LINK_IFELSE instead of AC_CHECK_LIB
dnl as symbols are often redefined in resolv.h

AC_DEFUN([AC_C_DNS], [

AC_ARG_ENABLE([dns],
    AC_HELP_STRING([--disable-dns], [disable support for database verification through DNS]),
    [want_dns=$enableval], [want_dns=yes]
)
if test $want_dns = yes; then
    ac_cv_have_lresolv=no
    AC_CHECK_HEADER([resolv.h],
	[
	    AC_CACHE_CHECK([for dn_expand in std libs], [ac_cv_have_lresolv_std], [
	    	ac_cv_have_lresolv_std='no'
	        AC_LINK_IFELSE([
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
int main() { return (int)dn_expand; }
		],
		[
		    ac_cv_have_lresolv_std='yes'
		    ac_cv_have_lresolv=''
		])
	    ])
	    if test "x$ac_cv_have_lresolv" = "xno"; then
	    bklibs=$LIBS
	    LIBS=-lresolv
	    AC_CACHE_CHECK([for dn_expand in -lresolv], [ac_cv_have_lresolv_lresolv], [
		ac_cv_have_lresolv_lresolv='yes'
		AC_LINK_IFELSE([
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
int main() { return (int)dn_expand; }
    	     	],
		[
		    ac_cv_have_lresolv_lresolv='yes'
		    ac_cv_have_lresolv=' -lresolv'
		])
	    ])
	    LIBS=$bklibs;
	    fi
	],
	[ ac_cv_have_lresolv=no ],
	[
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
    ])
    if test "x$ac_cv_have_lresolv" != "xno"; then
    	FRESHCLAM_LIBS="$FRESHCLAM_LIBS$ac_cv_have_lresolv"
	CLAMAV_MILTER_LIBS="$CLAMAV_MILTER_LIBS$ac_cv_have_lresolv"
	bklibs=$LIBS
	LIBS=$ac_cv_have_lresolv
	AC_DEFINE([HAVE_RESOLV_H],1,[have resolv.h])
	AC_CACHE_CHECK([for res_nquery in -lresolv], [ac_cv_have_lresolv_r], [
	    ac_cv_have_lresolv_r='no'
	    AC_LINK_IFELSE([
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
int main() { return (int)res_nquery; }
    	    ],
	    [
	        ac_cv_have_lresolv_r='yes'
	    ]),
	])
	LIBS=$bklibs
	if test "x$ac_cv_have_lresolv_r" = "xyes"; then
	    AC_DEFINE([HAVE_LRESOLV_R],1,[Define to 1 if -lresolv provides thread safe API's like res_nquery])
	fi
    else
	AC_MSG_WARN([****** DNS support disabled])
    fi
fi

])
