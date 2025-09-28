PORTNAME=	tools-make
DISTVERSION=       202509271954
CATEGORIES=	devel gnustep
PKGNAMEPREFIX=	gershwin-

MAINTAINER=	joe.maloney@icloud.com
COMMENT=	GNUstep makefile package
WWW=		http://www.gnustep.org/

LICENSE=	GPLv3

USES=		gershwin objc
CONFLICTS=	gnustep-make
GNU_CONFIGURE=	yes

USE_GITHUB=	yes
GH_ACCOUNT=	gershwin-desktop
GH_TAGNAME= c74782e42b6b7ce09442f66329b7f70760d32b23

MAKE_FLAGS=	OPTFLAG="${CFLAGS}"
CONFIGURE_ENV+=	INSTALL_PROGRAM="${INSTALL} -c" INSTALL_DATA="${INSTALL} -c"

CONFIGURE_ARGS+= \
	--with-config-file=/System/Library/Preferences/GNUstep.conf \
	--with-layout=gershwin \
	--with-library-combo=ng-gnu-gnu

GNU_CONFIGURE_PREFIX= ${GNUSTEP_SYSTEM_ROOT}
NO_ARCH=	yes

.include <bsd.port.mk>
